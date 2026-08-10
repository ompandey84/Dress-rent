import 'dart:io';

/// A draft listing being created step-by-step by a lender.
class ListingDraft {
  // Step 1: Media
  final List<File> photos = [];
  File? video;

  // Step 2: Item details
  String title = '';
  String description = '';
  String category = 'Casual'; // Casual, Ethnic, Formal, Party, Bridal, Sports
  String gender = 'Women';   // Women, Men, Unisex
  String occasion = 'Casual'; // Casual, Wedding, Party, Festive, Cocktail, Bridal
  String condition = 'Like New'; // New, Like New, Good, Fair
  Set<String> sizes = {}; // XS, S, M, L, XL, XXL, Free Size
  String color = '';
  String fabric = '';

  // Step 3: Pricing
  double pricePerDay = 0;
  double securityDeposit = 0;
  double? insuranceFee;
  int minDays = 1;
  int maxDays = 14;

  // Step 4: Pickup
  String pickupAddressLine1 = '';
  String? pickupAddressLine2;
  String pickupCity = '';
  String pickupState = '';
  String pickupPincode = '';
  String? landmark;
  String pickupMethod = 'both'; // self, rider, both

  bool isValidStep1() => photos.isNotEmpty;
  bool isValidStep2() =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      sizes.isNotEmpty &&
      color.trim().isNotEmpty;
  bool isValidStep3() => pricePerDay > 0 && securityDeposit >= 0 && minDays >= 1;
  bool isValidStep4() =>
      pickupAddressLine1.trim().isNotEmpty &&
      pickupCity.trim().isNotEmpty &&
      pickupPincode.trim().length >= 5;
}

/// Admin approval status for a listing.
enum ListingStatus {
  draft,
  pendingReview,
  approved,
  rejected,
  suspended,
}

extension ListingStatusX on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.draft: return 'Draft';
      case ListingStatus.pendingReview: return 'Under review';
      case ListingStatus.approved: return 'Live';
      case ListingStatus.rejected: return 'Rejected';
      case ListingStatus.suspended: return 'Suspended';
    }
  }
}
