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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      body: Stack(
        children: [
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
  }

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
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * heightFactor,
      width: double.infinity,
      child: Stack(
        children: [
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
                  'IQRA UNIVERSITY ISLAMABAD',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: fontSize.clamp(26.0, 50.0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Shaping Futures Since 1998',
                  style: GoogleFonts.roboto(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: fontSize.clamp(16.0, 28.0),
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

  static Widget buildInfoSection({
    required BuildContext context,
    required bool isMobile,
  }) {
    final size = MediaQuery.of(context).size;

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
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

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: cardHeight,
            child:
                locationCards.isEmpty
                    ? Center(
                      child: Text(
                        'No locations available',
                        style: GoogleFonts.roboto(
                          fontSize: 18.0,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    )
                    : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            isDesktop ? size.width * 0.06 : size.width * 0.05,
                        vertical: 20.0,
                      ),
                      child: PageView.builder(
                        clipBehavior: Clip.hardEdge,
                        controller: controller,
                        pageSnapping: true,
                        physics: const ClampingScrollPhysics(),
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
          if (locationCards.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SmoothPageIndicator(
                controller: controller,
                count: locationCards.length,
                effect: WormEffect(
                  activeDotColor: theme.primaryColor,
                  dotColor:
                      theme.textTheme.bodyMedium?.color?.withOpacity(0.4) ??
                      Colors.grey,
                  dotHeight: isDesktop ? 12.0 : 10.0,
                  dotWidth: isDesktop ? 12.0 : 10.0,
                  spacing: isDesktop ? 14.0 : 12.0,
                  type: WormType.thin,
                ),
              ),
            ),
        ],
      ),
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

    return SlideInRight(
      duration: Duration(milliseconds: 1000 + index * 200),
      from: isDesktop ? 100.0 : 50.0,
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
                  theme: theme,
                ),
              )
              : GestureDetector(
                onTapDown: (_) => setInteracting(true),
                onTapCancel: () => setInteracting(false),
                onTap: () {
                  onTap(index);
                  controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOutBack,
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
        horizontal: size.width * 0.02, // Reduced gap between cards
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
      child: Transform(
        transform:
            Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective for 3D effect
              ..rotateY(
                isSelected
                    ? 0.05
                    : isCentered
                    ? 0.03
                    : 0.0,
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
          borderRadius: BorderRadius.circular(20.0),
          child: GestureDetector(
            onTap: () => onTap(index),
            child: Stack(
              children: [
                LocationCard(
                  data: locationCards[index],
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
