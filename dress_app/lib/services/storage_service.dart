import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Generic method to upload a file to a specific bucket
  Future<String> _uploadFile(String bucketName, File file, String folderPath) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final finalPath = folderPath.isNotEmpty ? '$folderPath/$fileName' : fileName;
      
      await _supabase.storage.from(bucketName).upload(
        finalPath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      final String publicUrl = _supabase.storage.from(bucketName).getPublicUrl(finalPath);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload file to $bucketName: $e');
    }
  }

  // Avatars
  Future<String> uploadAvatar(File file, String userId) async {
    return await _uploadFile('avatars', file, userId);
  }

  // Product Images
  Future<String> uploadProductImage(File file, String storeId) async {
    return await _uploadFile('product-images', file, storeId);
  }

  // Product Videos
  Future<String> uploadProductVideo(File file, String storeId) async {
    return await _uploadFile('product-videos', file, storeId);
  }

  // Chat Attachments
  Future<String> uploadChatAttachment(File file, String roomId) async {
    // Note: private bucket usage, getting signed URL might be required instead of public URL
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final finalPath = '$roomId/$fileName';
      
      await _supabase.storage.from('chat-attachments').upload(finalPath, file);
      
      // Creating a signed URL valid for 1 year for simplicity in this mockup, 
      // in production short-lived URLs are better
      final String signedUrl = await _supabase.storage.from('chat-attachments').createSignedUrl(finalPath, 60 * 60 * 24 * 365);
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to upload chat attachment: $e');
    }
  }

  // Early Pickup Damage Photos
  Future<String> uploadPickupEvidence(File file, String requestId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final finalPath = '$requestId/$fileName';
      
      await _supabase.storage.from('pickup-evidence').upload(finalPath, file);
      
      final String signedUrl = await _supabase.storage.from('pickup-evidence').createSignedUrl(finalPath, 60 * 60 * 24 * 365);
      return signedUrl;
    } catch (e) {
      throw Exception('Failed to upload pickup evidence: $e');
    }
  }
  
  // Influencer Posts
  Future<String> uploadInfluencerPost(File file, String userId) async {
    return await _uploadFile('influencer-posts', file, userId);
  }

  // Delete File
  Future<void> deleteFile(String bucketName, String filePath) async {
    try {
      await _supabase.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete file from $bucketName: $e');
    }
  }
}
