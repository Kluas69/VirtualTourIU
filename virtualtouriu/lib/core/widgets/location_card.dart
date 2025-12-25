// lib/core/widgets/location_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';
import 'package:virtualtouriu/core/constants.dart';

/// Premium Location Card with Material 3 design principles
/// Matches the quality and polish of HomeScreen
class LocationCard extends StatefulWidget {
  final LocationCardData data;
  final bool isHovered;
  final VoidCallback? onTap;

  const LocationCard({
    super.key,
    required this.data,
    this.isHovered = false,
    this.onTap,
  });

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _overlayOpacityAnimation;

  bool _internalHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 20.0,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));

    _overlayOpacityAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  bool get _isHovered => widget.isHovered || _internalHovered;

  String get _shortDescription {
    final features = AppConstants.locationFeatures[widget.data.title] ?? [];
    return features.isNotEmpty
        ? (features[0]['description'] as String? ??
            'Explore this beautiful campus facility')
        : 'Explore this beautiful campus facility';
  }

  void _navigateToDetails() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder:
            (context, animation, _) => FadeTransition(
              opacity: animation,
              child: LocationDetailScreen(
                locationName: widget.data.title,
                imagePath: widget.data.imagePath,
                locationData: widget.data,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _internalHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _internalHovered = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: _navigateToDetails,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 20.0 : 24.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(_isHovered ? 0.3 : 0.0),
                      blurRadius: _elevationAnimation.value,
                      spreadRadius: _isHovered ? 2 : 0,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black.withOpacity(0.15),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    isSmallScreen ? 20.0 : 24.0,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero image
                      Image.asset(
                        widget.data.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        errorBuilder:
                            (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    primaryColor.withOpacity(0.3),
                                    primaryColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Image unavailable',
                                      style: GoogleFonts.roboto(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ),

                      // Premium gradient overlay
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(_isHovered ? 0.6 : 0.4),
                              Colors.black.withOpacity(_isHovered ? 0.8 : 0.7),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),

                      // Premium tag badge
                      if (widget.data.tag.isNotEmpty)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: AnimatedOpacity(
                            opacity: _isHovered ? 1.0 : 0.9,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.data.tag.toUpperCase(),
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Content section
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 20 : 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                widget.data.title,
                                style: GoogleFonts.roboto(
                                  fontSize: isSmallScreen ? 22 : 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 12,
                                      color: Colors.black.withOpacity(0.6),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Description (on hover)
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child:
                                    _isHovered
                                        ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Text(
                                              _shortDescription,
                                              style: GoogleFonts.roboto(
                                                fontSize:
                                                    isSmallScreen ? 13 : 15,
                                                color: Colors.white.withOpacity(
                                                  0.95,
                                                ),
                                                height: 1.5,
                                                letterSpacing: 0.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )
                                        : const SizedBox.shrink(),
                              ),

                              // Explore button (on hover)
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child:
                                    _isHovered
                                        ? Column(
                                          children: [
                                            const SizedBox(height: 20),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withOpacity(0.4),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ElevatedButton(
                                                onPressed: _navigateToDetails,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 28,
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Explore',
                                                      style: GoogleFonts.roboto(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                        : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
