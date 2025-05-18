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

  // Starts a timer to shuffle location cards every 5 seconds
  void _startShuffleTimer() {
    _shuffleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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
        final heroHeight = (size.height * 0.35).clamp(250.0, 400.0);
        final paddingHorizontal = (size.width * 0.05).clamp(8.0, 32.0);
        final paddingVertical = (size.height * 0.03).clamp(8.0, 24.0);
        final fontSize = (size.width * 0.07).clamp(16.0, 40.0);
        final cardHeight = (size.height * 0.25).clamp(150.0, 250.0);
        final infoMaxWidth =
            constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth * 0.9;
        final viewportFraction =
            constraints.maxWidth > 600
                ? 0.55
                : constraints.maxWidth > 400
                ? 0.65
                : 0.75;

        // Initialize PageController with responsive viewport fraction
        _controller?.dispose();
        _controller = PageController(viewportFraction: viewportFraction);

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
                  isMobile: true,
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
