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
    if (width > 2000) {
      viewportFraction = 0.26;
    } else if (width > 1600) {
      viewportFraction = 0.30;
    } else if (width > 1200) {
      viewportFraction = 0.34;
    } else {
      viewportFraction = 0.38;
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

        final double heroHeight = (size.height * 0.52).clamp(500.0, 650.0);
        final double idealCardHeight = (size.width * 0.20).clamp(420.0, 520.0);
        final double cardSectionPadding = size.width * 0.04;

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
                        fontSize: (size.width * 0.06).clamp(42.0, 64.0),
                        heightFactor: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),

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

                  // Enhanced carousel with navigation arrows
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardSectionPadding,
                        vertical: size.height * 0.03,
                      ),
                      constraints: const BoxConstraints(maxWidth: 1600),
                      child: Column(
                        children: [
                          // Navigation arrows + carousel
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cards
                              SizedBox(
                                height: idealCardHeight + 40,
                                child: HomeScreen.buildCarousel(
                                  context: context,
                                  cardHeight: idealCardHeight,
                                  controller: _controller,
                                  selectedIndex: _selectedIndex,
                                  isInteracting: _isInteracting,
                                  onPageChanged:
                                      (index) => setState(
                                        () => _selectedIndex = index,
                                      ),
                                  isDesktop: true,
                                  onTap: (index) {},
                                  setInteracting: (value) {},
                                ),
                              ),

                              // Left arrow
                              if (_showLeftArrow)
                                Positioned(
                                  left: -20,
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
                                  right: -20,
                                  child: _buildNavigationArrow(
                                    icon: Icons.arrow_forward_ios_rounded,
                                    onPressed: () => _navigateToPage(1),
                                    isDark: isDark,
                                    theme: theme,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Page indicator
                          SmoothPageIndicator(
                            controller: _controller,
                            count: AppConstants.locationCards.length,
                            effect: WormEffect(
                              dotWidth: 10,
                              dotHeight: 10,
                              spacing: 12,
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
                              horizontal: 16,
                              vertical: 8,
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
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
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isDark ? Colors.white : theme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
