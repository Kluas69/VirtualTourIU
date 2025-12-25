import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  late PageController _controller;
  int _selectedIndex = 0;
  bool _isInteracting = false;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    final middleIndex = AppConstants.locationCards.length ~/ 2;

    final double width =
        WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;

    final double viewportFraction;
    if (width > 1100) {
      viewportFraction = 0.38;
    } else if (width > 900) {
      viewportFraction = 0.42;
    } else {
      viewportFraction = 0.46;
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
            _updateArrowVisibility();
          });
        }
      }
    });

    _updateArrowVisibility();
  }

  void _updateArrowVisibility() {
    setState(() {
      _showLeftArrow = _selectedIndex > 0;
      _showRightArrow = _selectedIndex < AppConstants.locationCards.length - 1;
    });
  }

  void _navigateToPage(int delta) {
    final newIndex = (_selectedIndex + delta).clamp(
      0,
      AppConstants.locationCards.length - 1,
    );
    _controller.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
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
    final theme = Theme.of(context);
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

        final double heroHeight = (size.height * 0.55).clamp(480.0, 620.0);
        final double cardHeight = (size.width * 0.28).clamp(440.0, 520.0);
        final double cardSectionPadding = size.width * 0.06;

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
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox(
                      height: heroHeight,
                      width: double.infinity,
                      child: HomeScreen.buildHeroSection(
                        context: context,
                        fontSize: (size.width * 0.065).clamp(38.0, 56.0),
                        heightFactor: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.045),

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
                  SizedBox(height: size.height * 0.05),

                  // Section header
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FEATURED LOCATIONS',
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.5,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Discover Our Campus',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

                  // Enhanced carousel with navigation
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
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: cardHeight + 40,
                                child: HomeScreen.buildCarousel(
                                  context: context,
                                  cardHeight: cardHeight,
                                  controller: _controller,
                                  selectedIndex: _selectedIndex,
                                  isInteracting: _isInteracting,
                                  onPageChanged:
                                      (index) => setState(
                                        () => _selectedIndex = index,
                                      ),
                                  isDesktop: false,
                                  onTap: (index) {},
                                  setInteracting: (value) {},
                                ),
                              ),

                              // Left arrow
                              if (_showLeftArrow)
                                Positioned(
                                  left: -16,
                                  child: _buildNavigationArrow(
                                    icon: Icons.arrow_back_ios_new_rounded,
                                    onPressed: () => _navigateToPage(-1),
                                    isDark: isDark,
                                    theme: theme,
                                  ),
                                ),

                              // Right arrow
                              if (_showRightArrow)
                                Positioned(
                                  right: -16,
                                  child: _buildNavigationArrow(
                                    icon: Icons.arrow_forward_ios_rounded,
                                    onPressed: () => _navigateToPage(1),
                                    isDark: isDark,
                                    theme: theme,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Page indicator
                          SmoothPageIndicator(
                            controller: _controller,
                            count: AppConstants.locationCards.length,
                            effect: WormEffect(
                              dotWidth: 9,
                              dotHeight: 9,
                              spacing: 10,
                              activeDotColor: theme.primaryColor,
                              dotColor:
                                  isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade400,
                              paintStyle: PaintingStyle.fill,
                            ),
                          ),

                          // Card counter
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.06),
                              ),
                            ),
                            child: Text(
                              '${_selectedIndex + 1} / ${AppConstants.locationCards.length}',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
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

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.95),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.08),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isDark ? Colors.white : theme.primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}
