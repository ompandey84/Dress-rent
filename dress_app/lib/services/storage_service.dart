import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';

/// Real upload via Supabase Storage when configured, with a graceful
/// fallback for mock mode. Buckets are auto-created by the SQL migration
/// (`0001_full_schema.sql`).
class StorageService {
  String? _lastError;

  /// Most recent error message from an upload attempt, or null if it
  /// succeeded. Useful for surfacing why a profile photo / KYC upload
  /// silently kept a placeholder.
  String? get lastError => _lastError;

  Future<String> _uploadFile(
      String bucketName, File file, String folderPath) async {
    _lastError = null;
    if (!SupabaseService.isConfigured) {
      // Mock mode: return the local file URI so the UI can show
      // the picked image (vs. a hardcoded placeholder).
      return 'file://${file.path}';
    }
    try {
      final dot = file.path.lastIndexOf('.');
      final ext = (dot != -1 && dot < file.path.length - 1)
          ? file.path.substring(dot + 1).toLowerCase()
          : 'jpg';
      final objectPath =
          '$folderPath/${DateTime.now().millisecondsSinceEpoch}.$ext';
      final bytes = await file.readAsBytes();
      await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(objectPath, Uint8List.fromList(bytes),
              fileOptions: FileOptions(contentType: 'image/$ext'));
      return Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(objectPath);
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Upload error [$bucketName/$folderPath]: $e');
      rethrow;
    }
  }

  Future<String> uploadAvatar(File file, String userId) =>
      _uploadFile('avatars', file, userId);

  Future<String> uploadProductImage(File file, String productId) =>
      _uploadFile('products', file, productId);

  Future<String> uploadVendorCover(File file, String vendorId) =>
      _uploadFile('vendor_covers', file, vendorId);

  Future<String> uploadPickupPhoto(File file, String requestId) =>
      _uploadFile('pickup_photos', file, requestId);

  Future<String> uploadChatFile(File file, String roomId) =>
      _uploadFile('chat_files', file, roomId);

  /// Upload KYC document. Uses the `kyc_documents` bucket.
  Future<String> uploadKycDocument(File file, String userId, String idType) {
    return _uploadFile('kyc_documents', file, '${userId}_$idType');
  }
}
