import 'package:dress_app/models/address.dart';

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
  List<Address> addresses;

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
    this.addresses = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isVendor: json['is_vendor'] as bool? ?? false,
      isOnboarded: json['is_onboarded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'location': location,
      'is_vendor': isVendor,
      'is_onboarded': isOnboarded,
    };
  }
  
  UserProfile copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    String? location,
    bool? isVendor,
    bool? isOnboarded,
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
      reviewsCount: reviewsCount,
      rating: rating,
      addresses: addresses,
    );
  }
}
