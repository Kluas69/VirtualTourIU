import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  late PageController _controller;
  int _selectedIndex = 0;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    final middleIndex = AppConstants.locationCards.length ~/ 2;

    // Professional viewport fractions for desktop - shows 3-4 cards perfectly
    final double width =
        WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;

    final double viewportFraction;
    if (width > 2000) {
      viewportFraction = 0.26; // Ultra-wide: ~4 cards visible
    } else if (width > 1600) {
      viewportFraction = 0.30; // Wide: ~3.5 cards
    } else if (width > 1200) {
      viewportFraction = 0.34; // Standard desktop: ~3 cards
    } else {
      viewportFraction = 0.38; // Smaller desktop: ~2.5 cards
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

        // PROFESSIONAL GOLDEN RATIOS FOR DESKTOP
        final double heroHeight = (size.height * 0.52).clamp(500.0, 650.0);

        // Ideal card height: 16:9 aspect ratio, perfect for desktop galleries
        final double idealCardHeight = (size.width * 0.20).clamp(420.0, 520.0);
        final double cardSectionPadding = size.width * 0.04;

        return Stack(
          children: [
            // Background blur
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
                  // Hero Section - Professional proportions
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      height: heroHeight,
                      width: double.infinity,
                      child: HomeScreen.buildHeroSection(
                        context: context,
                        fontSize: (size.width * 0.06).clamp(42.0, 64.0),
                        heightFactor: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Info Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: HomeScreen.buildInfoSection(
                        context: context,
                        isMobile: false,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),

                  // CAROUSEL SECTION - PROFESSIONAL DESKTOP SIZING
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardSectionPadding,
                        vertical: size.height * 0.03,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 1600,
                      ), // Max width for ultra-wide screens
                      child: Column(
                        children: [
                          // Cards container with perfect spacing
                          SizedBox(
                            height:
                                idealCardHeight + 40, // Extra space for shadows
                            child: HomeScreen.buildCarousel(
                              context: context,
                              cardHeight: idealCardHeight,
                              controller: _controller,
                              selectedIndex: _selectedIndex,
                              isInteracting: _isInteracting,
                              onPageChanged:
                                  (index) =>
                                      setState(() => _selectedIndex = index),
                              isDesktop: true,
                              onTap: (index) {},
                              setInteracting: (value) {},
                            ),
                          ),
                          SizedBox(height: 24),
                          // Professional indicator
                          SmoothPageIndicator(
                            controller: _controller,
                            count: AppConstants.locationCards.length,
                            effect: WormEffect(
                              dotWidth: 12,
                              dotHeight: 12,
                              spacing: 8,
                              // activeDotColor: theme.primaryColor,
                              dotColor: Colors.grey.shade400,
                              paintStyle: PaintingStyle.fill,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
