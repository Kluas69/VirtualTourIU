import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

class TabletHomeScreen extends StatefulWidget {
  const TabletHomeScreen({super.key});

  @override
  State<TabletHomeScreen> createState() => _TabletHomeScreenState();
}

class _TabletHomeScreenState extends State<TabletHomeScreen> {
  PageController? _controller;
  int _selectedIndex = -1;
  Timer? _shuffleTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewportFraction = _computeViewportFraction(
        MediaQuery.of(context).size.width,
      );
      final middleIndex =
          locationCards.isNotEmpty ? locationCards.length ~/ 2 : 0;
      if (mounted) {
        setState(() {
          _controller = PageController(
            viewportFraction: viewportFraction,
            initialPage: middleIndex,
          );
          _selectedIndex = middleIndex;
        });
      }
    });
    _startShuffleTimer();
  }

  double _computeViewportFraction(double width) {
    if (width > 1800) return 0.3;
    if (width > 1400) return 0.35;
    if (width > 1000) return 0.4;
    return 0.45;
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
        final heroHeight = (size.height * 0.45).clamp(400.0, 650.0);
        final paddingHorizontal = (size.width * 0.08).clamp(20.0, 33.0);
        final paddingVertical = (size.height * 0.05).clamp(24.0, 48.0);
        final fontSize = (size.width * 0.05).clamp(26.0, 50.0);
        final cardHeight = (size.height * 0.25).clamp(300.0, 750.0);
        final infoMaxWidth =
            constraints.maxWidth > 1000 ? 800.0 : constraints.maxWidth * 0.9;

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
                            heightFactor: 1.0,
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
                            isMobile: false,
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
                            onTap: (index) {
                              setState(() {
                                _selectedIndex = index;
                                _isInteracting = false;
                              });
                            },
                            setInteracting:
                                (value) =>
                                    setState(() => _isInteracting = value),
                            onPageChanged:
                                (index) => setState(() {
                                  _selectedIndex = index;
                                  _isInteracting = false;
                                }),
                            isDesktop: true,
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
