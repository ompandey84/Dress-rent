import 'package:dress_app/models/address.dart';

class UserProfile {
  final String id;
  String name;
  String email;
  String phone;
  String avatarUrl;
  String location;
  bool isVendor;
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
    this.reviewsCount = 0,
    this.rating = 0.0,
    this.addresses = const [],
  });
}
