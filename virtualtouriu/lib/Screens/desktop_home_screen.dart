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
  int _hoveredIndex = -1;
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
        final heroHeight = (size.height * 0.4).clamp(300.0, 500.0);
        final paddingHorizontal = (size.width * 0.05).clamp(16.0, 64.0);
        final paddingVertical = (size.height * 0.03).clamp(16.0, 32.0);
        final fontSize = (size.width * 0.05).clamp(20.0, 50.0);
        final cardHeight = (size.height * 0.35).clamp(200.0, 600.0);
        final infoMaxWidth =
            constraints.maxWidth > 1200 ? 800.0 : constraints.maxWidth * 0.9;
        final viewportFraction =
            constraints.maxWidth > 1200
                ? 0.40
                : constraints.maxWidth > 800
                ? 0.45
                : 0.50;

        _controller?.dispose();
        _controller = PageController(viewportFraction: viewportFraction);

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: HomeScreen.buildHeroSection(
                  context,
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
                constraints: BoxConstraints(maxWidth: infoMaxWidth),
                child: HomeScreen.buildInfoSection(context, isMobile: false),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: paddingVertical,
                ),
                width: double.infinity,
                child: HomeScreen.buildCarousel(
                  context,
                  cardHeight: cardHeight,
                  controller: _controller!,
                  tappedIndex: _hoveredIndex,
                  isInteracting: _isInteracting,
                  onTap:
                      (index) => setState(() {
                        _hoveredIndex = _hoveredIndex == index ? -1 : index;
                        _isInteracting = false;
                      }),
                  setInteracting:
                      (value) => setState(() => _isInteracting = value),
                  onPageChanged:
                      (index) => setState(() {
                        _hoveredIndex = index;
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
