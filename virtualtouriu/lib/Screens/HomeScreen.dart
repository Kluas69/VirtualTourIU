import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:virtualtouriu/Screens/categories.dart';
import 'package:virtualtouriu/Screens/desktop_home_screen.dart';
import 'package:virtualtouriu/Screens/mobile_home_screen.dart';
import 'package:virtualtouriu/Screens/tablet_home_screen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/core/widgets/location_card.dart';
import 'package:virtualtouriu/responsive/Responsive_Layout.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';
import 'dart:async';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    print('HomeScreen rebuilt');

    return FutureBuilder<void>(
      future: AppConstants.initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading data: ${snapshot.error}\nPlease check app_data.json and ensure assets are correctly declared in pubspec.yaml.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.red,
                  textStyle: const TextStyle(height: 1.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Scaffold(
          // Rest of the Scaffold content remains unchanged
          body: Stack(
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
              const ResponsiveLayout(
                mobileBody: MobileHomeScreen(),
                tabletBody: TabletHomeScreen(),
                desktopBody: DesktopHomeScreen(),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      onPressed: () => themeProvider.toggleTheme(),
                      tooltip: 'Toggle Theme',
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToCategories(context),
            tooltip: 'Start Tour',
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.explore),
          ),
        );
      },
    );
  }

  // Rest of the HomeScreen methods (buildHeroSection, buildInfoSection, buildCarousel, etc.) remain unchanged
  static void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
    );
  }

  static Widget buildHeroSection({
    required BuildContext context,
    required double fontSize,
    required double heightFactor,
  }) {
    // Implementation remains unchanged
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * heightFactor,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            'lib/images/backgroundiu.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Text('Failed to load image')),
                ),
          ),
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            left: size.width * 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IQRA UNIVERSITY',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: fontSize.clamp(25.0, 45.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      'ISLAMABAD CAMPUS',
                      textStyle: GoogleFonts.roboto(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: fontSize.clamp(8.0, 16.0),
                        fontWeight: FontWeight.w400,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                    // Other animated texts remain unchanged
                  ],
                  pause: const Duration(seconds: 3),
                  isRepeatingAnimation: true,
                  repeatForever: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Other static methods (buildInfoSection, buildCarousel, etc.) remain unchanged

  static Widget buildInfoSection({
    required BuildContext context,
    required bool isMobile,
  }) {
    final size = MediaQuery.of(context).size;

    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "VIRTUAL TOUR",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 16.0 : 18.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              "Explore Iqra University",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 26.0 : 32.0,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              "Discover our state-of-the-art H-9 campus in Islamabad.",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 16.0 : 18.0,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                    Colors.grey,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            isMobile
                ? _buildMobileStartButton(context, size)
                : _AnimatedStartTourButton(size: size),
          ],
        ),
      ),
    );
  }

  static Widget buildCarousel({
    required BuildContext context,
    required double cardHeight,
    required PageController controller,
    required int selectedIndex,
    required bool isInteracting,
    required Function(int) onTap,
    required Function(bool) setInteracting,
    required Function(int) onPageChanged,
    bool isDesktop = false,
  }) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final isMobile = size.width < 600;

    final buttonSize = isDesktop ? 48.0 : (size.width * 0.12).clamp(36.0, 44.0);
    final buttonPadding =
        isDesktop ? 16.0 : (size.width * 0.03).clamp(8.0, 12.0);
    final canScrollLeft = selectedIndex > 0;
    final canScrollRight =
        selectedIndex < AppConstants.locationCards.length - 1;

    print('Building carousel with ${AppConstants.locationCards.length} cards');

    return Builder(
      builder: (context) {
        print('Carousel content rebuilt');
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: cardHeight,
                child:
                    AppConstants.locationCards.isEmpty
                        ? Center(
                          child: Text(
                            'No locations available. Please check app_data.json.',
                            style: GoogleFonts.roboto(
                              fontSize: 18.0,
                              color:
                                  theme.textTheme.bodyMedium?.color ??
                                  Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    isDesktop
                                        ? size.width * 0.06
                                        : size.width * 0.05,
                                vertical: 20.0,
                              ),
                              child: PageView.builder(
                                clipBehavior: Clip.hardEdge,
                                controller: controller,
                                pageSnapping: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: AppConstants.locationCards.length,
                                onPageChanged: onPageChanged,
                                itemBuilder: (context, index) {
                                  print('Building card at index $index');
                                  return _buildCarouselCard(
                                    context: context,
                                    index: index,
                                    selectedIndex: selectedIndex,
                                    isInteracting: isInteracting,
                                    onTap: onTap,
                                    setInteracting: setInteracting,
                                    controller: controller,
                                    isDesktop: isDesktop,
                                  );
                                },
                              ),
                            ),
                            if (!isMobile)
                              Positioned(
                                left: buttonPadding,
                                top: cardHeight / 2 - buttonSize / 2,
                                child: FadeInLeft(
                                  duration: const Duration(milliseconds: 300),
                                  child: _NavButton(
                                    icon: Icons.arrow_back,
                                    isEnabled: canScrollLeft,
                                    buttonSize: buttonSize,
                                    onPressed: () {
                                      if (canScrollLeft) {
                                        setInteracting(true);
                                        controller.previousPage(
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            if (!isMobile)
                              Positioned(
                                right: buttonPadding,
                                top: cardHeight / 2 - buttonSize / 2,
                                child: FadeInRight(
                                  duration: const Duration(milliseconds: 300),
                                  child: _NavButton(
                                    icon: Icons.arrow_forward,
                                    isEnabled: canScrollRight,
                                    buttonSize: buttonSize,
                                    onPressed: () {
                                      if (canScrollRight) {
                                        setInteracting(true);
                                        controller.nextPage(
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
              ),
              if (AppConstants.locationCards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SmoothPageIndicator(
                    controller: controller,
                    count: AppConstants.locationCards.length,
                    effect: ScrollingDotsEffect(
                      activeDotColor: theme.primaryColor,
                      dotColor: Theme.of(context).colorScheme.onSurface,
                      dotHeight: isDesktop ? 12.0 : 10.0,
                      dotWidth: isDesktop ? 12.0 : 10.0,
                      spacing: isDesktop ? 14.0 : 12.0,
                      maxVisibleDots: 5,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildCarouselCard({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required bool isInteracting,
    required Function(int) onTap,
    required Function(bool) setInteracting,
    required PageController controller,
    required bool isDesktop,
  }) {
    final isCentered = (controller.page?.round() ?? selectedIndex) == index;
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    Timer? debounceTimer;

    void updateInteracting(bool value) {
      if (isInteracting != value) {
        debounceTimer?.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 50), () {
          setInteracting(value);
        });
      }
    }

    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child:
          isDesktop
              ? MouseRegion(
                onEnter: (_) => updateInteracting(true),
                onExit: (_) => updateInteracting(false),
                child: GestureDetector(
                  onTap: () {
                    onTap(index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => LocationDetailScreen(
                              locationName:
                                  AppConstants.locationCards[index].title,
                              imagePath:
                                  AppConstants.locationCards[index].imagePath,
                            ),
                      ),
                    );
                  },
                  child: _buildCardContent(
                    context: context,
                    index: index,
                    isSelected: isSelected,
                    isCentered: isCentered,
                    onTap: onTap,
                    controller: controller,
                    theme: theme,
                  ),
                ),
              )
              : GestureDetector(
                onTapDown: (_) => updateInteracting(true),
                onTapCancel: () => updateInteracting(false),
                onTap: () {
                  onTap(index);
                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutBack,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LocationDetailScreen(
                            locationName:
                                AppConstants.locationCards[index].title,
                            imagePath:
                                AppConstants.locationCards[index].imagePath,
                          ),
                    ),
                  );
                },
                child: _buildCardContent(
                  context: context,
                  index: index,
                  isSelected: isSelected,
                  isCentered: isCentered,
                  onTap: onTap,
                  controller: controller,
                  theme: theme,
                ),
              ),
    );
  }

  static Widget _buildCardContent({
    required BuildContext context,
    required int index,
    required bool isSelected,
    required bool isCentered,
    required Function(int) onTap,
    required PageController controller,
    required ThemeData theme,
  }) {
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutBack,
      margin: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical: 20.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color:
                isSelected
                    ? theme.primaryColor.withOpacity(0.5)
                    : isCentered
                    ? theme.primaryColor.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
            blurRadius:
                isSelected
                    ? 16.0
                    : isCentered
                    ? 12.0
                    : 8.0,
            spreadRadius:
                isSelected
                    ? 4.0
                    : isCentered
                    ? 2.0
                    : 0.0,
            offset: Offset(
              0,
              isSelected
                  ? 10.0
                  : isCentered
                  ? 6.0
                  : 4.0,
            ),
          ),
        ],
      ),
      child: Transform.scale(
        scale: isSelected ? 1.15 : 1.0,
        child: Transform(
          transform:
              Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(
                  isSelected
                      ? 0.05
                      : isCentered
                      ? 0.03
                      : 0.1,
                )
                ..rotateX(
                  isSelected
                      ? -0.05
                      : isCentered
                      ? -0.03
                      : 0.0,
                ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: Stack(
              children: [
                LocationCard(
                  data: AppConstants.locationCards[index],
                  isHovered: isSelected || isCentered,
                ),
                if (isSelected || isCentered)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.7),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildMobileStartButton(BuildContext context, Size size) {
    return ElevatedButton(
      onPressed: () => _navigateToCategories(context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.015,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        "Start Tour",
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16.0,
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final bool isEnabled;
  final double buttonSize;
  final VoidCallback onPressed;

  const _NavButton({
    required this.icon,
    required this.isEnabled,
    required this.buttonSize,
    required this.onPressed,
  });

  @override
  _NavButtonState createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return MouseRegion(
      onEnter:
          widget.isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit:
          widget.isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.isEnabled ? widget.onPressed : null,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale:
                  widget.isEnabled
                      ? (_isHovered ? 1.15 : _pulseAnimation.value)
                      : 1.0,
              child: Container(
                width: widget.buttonSize,
                height: widget.buttonSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        widget.isEnabled
                            ? _isHovered
                                ? [primaryColor, primaryColor.withOpacity(0.8)]
                                : [
                                  primaryColor.withOpacity(0.9),
                                  primaryColor.withOpacity(0.6),
                                ]
                            : [
                              Colors.grey.withOpacity(0.5),
                              Colors.grey.withOpacity(0.5),
                            ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          widget.isEnabled
                              ? _isHovered
                                  ? primaryColor.withOpacity(0.6)
                                  : primaryColor.withOpacity(0.4)
                              : Colors.black.withOpacity(0.2),
                      blurRadius: _isHovered ? 14 : 10,
                      offset: Offset(0, _isHovered ? 10 : 6),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color:
                      widget.isEnabled
                          ? theme.colorScheme.onPrimary
                          : Colors.grey,
                  size: widget.buttonSize * 0.5,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedStartTourButton extends StatefulWidget {
  final Size size;

  const _AnimatedStartTourButton({required this.size});

  @override
  _AnimatedStartTourButtonState createState() =>
      _AnimatedStartTourButtonState();
}

class _AnimatedStartTourButtonState extends State<_AnimatedStartTourButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => HomeScreen._navigateToCategories(context),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isHovered ? 1.15 : _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.size.width * 0.06,
                    vertical: widget.size.height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          _isHovered
                              ? [primaryColor, primaryColor.withOpacity(0.8)]
                              : [
                                primaryColor.withOpacity(0.9),
                                primaryColor.withOpacity(0.6),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _isHovered
                                ? primaryColor.withOpacity(0.6)
                                : primaryColor.withOpacity(0.4),
                        blurRadius: _isHovered ? 14 : 10,
                        offset: Offset(0, _isHovered ? 10 : 6),
                      ),
                    ],
                  ),
                  child: Text(
                    "Start Tour",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
