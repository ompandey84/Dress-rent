import 'package:dress_app/models/address.dart';

/// KYC verification status
enum KycStatus { pending, submitted, approved, rejected }

KycStatus kycStatusFromString(String? s) {
  switch (s) {
    case 'approved':
      return KycStatus.approved;
    case 'submitted':
      return KycStatus.submitted;
    case 'rejected':
      return KycStatus.rejected;
    default:
      return KycStatus.pending;
  }
}

class UserProfile {
  final String id;
  String name;
  String email;
  String phone;
  String avatarUrl;
  String location;
  bool isVendor;
  bool isOnboarded;
  int reviewsCount;
  double rating;
  double responseRate;
  int totalOrders;
  List<Address> addresses;

  // New fields (Phase 1+)
  DateTime? dateOfBirth;
  bool isVerified;
  bool isAdmin;
  KycStatus kycStatus;
  String? kycIdUrl;
  String? kycIdType;
  String? referralCode;
  String? referredBy;
  String? pushToken;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.location = '',
    this.isVendor = false,
    this.isOnboarded = false,
    this.reviewsCount = 0,
    this.rating = 0.0,
    this.responseRate = 0.0,
    this.totalOrders = 0,
    this.addresses = const [],
    this.dateOfBirth,
    this.isVerified = false,
    this.isAdmin = false,
    this.kycStatus = KycStatus.pending,
    this.kycIdUrl,
    this.kycIdType,
    this.referralCode,
    this.referredBy,
    this.pushToken,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['full_name'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['phone_number'] as String? ?? '',
      avatarUrl: (json['avatar_url'] as String?) ?? (json['profile_image_url'] as String?) ?? '',
      location: json['location'] as String? ?? '',
      isVendor: json['is_vendor'] as bool? ?? (json['role'] == 'vendor'),
      isOnboarded: json['is_onboarded'] as bool? ?? false,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      responseRate: (json['response_rate'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? json['total_rentals'] as int? ?? 0,
      addresses: const [],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      kycStatus: kycStatusFromString(json['kyc_status'] as String?),
      kycIdUrl: json['kyc_id_url'] as String?,
      kycIdType: json['kyc_id_type'] as String?,
      referralCode: json['referral_code'] as String?,
      referredBy: json['referred_by'] as String?,
      pushToken: json['push_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'name': name,
      'email': email,
      'phone': phone,
      'phone_number': phone,
      'avatar_url': avatarUrl,
      'profile_image_url': avatarUrl,
      'is_vendor': isVendor,
      'is_onboarded': isOnboarded,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      'is_verified': isVerified,
      'kyc_status': kycStatus.name,
      if (kycIdUrl != null) 'kyc_id_url': kycIdUrl,
      if (kycIdType != null) 'kyc_id_type': kycIdType,
      if (referralCode != null) 'referral_code': referralCode,
    };
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? location,
    bool? isVendor,
    bool? isOnboarded,
    int? reviewsCount,
    double? rating,
    double? responseRate,
    int? totalOrders,
    List<Address>? addresses,
    DateTime? dateOfBirth,
    bool? isVerified,
    KycStatus? kycStatus,
    String? kycIdUrl,
    String? kycIdType,
    String? referralCode,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      location: location ?? this.location,
      isVendor: isVendor ?? this.isVendor,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      rating: rating ?? this.rating,
      responseRate: responseRate ?? this.responseRate,
      totalOrders: totalOrders ?? this.totalOrders,
      addresses: addresses ?? this.addresses,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin,
      kycStatus: kycStatus ?? this.kycStatus,
      kycIdUrl: kycIdUrl ?? this.kycIdUrl,
      kycIdType: kycIdType ?? this.kycIdType,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy,
      pushToken: pushToken,
    );
  }

  /// Whether the user can use the app's main features.
  bool get isFullyOnboarded => isOnboarded && kycStatus != KycStatus.rejected;
}
