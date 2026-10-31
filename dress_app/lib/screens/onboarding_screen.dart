import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/screens/login_screen.dart';
import 'package:dress_app/screens/main_navigation.dart';
import 'package:dress_app/services/app_state.dart';
import 'package:dress_app/services/supabase_service.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'RENT PREMIUM\nFASHION AT\nA FRACTION',
      'subtitle': 'A smarter rental marketplace for India —\nfast, trusted, and made for your lifestyle.',
      'image': 'assets/images/gfvghj.png',
    },
    {
      'title': 'WEAR LUXURY\nBRANDS FOR\nLESS',
      'subtitle': 'Access a curated wardrobe of high-end fashion\nwithout the commitment of buying.',
      'image': 'assets/images/gfvghj.png',
    },
    {
      'title': 'EARN FROM\nYOUR CLOSET\nEASILY',
      'subtitle': 'Become a lender and turn your unused\npremium outfits into a new income stream.',
      'image': 'assets/images/gfvghj.png',
    },
  ];

  void _navigateToNext(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF5CA8B5),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: size.height * 0.6,
                    child: Image.asset(
                      _onboardingData[index]['image']!,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: size.height * 0.6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF5CA8B5),
                            const Color(0xFF5CA8B5).withOpacity(0.0),
                            Colors.black.withOpacity(0.4),
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToNext(context),
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _onboardingData[_currentIndex]['title']!,
                    key: ValueKey<String>(_onboardingData[_currentIndex]['title']!),
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _onboardingData[_currentIndex]['subtitle']!,
                    key: ValueKey<String>(_onboardingData[_currentIndex]['subtitle']!),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned(
                          right: 20,
                          bottom: 40,
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Text(
                              'TRENDING',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          bottom: 80,
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Text(
                              'FIND FASHION',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex == _onboardingData.length - 1) {
                          _navigateToNext(context);
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentIndex == _onboardingData.length - 1 ? 'GET STARTED' : 'NEXT',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
