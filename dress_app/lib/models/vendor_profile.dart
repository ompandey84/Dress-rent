class VendorProfile {
  final String id;
  final String userId;
  final String? storeId;
  final String businessName;
  final String vendorName;
  final String phone;
  final String email;
  final String shopAddress;
  final String city;
  final String state;
  final String pincode;
  final String verificationStatus;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  VendorProfile({
    required this.id,
    required this.userId,
    this.storeId,
    required this.businessName,
    required this.vendorName,
    required this.phone,
    required this.email,
    this.shopAddress = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.verificationStatus = 'pending',
    this.verifiedAt,
    required this.createdAt,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      storeId: json['store_id'] as String?,
      businessName: json['business_name'] as String? ?? '',
      vendorName: json['vendor_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      shopAddress: json['shop_address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
