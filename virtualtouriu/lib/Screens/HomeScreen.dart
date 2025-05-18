import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';

import 'package:virtualtouriu/Screens/categories.dart';
import 'package:virtualtouriu/Screens/desktop_home_screen.dart';
import 'package:virtualtouriu/Screens/mobile_home_screen.dart';
import 'package:virtualtouriu/Screens/tablet_home_screen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/core/widgets/location_card.dart';
import 'package:virtualtouriu/responsive/Responsive_Layout.dart';
import 'package:virtualtouriu/themes/Themes.dart';

// Main HomeScreen widget that sets up the responsive layout and shared UI elements
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: Stack(
        children: [
          // Responsive layout for different screen sizes
          const ResponsiveLayout(
            mobileBody: MobileHomeScreen(),
            tabletBody: TabletHomeScreen(),
            desktopBody: DesktopHomeScreen(),
          ),
          // Theme toggle button at top-right
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
      // Floating action button to navigate to CategoriesScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () => HomeScreen._navigateToCategories(context),
        tooltip: 'Start Tour',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.explore),
      ),
    );
  }

  // Helper method to navigate to CategoriesScreen
  static void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
    );
  }

  // Builds the hero section with a background image and text
  static Widget buildHeroSection({
    required BuildContext context,
    required double fontSize,
    required double heightFactor,
  }) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * heightFactor,
      width: double.infinity,
      child: Stack(
        children: [
          // Background image with error handling
          Image.asset(
            'lib/images/main.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Text('Failed to load image')),
                ),
          ),
          // Gradient overlay for better text readability
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
          // University branding text
          Positioned(
            bottom: size.height * 0.05,
            left: size.width * 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IQRA UNIVERSITY ISLAMABAD',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: fontSize.clamp(20.0, 50.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Shaping Futures Since 1998',
                  style: GoogleFonts.roboto(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: fontSize.clamp(14.0, 24.0),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the info section with title, description, and a start tour button
  static Widget buildInfoSection({
    required BuildContext context,
    required bool isMobile,
  }) {
    final size = MediaQuery.of(context).size;

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "VIRTUAL TOUR",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 14.0 : 16.0,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              "Explore Iqra University",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 24.0 : 28.0,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              "Discover our state-of-the-art H-9 campus in Islamabad.",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 14.0 : 16.0,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                    Colors.grey,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            isMobile
                ? _buildMobileStartButton(context, size)
                : _AnimatedStartTourButton(size: size),
          ],
        ),
      ),
    );
  }

  // Builds the carousel for displaying location cards
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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: cardHeight,
            child:
                locationCards.isEmpty
                    ? const Center(child: Text('No locations available'))
                    : ClipRect(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: isDesktop ? 0.0 : size.width * 0.04,
                          right: size.width * 0.04,
                        ),
                        child: PageView.builder(
                          clipBehavior: Clip.hardEdge,
                          controller: controller,
                          pageSnapping: true,
                          physics: const PageScrollPhysics(),
                          itemCount: locationCards.length,
                          onPageChanged: onPageChanged,
                          itemBuilder:
                              (context, index) => _buildCarouselCard(
                                context: context,
                                index: index,
                                selectedIndex: selectedIndex,
                                isInteracting: isInteracting,
                                onTap: onTap,
                                setInteracting: setInteracting,
                                controller: controller,
                                isDesktop: isDesktop,
                              ),
                        ),
                      ),
                    ),
          ),
          // Page indicator for carousel navigation
          if (locationCards.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.50, top: 15),
              child: SmoothPageIndicator(
                controller: controller,
                count: locationCards.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Theme.of(context).primaryColor,
                  dotColor:
                      Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.3) ??
                      Colors.grey,
                  dotHeight: isDesktop ? 8.0 : 6.0,
                  dotWidth: isDesktop ? 8.0 : 6.0,
                  spacing: isDesktop ? 10.0 : 8.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builds individual carousel card with animations
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

    return FadeInUp(
      duration: Duration(milliseconds: 600 + index * 100),
      child:
          isDesktop
              ? MouseRegion(
                onEnter: (_) => setInteracting(true),
                onExit: (_) => setInteracting(false),
                child: _buildCardContent(
                  context: context,
                  index: index,
                  isSelected: isSelected,
                  isCentered: isCentered,
                  onTap: onTap,
                  controller: controller,
                ),
              )
              : GestureDetector(
                onTapDown: (_) => setInteracting(true),
                onTapCancel: () => setInteracting(false),
                onTap: () {
                  onTap(index);
                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                child: _buildCardContent(
                  context: context,
                  index: index,
                  isSelected: isSelected,
                  isCentered: isCentered,
                  onTap: onTap,
                  controller: controller,
                ),
              ),
    );
  }

  // Builds the content of a carousel card
  static Widget _buildCardContent({
    required BuildContext context,
    required int index,
    required bool isSelected,
    required bool isCentered,
    required Function(int) onTap,
    required PageController controller,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin:
          index == 0
              ? EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.01,
                right: MediaQuery.of(context).size.width * 0.04,
                top: 12.0,
                bottom: 12.0,
              )
              : EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: 12.0,
              ),
      child: Transform.scale(
        scale:
            isSelected
                ? 1.1
                : isCentered
                ? 1.08
                : 1.0,
        child: Transform.rotate(
          angle: isSelected ? 0.02 : 0.0,
          child: LocationCard(
            data: locationCards[index],
            isHovered: isSelected || isCentered,
          ),
        ),
      ),
    );
  }

  // Mobile-specific start tour button
  static Widget _buildMobileStartButton(BuildContext context, Size size) {
    return ElevatedButton(
      onPressed: () => HomeScreen._navigateToCategories(context),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: size.height * 0.015,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        "Start Tour",
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Animated button for desktop and tablet layouts
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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
      duration: const Duration(milliseconds: 800),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => HomeScreen._navigateToCategories(context),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isHovered ? 1.1 : _pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.size.width * 0.06,
                    vertical: widget.size.height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          _isHovered
                              ? [primaryColor, primaryColor.withOpacity(0.7)]
                              : [
                                primaryColor.withOpacity(0.9),
                                primaryColor.withOpacity(0.6),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color:
                            _isHovered
                                ? primaryColor.withOpacity(0.5)
                                : primaryColor.withOpacity(0.3),
                        blurRadius: _isHovered ? 12 : 8,
                        offset: Offset(0, _isHovered ? 8 : 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "Start Tour",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
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
