import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  late PageController _controller;
  int _selectedIndex = 0;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    final middleIndex = AppConstants.locationCards.length ~/ 2;

    _controller = PageController(
      viewportFraction: 0.85,
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

        final double heroHeight = size.height * 0.70;
        final double cardHeight = size.height * 0.55;

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
                  // Hero Section
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      height: heroHeight,
                      width: double.infinity,
                      child: HomeScreen.buildHeroSection(
                        context: context,
                        fontSize: size.width * 0.12,
                        heightFactor: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Info Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: HomeScreen.buildInfoSection(
                      context: context,
                      isMobile: true,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),

                  // Carousel Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: cardHeight,
                            child: HomeScreen.buildCarousel(
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
                          SizedBox(height: 24),
                          SmoothPageIndicator(
                            controller: _controller,
                            count: AppConstants.locationCards.length,
                            effect: ExpandingDotsEffect(
                              dotWidth: 10,
                              dotHeight: 10,
                              spacing: 8,
                              activeDotColor: Theme.of(context).primaryColor,
                              dotColor: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.12),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
