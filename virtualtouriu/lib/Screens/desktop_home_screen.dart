import 'dart:async';
import 'package:flutter/material.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  PageController? _controller;
  int _selectedIndex = -1;
  Timer? _shuffleTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _startShuffleTimer();
  }

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
        // Responsive dimensions for desktop
        final heroHeight = (size.height * 0.45).clamp(400.0, 650.0);
        final paddingHorizontal = (size.width * 0.07).clamp(20.0, 33.0);
        final paddingVertical = (size.height * 0.05).clamp(24.0, 48.0);
        final fontSize = (size.width * 0.05).clamp(26.0, 50.0);
        final cardHeight = (size.height * 0.33).clamp(300.0, 1200.0);
        final viewportFraction =
            constraints.maxWidth > 1800
                ? 0.25
                : constraints.maxWidth > 1400
                ? 0.35
                : constraints.maxWidth > 1000
                ? 0.4
                : 0.45;

        _controller?.dispose();
        _controller = PageController(
          viewportFraction: viewportFraction,
          initialPage: 0,
        );

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: HomeScreen.buildHeroSection(
                  context: context,
                  fontSize: fontSize,
                  heightFactor: 1.0,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
                width: double.infinity,
                child: HomeScreen.buildInfoSection(
                  context: context,
                  isMobile: false,
                ),
              ),
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
                  isDesktop: true,
                ),
              ),
              SizedBox(height: paddingVertical * 2),
            ],
          ),
        );
      },
    );
  }
}
