import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart'; // ← FIXED
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

import 'HomeScreen.dart' as home_screen;
import 'homeScreen.dart' as home_screen;

class TabletHomeScreen extends StatefulWidget {
  const TabletHomeScreen({super.key});

  @override
  State<TabletHomeScreen> createState() => _TabletHomeScreenState();
}

class _TabletHomeScreenState extends State<TabletHomeScreen> {
  late PageController _controller;
  int _selectedIndex = 0;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    final middleIndex = AppConstants.locationCards.length ~/ 2;

    // Professional tablet viewport - shows 2-2.5 cards with elegant spacing
    final double width =
        WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;

    final double viewportFraction;
    if (width > 1100) {
      viewportFraction = 0.38; // Larger tablets: ~2.6 cards
    } else if (width > 900) {
      viewportFraction = 0.42; // Standard tablets: ~2.4 cards
    } else {
      viewportFraction = 0.46; // Smaller tablets: ~2.2 cards
    }

    _controller = PageController(
      viewportFraction: viewportFraction,
      initialPage: middleIndex,
    );
    _selectedIndex = middleIndex;

    _controller.addListener(() {
      if (_controller.hasClients) {
        final newIndex = _controller.page?.round() ?? middleIndex;
        if (newIndex != _selectedIndex) {
          setState(() {
            _selectedIndex = newIndex;
            _isInteracting = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final size = MediaQuery.of(context).size;

    return FutureBuilder<void>(
      future: AppConstants.initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // Professional tablet proportions
        final double heroHeight = (size.height * 0.55).clamp(480.0, 620.0);
        // Golden ratio card sizing for tablets (optimized 16:9 aspect)
        final double cardHeight = (size.width * 0.28).clamp(440.0, 520.0);
        final double cardSectionPadding = size.width * 0.06;

        return Stack(
          children: [
            // Premium background blur
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
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isDark ? 8.0 : 5.0,
                    sigmaY: isDark ? 8.0 : 5.0,
                  ),
                  child: Container(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Hero Section - Tablet optimized proportions
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      height: heroHeight,
                      width: double.infinity,
                      child: home_screen.HomeScreen.buildHeroSection(
                        context: context,
                        fontSize: (size.width * 0.065).clamp(38.0, 56.0),
                        heightFactor: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.045),

                  // Animated Statistics Section
                  home_screen.AnimatedStatsSection(
                    isDark: isDark,
                    isMobile: false,
                  ),

                  SizedBox(height: size.height * 0.045),

                  // Info Section - Balanced padding
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: home_screen.HomeScreen.buildInfoSection(
                        context: context,
                        isMobile: false,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.045),

                  // Quick Action Cards
                  home_screen.QuickActionCardsSection(
                    isDark: isDark,
                    isMobile: false,
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Featured Section Header
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FEATURED LOCATIONS',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.5,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Discover Our Campus',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34,
                                ),
                              ),
                            ],
                          ),
                          // Navigation hint
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Premium Carousel Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardSectionPadding,
                        vertical: size.height * 0.02,
                      ),
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        children: [
                          // Professional card gallery
                          SizedBox(
                            height: cardHeight + 40,
                            child: home_screen.HomeScreen.buildCarousel(
                              context: context,
                              cardHeight: cardHeight,
                              controller: _controller,
                              selectedIndex: _selectedIndex,
                              isInteracting: _isInteracting,
                              onPageChanged:
                                  (index) =>
                                      setState(() => _selectedIndex = index),
                              isDesktop: false,
                              onTap: (index) {},
                              setInteracting: (value) {},
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Elegant page indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SmoothPageIndicator(
                                controller: _controller,
                                count: AppConstants.locationCards.length,
                                effect: WormEffect(
                                  dotWidth: 10,
                                  dotHeight: 10,
                                  spacing: 20,
                                  activeDotColor:
                                      Theme.of(context).primaryColor,
                                  dotColor:
                                      isDark
                                          ? Colors.grey.shade700
                                          : Colors.grey.shade300,
                                  paintStyle: PaintingStyle.fill,
                                ),
                              ),
                            ],
                          ),

                          // Card counter
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Text(
                              '${_selectedIndex + 1} / ${AppConstants.locationCards.length}',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Why Choose IQRA Section
                  home_screen.WhyChooseSection(isDark: isDark, isMobile: false),

                  SizedBox(height: size.height * 0.05),

                  // News & Events Section
                  home_screen.NewsEventsSection(
                    isDark: isDark,
                    isMobile: false,
                  ),

                  SizedBox(height: size.height * 0.1),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
