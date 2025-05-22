import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:panorama/panorama.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:virtualtouriu/core/constants.dart';

class PanoramaScreen extends StatefulWidget {
  final String locationName;

  const PanoramaScreen({super.key, required this.locationName});

  @override
  State<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends State<PanoramaScreen>
    with SingleTickerProviderStateMixin {
  bool _showControls = true;
  bool _showHelpOverlay = false;
  bool _showInfoOverlay = false;
  bool _isFullScreen = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _currentLocation = '';
  double _zoomLevel = 1.0; // Control zoom (field of view)

  @override
  void initState() {
    super.initState();
    debugPrint('PanoramaScreen initState for ${widget.locationName}');
    _currentLocation = widget.locationName;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _checkFirstUse();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isFullScreen) {
        setState(() => _showControls = false);
        _fadeController.forward();
      }
    });
  }

  Future<void> _checkFirstUse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenHelp = prefs.getBool('hasSeenPanoramaHelp') ?? false;
      if (!hasSeenHelp && mounted) {
        setState(() => _showHelpOverlay = true);
        await prefs.setBool('hasSeenPanoramaHelp', true);
        debugPrint('Help overlay shown and preference saved');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _showHelpOverlay = true);
      }
      debugPrint('Error checking first use: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('PanoramaScreen disposed');
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
        if (_showControls) {
          _fadeController.reverse();
        } else {
          _fadeController.forward();
        }
      });
    }
  }

  void _toggleFullScreen() {
    if (mounted) {
      setState(() {
        _isFullScreen = !_isFullScreen;
        _showControls = _isFullScreen ? true : _showControls;
        if (!_showControls && !_isFullScreen) {
          _fadeController.forward();
        } else {
          _fadeController.reverse();
        }
      });
    }
  }

  void _zoomIn() {
    if (mounted) {
      setState(() {
        _zoomLevel = (_zoomLevel * 0.9).clamp(0.5, 2.0); // Decrease FOV
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zoomed in')));
    }
  }

  void _zoomOut() {
    if (mounted) {
      setState(() {
        _zoomLevel = (_zoomLevel * 1.1).clamp(0.5, 2.0); // Increase FOV
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zoomed out')));
    }
  }

  void _resetView() {
    if (mounted) {
      setState(() {
        _zoomLevel = 1.0; // Reset zoom to default
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('View reset')));
    }
  }

  void _toggleInfoOverlay() {
    if (mounted) {
      setState(() {
        _showInfoOverlay = !_showInfoOverlay;
        debugPrint('Info overlay toggled: $_showInfoOverlay');
      });
    }
  }

  void _sharePanorama() {
    if (mounted) {
      debugPrint('Share button pressed');
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Share Panorama',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              content: Text(
                'Share the 360° view of $_currentLocation via your preferred platform.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    debugPrint('Share dialog closed');
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Close',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _loadPanorama(String locationName) {
    if (!AppConstants.panoramaImages.containsKey(locationName)) {
      debugPrint('No panorama image for $locationName, using fallback');
      _showErrorSnackBar(
        'No tour available for $locationName, showing default view',
      );
    }
    if (mounted) {
      setState(() {
        _currentLocation = locationName;
        _zoomLevel = 1.0; // Reset zoom
      });
      debugPrint('Panorama loaded for: $locationName');
    }
  }

  void _dismissHelpOverlay() {
    if (mounted) {
      debugPrint('Got It button pressed, dismissing help overlay');
      setState(() => _showHelpOverlay = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building PanoramaScreen for $_currentLocation');
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;

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
          final fontSizeTitle = (constraints.maxWidth * 0.05).clamp(
            isMobile ? 20.0 : 22.0,
            isDesktop ? 28.0 : 26.0,
          );
          final fontSizeBody = (constraints.maxWidth * 0.035).clamp(
            isMobile ? 14.0 : 15.0,
            isDesktop ? 18.0 : 16.0,
          );
          final maxContentWidth = isDesktop ? 1400.0 : constraints.maxWidth;

          final imagePath =
              AppConstants.panoramaImages[_currentLocation] ??
              AppConstants.fallbackPanoramaImage;
          final hotspots =
              AppConstants.panoramaHotspots[_currentLocation] ?? [];

          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [
                              Colors.black.withOpacity(0.3),
                              Colors.grey.shade900.withOpacity(0.7),
                            ]
                            : [
                              Colors.blue.shade50,
                              Colors.white.withOpacity(0.9),
                            ],
                  ),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isDark ? 10.0 : 6.0,
                      sigmaY: isDark ? 10.0 : 6.0,
                    ),
                    child: Container(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child:
                    _isFullScreen
                        ? Stack(
                          children: [
                            Positioned.fill(
                              child: Panorama(
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      'Error loading panorama image: $error',
                                    );
                                    _showErrorSnackBar(
                                      'Failed to load panorama image',
                                    );
                                    return const Center(
                                      child: Icon(Icons.error, size: 48),
                                    );
                                  },
                                ),
                                zoom: _zoomLevel,
                                hotspots:
                                    hotspots.map((hotspot) {
                                      return Hotspot(
                                        latitude:
                                            hotspot['pitch']?.toDouble() ?? 0.0,
                                        longitude:
                                            hotspot['yaw']?.toDouble() ?? 0.0,
                                        width: isMobile ? 60.0 : 80.0,
                                        height: isMobile ? 60.0 : 80.0,
                                        widget: GestureDetector(
                                          onTap: () {
                                            final newLocation =
                                                hotspot['sceneId'] as String?;
                                            debugPrint(
                                              'Hotspot clicked: $newLocation',
                                            );
                                            if (newLocation != null &&
                                                AppConstants.panoramaImages
                                                    .containsKey(newLocation)) {
                                              _loadPanorama(newLocation);
                                            } else {
                                              _showErrorSnackBar(
                                                'Location $newLocation not available',
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.primaryColor,
                                                  theme.primaryColor
                                                      .withOpacity(0.7),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                hotspot['text']?.toString() ??
                                                    '',
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 12 : 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            Positioned(
                              top: paddingVertical,
                              left: paddingHorizontal,
                              child: _buildControlButton(
                                icon: Icons.arrow_back,
                                onPressed: () {
                                  debugPrint('Back button pressed');
                                  Navigator.pop(context);
                                },
                                tooltip: 'Back',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                            ),
                          ],
                        )
                        : Column(
                          children: [
                            FadeInDown(
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: paddingHorizontal,
                                  vertical: paddingVertical * 0.5,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          isDark
                                              ? Colors.black54
                                              : Colors.grey.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: paddingHorizontal,
                                  vertical: paddingVertical * 0.5,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                        size: isMobile ? 24 : 28,
                                      ),
                                      onPressed: () {
                                        debugPrint('Back button pressed');
                                        Navigator.pop(context);
                                      },
                                      tooltip: 'Back',
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$_currentLocation 360° Tour',
                                        style: GoogleFonts.roboto(
                                          fontSize: fontSizeTitle,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  isDark
                                                      ? Colors.black54
                                                      : Colors.grey.withOpacity(
                                                        0.3,
                                                      ),
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                        size: isMobile ? 24 : 28,
                                      ),
                                      onPressed: () {
                                        debugPrint('Theme toggle pressed');
                                        Provider.of<ThemeProvider>(
                                          context,
                                          listen: false,
                                        ).toggleTheme();
                                      },
                                      tooltip: 'Toggle Theme',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Panorama(
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      'Error loading panorama image: $error',
                                    );
                                    _showErrorSnackBar(
                                      'Failed to load panorama image',
                                    );
                                    return const Center(
                                      child: Icon(Icons.error, size: 48),
                                    );
                                  },
                                ),
                                zoom: _zoomLevel,
                                hotspots:
                                    hotspots.map((hotspot) {
                                      return Hotspot(
                                        latitude:
                                            hotspot['pitch']?.toDouble() ?? 0.0,
                                        longitude:
                                            hotspot['yaw']?.toDouble() ?? 0.0,
                                        width: isMobile ? 60.0 : 80.0,
                                        height: isMobile ? 60.0 : 80.0,
                                        widget: GestureDetector(
                                          onTap: () {
                                            final newLocation =
                                                hotspot['sceneId'] as String?;
                                            debugPrint(
                                              'Hotspot clicked: $newLocation',
                                            );
                                            if (newLocation != null &&
                                                AppConstants.panoramaImages
                                                    .containsKey(newLocation)) {
                                              _loadPanorama(newLocation);
                                            } else {
                                              _showErrorSnackBar(
                                                'Location $newLocation not available',
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.primaryColor,
                                                  theme.primaryColor
                                                      .withOpacity(0.7),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                hotspot['text']?.toString() ??
                                                    '',
                                                style: GoogleFonts.roboto(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 12 : 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 700),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxWidth: maxContentWidth,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: paddingHorizontal,
                                  vertical: paddingVertical,
                                ),
                                child: Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: theme.cardColor.withOpacity(0.95),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Explore $_currentLocation',
                                          style: GoogleFonts.roboto(
                                            fontSize: fontSizeTitle * 0.9,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Experience a fully immersive 360° view of $_currentLocation at Iqra University. '
                                          'Tap hotspots to navigate or view information.',
                                          style: GoogleFonts.roboto(
                                            fontSize: fontSizeBody,
                                            color:
                                                isDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              debugPrint('Learn More pressed');
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => LocationDetailScreen(
                                                        locationName:
                                                            _currentLocation,
                                                        imagePath:
                                                            AppConstants
                                                                .panoramaImages[_currentLocation]!,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Learn More',
                                              style: GoogleFonts.roboto(
                                                fontSize: fontSizeBody,
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
              // Control buttons
              GestureDetector(
                onTap: _toggleControls,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _showControls ? 1.0 : _fadeAnimation.value,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.all(paddingHorizontal),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildControlButton(
                                icon: Icons.zoom_in,
                                onPressed: _zoomIn,
                                tooltip: 'Zoom In',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.zoom_out,
                                onPressed: _zoomOut,
                                tooltip: 'Zoom Out',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.refresh,
                                onPressed: _resetView,
                                tooltip: 'Reset View',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.info_outline,
                                onPressed: _toggleInfoOverlay,
                                tooltip: 'Location Info',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.share,
                                onPressed: _sharePanorama,
                                tooltip: 'Share Panorama',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon:
                                    _isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                onPressed: _toggleFullScreen,
                                tooltip:
                                    _isFullScreen
                                        ? 'Exit Full Screen'
                                        : 'Enter Full Screen',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.help_outline,
                                onPressed: () {
                                  setState(() => _showHelpOverlay = true);
                                },
                                tooltip: 'Show Help',
                                theme: theme,
                                isMobile: isMobile,
                                isEnabled: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Help overlay
              if (_showHelpOverlay)
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: theme.cardColor.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome to the 360° Tour',
                                style: GoogleFonts.roboto(
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '• Drag to rotate the view\n'
                                '• Pinch or use buttons to zoom\n'
                                '• Tap hotspots to navigate or view info\n'
                                '• Tap to show/hide controls',
                                style: GoogleFonts.roboto(
                                  fontSize: fontSizeBody,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _dismissHelpOverlay,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Got It',
                                  style: GoogleFonts.roboto(
                                    fontSize: fontSizeBody,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Info overlay
              if (_showInfoOverlay)
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: theme.cardColor.withOpacity(0.95),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'About $_currentLocation',
                                style: GoogleFonts.roboto(
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Discover the immersive 360° view of $_currentLocation at Iqra University. '
                                'Navigate through hotspots to explore connected areas or learn more about this location.',
                                style: GoogleFonts.roboto(
                                  fontSize: fontSizeBody,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _toggleInfoOverlay,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'Close',
                                  style: GoogleFonts.roboto(
                                    fontSize: fontSizeBody,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required ThemeData theme,
    required bool isMobile,
    required bool isEnabled,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.cardColor.withOpacity(0.95),
        shape: const CircleBorder(),
        elevation: 8,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(40),
          hoverColor: isEnabled ? theme.primaryColor.withOpacity(0.2) : null,
          splashColor: isEnabled ? theme.primaryColor.withOpacity(0.3) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors:
                    isEnabled
                        ? [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.7),
                        ]
                        : [Colors.grey.shade400, Colors.grey.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey.shade500,
              size: isMobile ? 24 : 28,
            ),
          ),
        ),
      ),
    );
  }
}
