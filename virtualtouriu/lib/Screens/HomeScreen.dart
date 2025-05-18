import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtualtouriu/Reponsive/Responsive_Layout.dart';
import 'package:virtualtouriu/Screens/categories.dart';
import 'package:virtualtouriu/Screens/desktop_home_screen.dart';
import 'package:virtualtouriu/Screens/mobile_home_screen.dart';
import 'package:virtualtouriu/Screens/tablet_home_screen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/core/widgets/location_card.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

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
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoriesScreen()),
          );
        },
        child: const Icon(Icons.explore),
        tooltip: 'Start Tour',
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  static Widget buildHeroSection(
    BuildContext context, {
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
                  color: Colors.grey,
                  child: const Text('Image Missing'),
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
                    fontSize: fontSize.clamp(20, 50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Shaping Futures Since 1998',
                  style: GoogleFonts.roboto(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: fontSize.clamp(14, 24),
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

  static Widget buildInfoSection(
    BuildContext context, {
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
                fontSize: isMobile ? 14 : 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              "Explore Iqra University",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              "Discover our state-of-the-art H-9 campus in Islamabad.",
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 14 : 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            isMobile
                ? ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.06,
                      vertical: size.height * 0.015,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Start Tour",
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : _AnimatedStartTourButton(size: size),
          ],
        ),
      ),
    );
  }

  static Widget buildCarousel(
    BuildContext context, {
    required double cardHeight,
    required PageController controller,
    required int tappedIndex,
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
                    ? const Center(child: Text('No Cards Available'))
                    : ClipRect(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left:
                              isDesktop
                                  ? 0.0
                                  : size.width *
                                      0.04, // Remove left padding for desktop
                          right: size.width * 0.04,
                        ),
                        child: PageView.builder(
                          clipBehavior: Clip.hardEdge,
                          controller: controller,
                          pageSnapping: true,
                          physics: const PageScrollPhysics(),
                          itemCount: locationCards.length,
                          onPageChanged: onPageChanged,
                          itemBuilder: (context, index) {
                            final isCentered =
                                (controller.page?.round() ?? tappedIndex) ==
                                index;
                            return FadeInUp(
                              duration: Duration(
                                milliseconds: 600 + index * 100,
                              ),
                              child:
                                  isDesktop
                                      ? MouseRegion(
                                        onEnter: (_) => setInteracting(true),
                                        onExit: (_) => setInteracting(false),
                                        child: buildCard(
                                          context,
                                          index,
                                          tappedIndex,
                                          onTap,
                                          setInteracting,
                                          isCentered,
                                        ),
                                      )
                                      : GestureDetector(
                                        onTapDown: (_) => setInteracting(true),
                                        onTapCancel:
                                            () => setInteracting(false),
                                        onTap: () {
                                          onTap(index);
                                          controller.animateToPage(
                                            index,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeOut,
                                          );
                                        },
                                        child: buildCard(
                                          context,
                                          index,
                                          tappedIndex,
                                          onTap,
                                          setInteracting,
                                          isCentered,
                                        ),
                                      ),
                            );
                          },
                        ),
                      ),
                    ),
          ),
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
                dotHeight: isDesktop ? 8 : 6,
                dotWidth: isDesktop ? 8 : 6,
                spacing: isDesktop ? 10 : 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCard(
    BuildContext context,
    int index,
    int tappedIndex,
    Function(int) onTap,
    Function(bool) setInteracting,
    bool isCentered,
  ) {
    final isSelected = tappedIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin:
          index == 0
              ? EdgeInsets.only(
                left:
                    MediaQuery.of(context).size.width *
                    0.01, // Reduced left padding
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoriesScreen()),
            );
          },
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
