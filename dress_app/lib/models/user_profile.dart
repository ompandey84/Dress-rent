import 'package:dress_app/models/address.dart';

class UserProfile {
  final String id;
  String name;
  String email;
  String phone;
  String avatarUrl;
  bool isVendor;
  List<Address> addresses;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    this.isVendor = false,
    this.addresses = const [],
  });
}
