import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/Screens/PanoramaScreen.dart';
import 'package:virtualtouriu/Screens/webgl_room_screen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';

class LocationDetailScreen extends StatefulWidget {
  final String locationName;
  final String imagePath;
  final LocationCardData locationData;

  const LocationDetailScreen({
    super.key,
    required this.locationName,
    required this.imagePath,
    required this.locationData,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen>
    with SingleTickerProviderStateMixin {
  late final List<Map<String, dynamic>> features;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load features from constants or use fallback
    features =
        AppConstants.locationFeatures[widget.locationData.name] ??
        [
          {
            'icon': Icons.wb_sunny_outlined,
            'title': 'Modern Facilities',
            'description': 'State-of-the-art amenities designed for excellence',
          },
          {
            'icon': Icons.location_on_outlined,
            'title': 'Prime Location',
            'description': 'Strategically positioned within campus grounds',
          },
          {
            'icon': Icons.groups_outlined,
            'title': 'Community Hub',
            'description': 'Perfect space for collaboration and growth',
          },
        ];
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openTour() {
    final viewType = AppConstants.viewTypeFor(widget.locationData.name);

    if (viewType == 'webgl') {
      final url = AppConstants.webglUrlFor(widget.locationData.name);
      if (url == null || url.isEmpty) {
        _showSnackBar(
          'Virtual tour is not available for this location',
          isError: true,
        );
        return;
      }

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  WebGlRoomScreen(title: widget.locationData.name, url: url),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }

    // Default: Panorama view
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PanoramaScreen(locationName: widget.locationData.name),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts.roboto(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor:
            isError ? Colors.red.shade400 : Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Premium background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
                  isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
                ],
              ),
            ),
          ),

          // Main Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: isMobile ? 400 : 500,
                pinned: true,
                elevation: 0,
                backgroundColor:
                    isDark
                        ? const Color(
                          0xFF1A1A1A,
                        ).withOpacity(_isScrolled ? 0.95 : 0)
                        : Colors.white.withOpacity(_isScrolled ? 0.95 : 0),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: isDark ? Colors.amber : Colors.indigo,
                          size: 20,
                        ),
                        onPressed:
                            () =>
                                Provider.of<ThemeProvider>(
                                  context,
                                  listen: false,
                                ).toggleTheme(),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero Image
                      Image.asset(
                        widget.locationData.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.primaryColor.withOpacity(0.3),
                                    theme.primaryColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                      ),
                      // Gradient Overlay
                      Container(
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
                      // Title at Bottom
                      Positioned(
                        left: isMobile ? 20 : 40,
                        right: isMobile ? 20 : 40,
                        bottom: 40,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'IQRA University',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.locationData.name,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: isMobile ? 32 : 48,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Section
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF0A0A0A)
                            : const Color(0xFFFAFAFA),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          isMobile
                              ? 20
                              : isTablet
                              ? 40
                              : 80,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tour Button
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _openTour,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 32 : 48,
                                    vertical: 20,
                                  ),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.view_in_ar_rounded,
                                  size: 24,
                                ),
                                label: Text(
                                  'Start Virtual Tour',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // About Section
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'ABOUT THIS LOCATION',
                                  style: GoogleFonts.roboto(
                                    fontSize: 11,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.locationData.description.isNotEmpty
                                    ? widget.locationData.description
                                    : 'Experience the vibrant and modern atmosphere of ${widget.locationData.name} at Iqra University Islamabad Campus. This space is designed to inspire learning, collaboration, and community engagement.',
                                style: GoogleFonts.roboto(
                                  fontSize: isMobile ? 16 : 18,
                                  height: 1.7,
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.8),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 56),

                        // Key Features Section
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Key Features',
                                style: GoogleFonts.roboto(
                                  fontSize: isMobile ? 28 : 36,
                                  fontWeight: FontWeight.w900,
                                  color: theme.textTheme.headlineMedium?.color,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'What makes this location special',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildFeatureGrid(
                                isMobile,
                                isTablet,
                                isDark,
                                theme,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(
    bool isMobile,
    bool isTablet,
    bool isDark,
    ThemeData theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount =
            isMobile
                ? 1
                : isTablet
                ? 2
                : 3;
        double spacing = isMobile ? 16 : 20;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              features.asMap().entries.map((entry) {
                final index = entry.key;
                final feature = entry.value;

                return FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: Duration(milliseconds: 300 + (index * 100)),
                  child: Container(
                    width:
                        isMobile
                            ? constraints.maxWidth
                            : (constraints.maxWidth -
                                    spacing * (crossAxisCount - 1)) /
                                crossAxisCount,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            feature['icon'] ?? Icons.star_outline,
                            color: theme.primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feature['title'] ?? 'Feature',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feature['description'] ?? 'Description',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            height: 1.5,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }
}
