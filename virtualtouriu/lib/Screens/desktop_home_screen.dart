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
  final PageController _controller = PageController(viewportFraction: 0.3);
  int _hoveredIndex = -1;
  Timer? _shuffleTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _startShuffleTimer();
  }

  void _startShuffleTimer() {
    _shuffleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isInteracting) {
        setState(() => locationCards.shuffle());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
              child: HomeScreen.buildHeroSection(
                context,
                fontSize: size.width * 0.05,
                heightFactor: 1.0,
              ),
            ),
            Expanded(
              child: HomeScreen.buildInfoSection(context, isMobile: false),
            ),
          ],
        ),
        Positioned(
          bottom: size.height * 0.05,
          left: size.width * 0.05,
          right: size.width * 0.05,
          child: HomeScreen.buildCarousel(
            context,
            cardHeight: size.height * 0.25,
            controller: _controller,
            tappedIndex: _hoveredIndex,
            isInteracting: _isInteracting,
            onTap:
                (index) => setState(() {
                  _hoveredIndex = _hoveredIndex == index ? -1 : index;
                  _isInteracting = false;
                }),
            setInteracting: (value) => setState(() => _isInteracting = value),
            isDesktop: true,
          ),
        ),
      ],
    );
  }
}
