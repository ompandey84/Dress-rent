class Address {
  final String id;
  final String label; // Home, Office, etc.
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String zipCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.zipCode,
    this.isDefault = false,
  });
}
