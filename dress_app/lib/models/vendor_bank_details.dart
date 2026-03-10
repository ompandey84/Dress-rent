class VendorBankDetails {
  final String id;
  final String vendorProfileId;
  final String accountHolderName;
  final String bankAccountNumber;
  final String ifscCode;
  final String upiId;

  VendorBankDetails({
    required this.id,
    required this.vendorProfileId,
    required this.accountHolderName,
    required this.bankAccountNumber,
    required this.ifscCode,
    this.upiId = '',
  });

  factory VendorBankDetails.fromJson(Map<String, dynamic> json) {
    return VendorBankDetails(
      id: json['id'] as String,
      vendorProfileId: json['vendor_profile_id'] as String? ?? '',
      accountHolderName: json['account_holder_name'] as String? ?? '',
      bankAccountNumber: json['bank_account_number'] as String? ?? '',
      ifscCode: json['ifsc_code'] as String? ?? '',
      upiId: json['upi_id'] as String? ?? '',
    );
  }
}
