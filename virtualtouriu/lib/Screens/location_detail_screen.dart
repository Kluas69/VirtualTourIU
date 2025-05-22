import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:virtualtouriu/core/widgets/custom_button.dart';
import 'package:virtualtouriu/Screens/PanoramaScreen.dart';
import 'package:virtualtouriu/core/constants.dart';

class LocationDetailScreen extends StatefulWidget {
  final String locationName;
  final String imagePath;

  const LocationDetailScreen({
    super.key,
    required this.locationName,
    required this.imagePath,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final mediaQuery = MediaQuery.of(context);

    // Fetch dynamic features from AppConstants or fallback to default
    final features =
        AppConstants.locationFeatures[widget.locationName] ??
        [
          {
            'title': 'Modern Design',
            'description':
                'Sleek architecture with state-of-the-art facilities.',
            'action': () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PanoramaScreen(locationName: widget.locationName),
                ),
              );
            },
          },
          {
            'title': 'Accessible Location',
            'description':
                'Centrally located for easy access across the H-9 campus.',
            'action': () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.cardColor.withOpacity(0.95),
                      title: Text(
                        'Accessible Location',
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      content: Text(
                        'This location is centrally positioned for easy access.',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Close',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
              );
            },
          },
          {
            'title': 'Versatile Space',
            'description': 'Perfect for events, meetings, or relaxation.',
            'action': () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Versatile Space tapped!',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  backgroundColor: theme.primaryColor.withOpacity(0.9),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          },
        ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;
          final isDesktop = constraints.maxWidth >= 900;
          final paddingHorizontal =
              isMobile
                  ? 16.0
                  : isTablet
                  ? 24.0
                  : 48.0;
          final paddingVertical =
              isMobile
                  ? 12.0
                  : isTablet
                  ? 16.0
                  : 24.0;
          final imageHeight =
              isDesktop
                  ? (mediaQuery.size.height * 0.5).clamp(400.0, 1200.0)
                  : (mediaQuery.size.width * 0.35).clamp(
                    isMobile ? 200.0 : 250.0,
                    350.0,
                  );
          final fontSizeTitle = (constraints.maxWidth * 0.05).clamp(
            isMobile ? 20.0 : 22.0,
            isDesktop ? 30.0 : 28.0,
          );
          final fontSizeBody = (constraints.maxWidth * 0.035).clamp(
            isMobile ? 13.0 : 14.0,
            isDesktop ? 18.0 : 16.0,
          );
          final cardWidth =
              isDesktop
                  ? constraints.maxWidth * 0.28
                  : constraints.maxWidth * 0.9;
          final cardSpacing =
              isMobile
                  ? 10.0
                  : isTablet
                  ? 14.0
                  : 20.0;
          final buttonWidth = (constraints.maxWidth * 0.3).clamp(
            isMobile ? 160.0 : 180.0,
            isDesktop ? 260.0 : 240.0,
          );
          final maxContentWidth = isDesktop ? 1400.0 : constraints.maxWidth;

          return Stack(
            children: [
              if (isDesktop)
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 400),
                              child: SizedBox(
                                height: imageHeight,
                                width: double.infinity,
                                child: Image.asset(
                                  widget.imagePath,
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey.shade300,
                                        child: Center(
                                          child: Text(
                                            'Image not found',
                                            style: GoogleFonts.roboto(
                                              fontSize: fontSizeBody,
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Container(
                              height: imageHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(
                                      isDesktop ? 0.4 : 0.3,
                                    ),
                                    Colors.black.withOpacity(
                                      isDesktop ? 0.8 : 0.7,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              left: paddingHorizontal,
                              child: SafeArea(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: isMobile ? 24 : 28,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: paddingHorizontal,
                              right: paddingHorizontal,
                              child: FadeInUp(
                                duration: const Duration(milliseconds: 700),
                                child: Text(
                                  widget.locationName,
                                  style: GoogleFonts.roboto(
                                    fontSize:
                                        fontSizeTitle * (isDesktop ? 1.3 : 1.2),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: isDesktop ? 8 : 6,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: paddingVertical,
                          ),
                          child:
                              isDesktop
                                  ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: FadeInUp(
                                          duration: const Duration(
                                            milliseconds: 700,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'About ${widget.locationName}',
                                                style: GoogleFonts.roboto(
                                                  fontSize: fontSizeTitle,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Immerse yourself in the vibrant atmosphere of ${widget.locationName} at Iqra University. '
                                                'This iconic space is crafted to inspire students, faculty, and visitors alike. '
                                                'From hosting dynamic events to fostering creativity and collaboration, '
                                                '${widget.locationName} stands as a cornerstone of our campus community.',
                                                style: GoogleFonts.roboto(
                                                  fontSize: fontSizeBody,
                                                  color: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.7),
                                                  height: 1.5,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              Center(
                                                child: CustomButton(
                                                  text: 'Start Virtual Tour',
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (
                                                              context,
                                                            ) => PanoramaScreen(
                                                              locationName:
                                                                  widget
                                                                      .locationName,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  width: buttonWidth,
                                                  fontSize: fontSizeBody,
                                                  isMobile: isMobile,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        flex: 2,
                                        child: FadeInUp(
                                          duration: const Duration(
                                            milliseconds: 700,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Key Features',
                                                style: GoogleFonts.roboto(
                                                  fontSize: fontSizeTitle * 0.8,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Wrap(
                                                spacing: cardSpacing,
                                                runSpacing: cardSpacing,
                                                alignment: WrapAlignment.start,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.start,
                                                children:
                                                    features.map((feature) {
                                                      return _buildFeatureCard(
                                                        context,
                                                        feature['title']
                                                            as String,
                                                        feature['description']
                                                            as String,
                                                        feature['action']
                                                            as VoidCallback?,
                                                        cardWidth * 0.9,
                                                        fontSizeBody,
                                                        isDesktop,
                                                      );
                                                    }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FadeInUp(
                                        duration: const Duration(
                                          milliseconds: 700,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'About ${widget.locationName}',
                                              style: GoogleFonts.roboto(
                                                fontSize: fontSizeTitle,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Immerse yourself in the vibrant atmosphere of ${widget.locationName} at Iqra University. '
                                              'This iconic space is crafted to inspire students, faculty, and visitors alike. '
                                              'From hosting dynamic events to fostering creativity and collaboration, '
                                              '${widget.locationName} stands as a cornerstone of our campus community.',
                                              style: GoogleFonts.roboto(
                                                fontSize: fontSizeBody,
                                                color: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withOpacity(0.7),
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Center(
                                              child: CustomButton(
                                                text: 'Start Virtual Tour',
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            context,
                                                          ) => PanoramaScreen(
                                                            locationName:
                                                                widget
                                                                    .locationName,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                width: buttonWidth,
                                                fontSize: fontSizeBody,
                                                isMobile: isMobile,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      FadeInUp(
                                        duration: const Duration(
                                          milliseconds: 700,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Key Features',
                                              style: GoogleFonts.roboto(
                                                fontSize: fontSizeTitle * 0.8,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Center(
                                              child: Wrap(
                                                spacing: cardSpacing,
                                                runSpacing: cardSpacing,
                                                alignment: WrapAlignment.center,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children:
                                                    features.map((feature) {
                                                      return _buildFeatureCard(
                                                        context,
                                                        feature['title']
                                                            as String,
                                                        feature['description']
                                                            as String,
                                                        feature['action']
                                                            as VoidCallback?,
                                                        cardWidth,
                                                        fontSizeBody,
                                                        isDesktop,
                                                      );
                                                    }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                        SizedBox(height: paddingVertical * 2),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: isDark ? Colors.white : Colors.black,
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
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    VoidCallback? onTap,
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
            onTap: onTap,
            child: AnimatedScale(
              scale: isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          isHovered
                              ? theme.primaryColor.withOpacity(
                                isDesktop ? 0.4 : 0.3,
                              )
                              : Colors.black.withOpacity(0.1),
                      blurRadius: isHovered ? (isDesktop ? 12 : 10) : 6,
                      offset: Offset(0, isHovered ? (isDesktop ? 8 : 6) : 4),
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
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.roboto(
                        fontSize: fontSize * 0.9,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
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
}
