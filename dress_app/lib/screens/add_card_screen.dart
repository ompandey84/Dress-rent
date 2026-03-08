import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/widgets/custom_text_field.dart';
import 'package:dress_app/screens/order_success_screen.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    text = text.replaceAll(RegExp(r'\s'), '');
    var newString = '';
    for (int i = 0; i < text.length; i++) {
      newString += text[i];
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        newString += ' ';
      }
    }
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  bool _saveCard = true;

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PAYMENT METHOD',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visual Credit Card Map
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C222B), Color(0xFF2E3A4A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1C222B).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(FluentIcons.payment_24_regular, color: Colors.white, size: 32),
                            Text(
                              'VISA',
                              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                        Text(
                          _cardController.text.isNotEmpty ? _cardController.text : '•••• •••• •••• ••••',
                          style: GoogleFonts.spaceMono(fontSize: 22, color: Colors.white, letterSpacing: 2.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Card Holder', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(
                                  _nameController.text.isNotEmpty ? _nameController.text.toUpperCase() : 'JOHN DOE',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Expires', style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(
                                  _expiryController.text.isNotEmpty ? _expiryController.text : 'MM/YY',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Inputs
                  Text('Card Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Cardholder Name',
                    hintText: 'Enter name on card',
                    controller: _nameController,
                    onChanged: (v) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter cardholder name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  CustomTextField(
                    label: 'Card Number',
                    hintText: '0000 0000 0000 0000',
                    controller: _cardController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CardNumberFormatter(),
                      LengthLimitingTextInputFormatter(19),
                    ],
                    onChanged: (v) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter card number';
                      if (val.length < 19) return 'Invalid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Expiry Date',
                          hintText: 'MM/YY',
                          controller: _expiryController,
                          keyboardType: TextInputType.datetime,
                          onChanged: (v) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          label: 'CVV',
                          hintText: '123',
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          isPassword: true,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required';
                            if (val.length < 3) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Card
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _saveCard,
                          onChanged: (val) {
                            setState(() {
                              _saveCard = val ?? true;
                            });
                          },
                          activeColor: AppTheme.primaryLime,
                          checkColor: AppTheme.textDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          side: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Save card for future payments',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Floating Bottom Continue Button
          Positioned(
            bottom: 15,
            left: 24,
            right: 24,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryLime,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryLime.withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15),
                ],
              ),
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: Center(
                  child: Text(
                    'PAY SECURELY',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
