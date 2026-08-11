/// Centralized form validators used across signup, profile, vendor signup,
/// and KYC screens. Keeping these in one place avoids inconsistent rules
/// (e.g. one screen accepts "abc@x" while another rejects it).
class Validators {
  /// Email regex — requires at least one char, @, domain, dot, TLD.
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  /// Indian mobile number: starts with 6/7/8/9, total 10 digits.
  /// Allows optional +91 or 0 prefix.
  static final _phoneRegex = RegExp(r'^(?:\+?91|0)?[6-9]\d{9}$');

  /// IFSC code: 4 letters + 0 + 6 alphanumeric characters.
  static final _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// UPI ID: alphanumeric + dot/underscore/dash, @, then alphanumeric.
  static final _upiRegex = RegExp(r'^[a-zA-Z0-9._-]{3,}@[a-zA-Z][a-zA-Z0-9]{2,}$');

  /// 6+ digit Indian PIN code.
  static final _pincodeRegex = RegExp(r'^\d{6}$');

  /// 9-18 digit account number.
  static final _accountRegex = RegExp(r'^\d{9,18}$');

  static String? email(String? v, {bool optional = false}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return optional ? null : 'Enter your email';
    if (!_emailRegex.hasMatch(s)) return 'Enter a valid email';
    return null;
  }

  static String? phone(String? v, {bool optional = false}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return optional ? null : 'Enter phone number';
    if (!_phoneRegex.hasMatch(s)) return 'Enter a valid 10-digit mobile number';
    return null;
  }

  static String? name(String? v, {String label = 'Name', int minLen = 2}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter $label';
    if (s.length < minLen) return '$label must be at least $minLen characters';
    return null;
  }

  static String? password(String? v, {int minLen = 6}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter a password';
    if (s.length < minLen) return 'Password must be at least $minLen characters';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Confirm your password';
    if (s != original.trim()) return 'Passwords do not match';
    return null;
  }

  static String? ifsc(String? v, {bool optional = false}) {
    final s = (v ?? '').trim().toUpperCase();
    if (s.isEmpty) return optional ? null : 'Enter IFSC code';
    if (!_ifscRegex.hasMatch(s)) return 'IFSC must be 4 letters + 0 + 6 chars';
    return null;
  }

  static String? upi(String? v, {bool optional = true}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return optional ? null : 'Enter UPI ID';
    if (!_upiRegex.hasMatch(s)) return 'UPI looks invalid (e.g. name@bank)';
    return null;
  }

  static String? pincode(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter pincode';
    if (!_pincodeRegex.hasMatch(s)) return 'Enter a valid 6-digit pincode';
    return null;
  }

  static String? accountNumber(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter account number';
    if (!_accountRegex.hasMatch(s)) {
      return 'Account number must be 9-18 digits';
    }
    return null;
  }

  static String? required(String? v, {String label = 'This field'}) {
    if ((v ?? '').trim().isEmpty) return '$label is required';
    return null;
  }

  /// Date can't be in the past (for booking-style flows).
  static String? futureDate(DateTime? d) {
    if (d == null) return 'Pick a date';
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    if (d.isBefore(t)) return 'Date can\'t be in the past';
    return null;
  }
}
