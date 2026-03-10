class Address {
  final String id;
  final String userId;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address({
    required this.id,
    this.userId = '',
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.state = '',
    required this.zipCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      label: json['label'] as String? ?? 'Home',
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId.isNotEmpty) 'user_id': userId,
      'label': label,
      'full_name': fullName,
      'phone': phone,
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_default': isDefault,
    };
  }
}
