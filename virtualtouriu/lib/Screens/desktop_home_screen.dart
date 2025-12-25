import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/core/widgets/chatbot_widget.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

class DesktopHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const DesktopHomeScreen({super.key, this.scrollController});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  late PageController _controller;
  late ScrollController _scrollController;
  int _selectedIndex = 0;
  bool _isInteracting = false;
  bool _showLeftArrow = false;
  bool _showRightArrow = true;
  bool _isHeaderVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_handleScroll);
    _initializeController();
  }

  void _handleScroll() {
    final currentScrollPosition = _scrollController.offset;

    if (currentScrollPosition > _lastScrollPosition &&
        currentScrollPosition > 100) {
      if (_isHeaderVisible) {
        setState(() => _isHeaderVisible = false);
      }
    } else if (currentScrollPosition < _lastScrollPosition) {
      if (!_isHeaderVisible) {
        setState(() => _isHeaderVisible = true);
      }
    }

    _lastScrollPosition = currentScrollPosition;
  }

  void _initializeController() {
    final middleIndex = AppConstants.locationCards.length ~/ 2;
    final width =
        WidgetsBinding.instance.window.physicalSize.width /
        WidgetsBinding.instance.window.devicePixelRatio;

    final viewportFraction = _calculateViewportFraction(width);

    _controller = PageController(
      viewportFraction: viewportFraction,
      initialPage: middleIndex,
    );
    _selectedIndex = middleIndex;

    _controller.addListener(_onPageScroll);
    _updateArrowVisibility();
  }

  double _calculateViewportFraction(double width) {
    if (width > 2000) return 0.26;
    if (width > 1600) return 0.30;
    if (width > 1200) return 0.34;
    return 0.38;
  }

  void _onPageScroll() {
    if (!_controller.hasClients) return;

    final newIndex = _controller.page?.round() ?? _selectedIndex;
    if (newIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = newIndex;
        _isInteracting = true;
        _updateArrowVisibility();
      });
    }
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

  // Navigation handler for chatbot - NAVIGATE TO DETAIL SCREEN
  void _handleChatbotNavigation(String location) {
    print('=== DESKTOP HANDLER ===');
    print('📍 Received: "$location"');

    final normalizedLocation = location.toLowerCase().trim();

    final locationMappings = {
      'library': ['library', 'lib', 'book', 'study', 'reading'],
      'play area': [
        'play area',
        'play ground',
        'playground',
        'field',
        'sports ground',
        'ground',
      ],
      'auditorium': [
        'auditorium',
        'hall',
        'assembly hall',
        'theater',
        'theatre',
      ],
      'class rooms': [
        'classroom',
        'class room',
        'class rooms',
        'class',
        'lecture hall',
        'lecture room',
        'classes',
      ],
      'amphitheater': [
        'amphitheater',
        'amphitheatre',
        'outdoor theater',
        'open air',
      ],
      'cafeteria': [
        'cafeteria',
        'cafe',
        'canteen',
        'food court',
        'dining',
        'restaurant',
      ],
      'common room': [
        'common room',
        'commonroom',
        'lounge',
        'student lounge',
        'recreation',
      ],
      'playground': ['playground', 'play ground', 'sports', 'outdoor sports'],
      'swimming pool': ['swimming pool', 'pool', 'swimming', 'swim'],
      'webinar room': [
        'webinar room',
        'webinar',
        'virtual room',
        'online class',
        'meeting room',
      ],
    };

    int locationIndex = -1;

    locationIndex = AppConstants.locationCards.indexWhere(
      (card) => card.title.toLowerCase().trim() == normalizedLocation,
    );

    if (locationIndex == -1) {
      locationIndex = AppConstants.locationCards.indexWhere(
        (card) =>
            card.title.toLowerCase().contains(normalizedLocation) ||
            normalizedLocation.contains(card.title.toLowerCase()),
      );
    }

    if (locationIndex == -1) {
      for (var entry in locationMappings.entries) {
        if (entry.value.any(
          (term) =>
              normalizedLocation.contains(term) ||
              term.contains(normalizedLocation),
        )) {
          locationIndex = AppConstants.locationCards.indexWhere(
            (card) => card.title.toLowerCase().trim() == entry.key,
          );
          if (locationIndex != -1) break;
        }
      }
    }

    if (locationIndex != -1) {
      final locationData = AppConstants.locationCards[locationIndex];
      print('✅ Found: ${locationData.title}');
      print('🚀 Navigating to detail screen...');

      // Navigate to LocationDetailScreen
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => LocationDetailScreen(
                locationName: locationData.title,
                imagePath: locationData.imagePath,
                locationData: locationData,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Opening ${locationData.title}')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      print('❌ Not found');
      final availableLocations = AppConstants.locationCards
          .map((card) => card.title)
          .take(5)
          .join(', ');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Location "$location" not found')),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Try: $availableLocations...',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageScroll);
    _controller.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
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

        final heroHeight = (size.height * 0.52).clamp(500.0, 650.0);
        final idealCardHeight = (size.width * 0.20).clamp(420.0, 520.0);

        return Stack(
          children: [
            _buildBackground(isDark),
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildHeroSection(context, size, heroHeight),
                  SizedBox(height: size.height * 0.04),
                  _buildInfoSection(context, size),
                  SizedBox(height: size.height * 0.06),
                  _buildCarouselSection(
                    context,
                    size,
                    idealCardHeight,
                    isDark,
                    theme,
                  ),
                  SizedBox(height: size.height * 0.08),
                ],
              ),
            ),
            _buildAnimatedHeader(context, isDark, theme),
            ChatbotWidget(onNavigate: _handleChatbotNavigation),
          ],
        );
      },
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isDark ? Colors.black.withOpacity(0.1) : Colors.grey.shade100,
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
    );
  }

  Widget _buildAnimatedHeader(
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _isHeaderVisible ? 0 : -100,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school, size: 20, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'IQRA Virtual Tour',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeInRight(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        key: ValueKey(isDark),
                        color: isDark ? Colors.amber : Colors.indigo,
                      ),
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                    tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Size size, double heroHeight) {
    return FadeInDown(
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
    );
  }

  Widget _buildInfoSection(BuildContext context, Size size) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: HomeScreen.buildInfoSection(context: context, isMobile: false),
      ),
    );
  }

  Widget _buildCarouselSection(
    BuildContext context,
    Size size,
    double idealCardHeight,
    bool isDark,
    ThemeData theme,
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.02,
          vertical: size.height * 0.03,
        ),
        constraints: const BoxConstraints(maxWidth: 1800),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: idealCardHeight + 40,
                  child: HomeScreen.buildCarousel(
                    context: context,
                    cardHeight: idealCardHeight,
                    controller: _controller,
                    selectedIndex: _selectedIndex,
                    isInteracting: _isInteracting,
                    onPageChanged:
                        (index) => setState(() => _selectedIndex = index),
                    isDesktop: true,
                    onTap: (index) {},
                    setInteracting: (value) {},
                  ),
                ),
                if (_showLeftArrow)
                  Positioned(
                    left: 0,
                    child: _buildNavigationArrow(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => _navigateToPage(-1),
                      isDark: isDark,
                      theme: theme,
                    ),
                  ),
                if (_showRightArrow)
                  Positioned(
                    right: 0,
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
            _buildPageIndicator(theme, isDark),
            const SizedBox(height: 20),
            _buildCardCounter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(ThemeData theme, bool isDark) {
    return SmoothPageIndicator(
      controller: _controller,
      count: AppConstants.locationCards.length,
      effect: WormEffect(
        dotWidth: 10,
        dotHeight: 10,
        spacing: 12,
        activeDotColor: theme.primaryColor,
        dotColor: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
        paintStyle: PaintingStyle.fill,
      ),
    );
  }

  Widget _buildCardCounter(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              width: 64,
              height: 64,
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
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
