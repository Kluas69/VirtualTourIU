import 'dart:async';
import 'package:flutter/material.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';

class TabletHomeScreen extends StatefulWidget {
  const TabletHomeScreen({super.key});

  @override
  State<TabletHomeScreen> createState() => _TabletHomeScreenState();
}

class _TabletHomeScreenState extends State<TabletHomeScreen> {
  final PageController _controller = PageController(viewportFraction: 0.5);
  int _tappedIndex = -1;
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          HomeScreen.buildHeroSection(
            context,
            fontSize: size.width * 0.06,
            heightFactor: 0.4,
          ),
          // Info Section
          HomeScreen.buildInfoSection(context, isMobile: false),
          // Card Carousel
          HomeScreen.buildCarousel(
            context,
            cardHeight: size.height * 0.3,
            controller: _controller,
            tappedIndex: _tappedIndex,
            isInteracting: _isInteracting,
            onTap:
                (index) => setState(() {
                  _tappedIndex = _tappedIndex == index ? -1 : index;
                  _isInteracting = false;
                }),
            setInteracting: (value) => setState(() => _isInteracting = value),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
