import 'dart:async';
import 'package:flutter/material.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';

// Mobile-specific home screen widget
class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  PageController? _controller;
  int _selectedIndex = -1;
  Timer? _shuffleTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _startShuffleTimer();
  }

  // Starts a timer to shuffle location cards every 3 seconds to match desktop
  void _startShuffleTimer() {
    _shuffleTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_isInteracting && mounted) {
        setState(() => locationCards.shuffle());
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        // Responsive dimensions for mobile
        final heroHeight = (size.height * 0.45).clamp(400.0, 650.0);
        final paddingHorizontal = (size.width * 0.08).clamp(32.0, 100.0);
        final paddingVertical = (size.height * 0.05).clamp(24.0, 48.0);
        final fontSize = (size.width * 0.05).clamp(26.0, 50.0);
        final cardHeight = (size.height * 0.20).clamp(240.0, 1000.0);
        final infoMaxWidth =
            constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth * 0.9;
        final viewportFraction =
            constraints.maxWidth > 1800
                ? 0.3
                : constraints.maxWidth > 1400
                ? 0.35
                : constraints.maxWidth > 1000
                ? 0.4
                : 0.45;

        // Initialize PageController with responsive viewport fraction
        _controller?.dispose();
        _controller = PageController(
          viewportFraction: viewportFraction,
          initialPage: 0,
        );

        return SingleChildScrollView(
          child: Column(
            children: [
              // Hero section with university branding
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: HomeScreen.buildHeroSection(
                  context: context,
                  fontSize: fontSize,
                  heightFactor: 1.0,
                ),
              ),
              // Info section with tour description and start button
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: infoMaxWidth),
                child: HomeScreen.buildInfoSection(
                  context: context,
                  isMobile: false, // Match desktop behavior
                ),
              ),
              // Carousel section for location cards
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
                width: double.infinity,
                child: HomeScreen.buildCarousel(
                  context: context,
                  cardHeight: cardHeight,
                  controller: _controller!,
                  selectedIndex: _selectedIndex,
                  isInteracting: _isInteracting,
                  onTap:
                      (index) => setState(() {
                        _selectedIndex = _selectedIndex == index ? -1 : index;
                        _isInteracting = false;
                      }),
                  setInteracting:
                      (value) => setState(() => _isInteracting = value),
                  onPageChanged:
                      (index) => setState(() {
                        _selectedIndex = index;
                        _isInteracting = false;
                      }),
                  isDesktop: true, // Match desktop behavior
                ),
              ),
              SizedBox(height: paddingVertical * 2), // Bottom spacing
            ],
          ),
        );
      },
    );
  }
}
