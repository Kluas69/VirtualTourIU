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
  double _zoomLevel = 1.0;

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
        _zoomLevel = (_zoomLevel * 0.9).clamp(0.5, 2.0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zoomed in', style: GoogleFonts.roboto(fontSize: 14)),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _zoomOut() {
    if (mounted) {
      setState(() {
        _zoomLevel = (_zoomLevel * 1.1).clamp(0.5, 2.0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zoomed out', style: GoogleFonts.roboto(fontSize: 14)),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetView() {
    if (mounted) {
      setState(() {
        _zoomLevel = 1.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('View reset', style: GoogleFonts.roboto(fontSize: 14)),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
          duration: const Duration(seconds: 1),
        ),
      );
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
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).cardColor.withOpacity(0.95),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.roboto(fontSize: 14)),
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          duration: const Duration(seconds: 2),
        ),
      );
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
        _zoomLevel = 1.0;
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
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 900;
          final isDesktop = constraints.maxWidth >= 900;

          final paddingHorizontal = (size.width * 0.05).clamp(
            isMobile ? 12.0 : 16.0,
            isDesktop ? 48.0 : 24.0,
          );
          final paddingVertical = (size.height * 0.02).clamp(
            isMobile ? 8.0 : 12.0,
            isDesktop ? 24.0 : 16.0,
          );
          final fontSizeTitle = (constraints.maxWidth * 0.05).clamp(
            isMobile ? 18.0 : 20.0,
            isDesktop ? 28.0 : 24.0,
          );
          final fontSizeBody = (constraints.maxWidth * 0.035).clamp(
            isMobile ? 14.0 : 15.0,
            isDesktop ? 18.0 : 16.0,
          );
          final buttonSize = (size.width * 0.12).clamp(40.0, 48.0);
          final maxContentWidth = isDesktop ? 1400.0 : constraints.maxWidth;

          final imagePath =
              AppConstants.panoramaImages[_currentLocation] ??
              AppConstants.fallbackPanoramaImage;
          final hotspotsRaw =
              AppConstants.panoramaHotspots[_currentLocation] ?? [];
          final hotspots =
              hotspotsRaw is List<Map<String, dynamic>>
                  ? hotspotsRaw
                  : hotspotsRaw.map((e) => e as Map<String, dynamic>).toList();

          return Stack(
            children: [
              // Background gradient and blur effect
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                        isDark
                            ? [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.2),
                            ]
                            : [Colors.grey.shade100, Colors.white],
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
              // Main content
              _isFullScreen
                  ? Stack(
                    children: [
                      // Full-screen panorama
                      SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Panorama(
                          zoom: _zoomLevel,
                          minZoom: 0.5,
                          maxZoom: 2.0,
                          sensitivity: 1.0,
                          hotspots:
                              hotspots.map((hotspot) {
                                return Hotspot(
                                  latitude:
                                      (hotspot['pitch'] as num?)?.toDouble() ??
                                      0.0,
                                  longitude:
                                      (hotspot['yaw'] as num?)?.toDouble() ??
                                      0.0,
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
                                            theme.primaryColor.withOpacity(0.7),
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
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          hotspot['text']?.toString() ?? '',
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
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
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
                        ),
                      ),
                      // Back button
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
                          buttonSize: buttonSize,
                          isEnabled: true,
                        ),
                      ),
                      // Location title overlay
                      Positioned(
                        bottom: 16,
                        left: paddingHorizontal,
                        right: paddingHorizontal,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _currentLocation,
                              style: GoogleFonts.roboto(
                                fontSize: fontSizeTitle * 1.2,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 6,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                  : Stack(
                    children: [
                      // Panorama
                      SizedBox(
                        width: double.infinity,
                        height: size.height,
                        child: Panorama(
                          zoom: _zoomLevel,
                          minZoom: 0.5,
                          maxZoom: 2.0,
                          sensitivity: 1.0,
                          hotspots:
                              hotspots.map((hotspot) {
                                return Hotspot(
                                  latitude:
                                      (hotspot['pitch'] as num?)?.toDouble() ??
                                      0.0,
                                  longitude:
                                      (hotspot['yaw'] as num?)?.toDouble() ??
                                      0.0,
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
                                            theme.primaryColor.withOpacity(0.7),
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
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          hotspot['text']?.toString() ?? '',
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
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
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
                        ),
                      ),
                      // Location title overlay
                      Positioned(
                        bottom: 16,
                        left: paddingHorizontal,
                        right: paddingHorizontal,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.black.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _currentLocation,
                              style: GoogleFonts.roboto(
                                fontSize: fontSizeTitle * 1.2,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 6,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      // Back and theme toggle buttons
                      Positioned(
                        top: paddingVertical,
                        left: paddingHorizontal,
                        child: SafeArea(
                          child: _buildControlButton(
                            icon: Icons.arrow_back,
                            onPressed: () {
                              debugPrint('Back button pressed');
                              Navigator.pop(context);
                            },
                            tooltip: 'Back',
                            theme: theme,
                            buttonSize: buttonSize,
                            isEnabled: true,
                          ),
                        ),
                      ),
                      Positioned(
                        top: paddingVertical,
                        right: paddingHorizontal,
                        child: SafeArea(
                          child: _buildControlButton(
                            icon: isDark ? Icons.light_mode : Icons.dark_mode,
                            onPressed: () {
                              debugPrint('Theme toggle pressed');
                              Provider.of<ThemeProvider>(
                                context,
                                listen: false,
                              ).toggleTheme();
                            },
                            tooltip: 'Toggle Theme',
                            theme: theme,
                            buttonSize: buttonSize,
                            isEnabled: true,
                          ),
                        ),
                      ),
                    ],
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
                                buttonSize: buttonSize,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.zoom_out,
                                onPressed: _zoomOut,
                                tooltip: 'Zoom Out',
                                theme: theme,
                                buttonSize: buttonSize,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.refresh,
                                onPressed: _resetView,
                                tooltip: 'Reset View',
                                theme: theme,
                                buttonSize: buttonSize,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.info_outline,
                                onPressed: _toggleInfoOverlay,
                                tooltip: 'Location Info',
                                theme: theme,
                                buttonSize: buttonSize,
                                isEnabled: true,
                              ),
                              const SizedBox(height: 10),
                              _buildControlButton(
                                icon: Icons.share,
                                onPressed: _sharePanorama,
                                tooltip: 'Share Panorama',
                                theme: theme,
                                buttonSize: buttonSize,
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
                                buttonSize: buttonSize,
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
                                buttonSize: buttonSize,
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
                          borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      debugPrint('Learn More pressed');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => LocationDetailScreen(
                                                locationName: _currentLocation,
                                                imagePath:
                                                    AppConstants
                                                        .panoramaImages[_currentLocation]!,
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor
                                          .withOpacity(0.8),
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
                                      'Learn More',
                                      style: GoogleFonts.roboto(
                                        fontSize: fontSizeBody,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
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
    required double buttonSize,
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
            width: buttonSize,
            height: buttonSize,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey.shade500,
              size: buttonSize * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
