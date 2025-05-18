import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final middleIndex =
          locationCards.isNotEmpty ? locationCards.length ~/ 2 : 0;
      if (mounted) {
        setState(() {
          _controller = PageController(
            viewportFraction: 0.55,
            initialPage: middleIndex,
          );
          _selectedIndex = middleIndex;
        });
      }
    });
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
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final heroHeight = (size.height * 0.35).clamp(200.0, 400.0);
        final paddingHorizontal = (size.width * 0.08).clamp(16.0, 24.0);
        final paddingVertical = (size.height * 0.05).clamp(16.0, 24.0);
        final fontSize = (size.width * 0.05).clamp(20.0, 28.0);
        final cardHeight = (size.height * 0.38).clamp(100.0, 250.0);
        final infoMaxWidth = constraints.maxWidth * 0.9;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? Colors.black.withOpacity(0.1)
                        : Colors.grey.shade100,
                    isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                  ],
                ),
              ),
            ),
            _controller == null
                ? FadeIn(
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: SizedBox(
                          height: heroHeight,
                          width: double.infinity,
                          child: HomeScreen.buildHeroSection(
                            context: context,
                            fontSize: fontSize,
                            heightFactor: 0.6,
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 100),
                        child: Container(
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
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
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
                                  _selectedIndex =
                                      _selectedIndex == index ? -1 : index;
                                  _isInteracting = false;
                                }),
                            setInteracting:
                                (value) =>
                                    setState(() => _isInteracting = value),
                            onPageChanged:
                                (index) => setState(() {
                                  _selectedIndex = index;
                                  _isInteracting = false;
                                }),
                            isDesktop: false,
                          ),
                        ),
                      ),
                      SizedBox(height: paddingVertical * 2),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}
