import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:virtualtouriu/Screens/PanoramaScreen.dart';
import 'package:virtualtouriu/Screens/webgl_room_screen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/core/widgets/custom_button.dart';
import 'package:virtualtouriu/themes/Themes.dart';

class LocationDetailScreen extends StatefulWidget {
  final String locationName;
  final String imagePath;

  const LocationDetailScreen({
    super.key,
    required this.locationName,
    required this.imagePath,
    required LocationCardData locationData,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> features;

  @override
  void initState() {
    super.initState();
    // Load features from constants or use fallback
    features =
        AppConstants.locationFeatures[widget.locationName] ??
        [
          {
            'title': 'Modern Facilities',
            'description':
                'Equipped with the latest amenities for an enhanced experience.',
            'actionType': 'snackbar',
          },
          {
            'title': 'Prime Location',
            'description':
                'Strategically located within the campus for easy access.',
            'actionType': 'dialog',
          },
          {
            'title': 'Versatile Use',
            'description': 'Suitable for various activities and events.',
            'actionType': 'snackbar',
          },
        ];
  }

  void _openTour() {
    final viewType = AppConstants.viewTypeFor(widget.locationName);

    if (viewType == 'webgl') {
      final url = AppConstants.webglUrlFor(widget.locationName);
      if (url == null || url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Virtual tour is not available for this location.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WebGlRoomScreen(title: widget.locationName, url: url),
        ),
      );
      return;
    }

    // Default: Panorama view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PanoramaScreen(locationName: widget.locationName),
      ),
    );
  }

  void _handleFeatureTap(Map<String, dynamic> feature) {
    final actionType = feature['actionType'] as String?;

    switch (actionType) {
      case 'navigate':
        _openTour();
        break;
      case 'dialog':
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).cardColor.withOpacity(0.95),
                title: Text(
                  feature['title'],
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  feature['description'],
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Close',
                      style: GoogleFonts.roboto(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
        );
        break;
      default: // snackbar or undefined
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(feature['title']),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  Widget _buildFeatureCard(
    String title,
    String description,
    double cardWidth,
    double fontSize,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: isDesktop ? (_) => setState(() => isHovered = true) : null,
          onExit: isDesktop ? (_) => setState(() => isHovered = false) : null,
          child: GestureDetector(
            onTap: () {
              final feature = features.firstWhere(
                (f) => f['title'] == title,
                orElse: () => {'actionType': 'snackbar'},
              );
              _handleFeatureTap(feature);
            },
            child: AnimatedScale(
              scale: isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isHovered
                            ? [
                              theme.cardColor,
                              theme.cardColor.withOpacity(0.8),
                            ]
                            : [
                              theme.cardColor.withOpacity(0.9),
                              theme.cardColor.withOpacity(0.7),
                            ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isHovered
                              ? theme.primaryColor.withOpacity(
                                isDesktop ? 0.4 : 0.3,
                              )
                              : Colors.black.withOpacity(0.12),
                      blurRadius: isHovered ? 14 : 8,
                      offset: Offset(0, isHovered ? 8 : 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: fontSize * 1.1,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.roboto(
                        fontSize: fontSize * 0.9,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.75,
                        ),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final size = MediaQuery.of(context).size;

    final bool isMobile = size.width < 600;
    final bool isTablet = size.width >= 600 && size.width < 900;
    final bool isDesktop = size.width >= 900;

    final double paddingHorizontal =
        isMobile
            ? 16
            : isTablet
            ? 32
            : 64;
    final double imageHeight =
        isDesktop
            ? size.height * 0.55
            : isTablet
            ? size.height * 0.4
            : size.height * 0.35;
    final double clampedImageHeight = imageHeight.clamp(300.0, 700.0);

    final double titleFontSize = (size.width * 0.06).clamp(24.0, 36.0);
    final double bodyFontSize = (size.width * 0.04).clamp(14.0, 18.0);

    final double cardWidth = isDesktop ? size.width * 0.25 : size.width * 0.85;
    final double cardSpacing = isMobile ? 12 : 20;

    final double buttonWidth = (size.width * 0.5).clamp(200.0, 300.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background blur effect (desktop only)
          if (isDesktop)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? Colors.black.withOpacity(0.1)
                        : Colors.grey.shade50,
                    isDark ? Colors.black.withOpacity(0.2) : Colors.white,
                  ],
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

          // Main scrollable content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image
                Stack(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        height: clampedImageHeight,
                        width: double.infinity,
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.broken_image,
                                        size: 60,
                                        color: Colors.grey,
                                      ),
                                      Text(
                                        'Image not found',
                                        style: GoogleFonts.roboto(
                                          fontSize: bodyFontSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                    ),
                    // Dark overlay gradient
                    Container(
                      height: clampedImageHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Location Title on Image
                    Positioned(
                      bottom: 30,
                      left: paddingHorizontal,
                      right: paddingHorizontal,
                      child: FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          widget.locationName,
                          style: GoogleFonts.roboto(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.8),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Section
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About ${widget.locationName}',
                              style: GoogleFonts.roboto(
                                fontSize: titleFontSize * 0.8,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Experience the vibrant and modern atmosphere of ${widget.locationName} at Iqra University Islamabad Campus. '
                              'This space is designed to inspire learning, collaboration, and community engagement.',
                              style: GoogleFonts.roboto(
                                fontSize: bodyFontSize,
                                height: 1.6,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: CustomButton(
                                text: 'Start Virtual Tour',
                                onPressed: _openTour,
                                width: buttonWidth,
                                fontSize: bodyFontSize + 2,
                                isMobile: isMobile,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Key Features Section
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Key Features',
                              style: GoogleFonts.roboto(
                                fontSize: titleFontSize * 0.8,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Wrap(
                                spacing: cardSpacing,
                                runSpacing: cardSpacing,
                                alignment: WrapAlignment.center,
                                children:
                                    features.map((feature) {
                                      return _buildFeatureCard(
                                        feature['title'],
                                        feature['description'],
                                        cardWidth,
                                        bodyFontSize,
                                        isDesktop,
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Theme Toggle Button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: IconButton(
                  iconSize: 32,
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed:
                      () =>
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).toggleTheme(),
                  tooltip: 'Toggle Theme',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
