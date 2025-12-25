import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';
import 'package:virtualtouriu/core/constants.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  int _hoveredIndex = -1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  Timer? _debounceTimer;
  static final Future<void> _initializationFuture = AppConstants.initialize();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _updateHoveredIndex(int index) {
    if (_hoveredIndex != index && mounted) {
      setState(() => _hoveredIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 900;

    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    'Loading locations...',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              // Premium background with subtle pattern
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDark
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFFFAFAFA),
                      isDark
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFFFFFFF),
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.5),
                            isDark
                                ? Colors.black.withOpacity(0.1)
                                : Colors.white.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Top navigation bar
                    SliverToBoxAdapter(
                      child: _buildTopNavigationBar(
                        context,
                        isDark,
                        themeProvider,
                      ),
                    ),

                    // Hero section
                    SliverToBoxAdapter(
                      child: _buildHeroSection(context, isDark),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: _buildSearchBar(context, theme, isDark),
                    ),

                    // Grid content
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: mediaQuery.size.width * 0.04,
                        vertical: 24,
                      ),
                      sliver: _buildLocationGrid(context, theme, isDesktop),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopNavigationBar(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Back button
          FadeInLeft(
            duration: const Duration(milliseconds: 600),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
            ),
          ),

          const Spacer(),

          // Theme toggle
          FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(isDark),
                    color: isDark ? Colors.amber : Colors.indigo,
                  ),
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDark) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: isMobile ? 24 : 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'VIRTUAL TOUR',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),

          // Title
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Explore Our Campus',
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 36 : 56,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),

          // Description
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Discover every corner of IQRA University through immersive 360° views',
              style: GoogleFonts.roboto(
                fontSize: isMobile ? 16 : 20,
                height: 1.6,
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.7),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, bool isDark) {
    final size = MediaQuery.of(context).size;

    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: 16,
        ),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.roboto(fontSize: 16, letterSpacing: 0.3),
            decoration: InputDecoration(
              hintText: 'Search locations...',
              hintStyle: GoogleFonts.roboto(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                letterSpacing: 0.3,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: theme.primaryColor,
                size: 24,
              ),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.5,
                          ),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationGrid(
    BuildContext context,
    ThemeData theme,
    bool isDesktop,
  ) {
    final filteredLocations =
        AppConstants.locationCards
            .asMap()
            .entries
            .where(
              (entry) => entry.value.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

    if (AppConstants.locationCards.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                'No locations available',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check app_data.json',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredLocations.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                'No locations found',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverMasonryGrid.count(
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemBuilder: (context, index) {
        final entry = filteredLocations[index];
        return _buildGridItem(context, entry.key, theme, entry.value, index);
      },
      childCount: filteredLocations.length,
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    int index,
    ThemeData theme,
    LocationCardData data,
    int animationIndex,
  ) {
    final isHovered = _hoveredIndex == index;
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    // Varied heights for masonry effect
    final baseHeight =
        index % 3 == 0
            ? 350.0
            : index % 2 == 0
            ? 300.0
            : 320.0;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: animationIndex * 50),
      child: MouseRegion(
        onEnter: (_) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 50), () {
            _updateHoveredIndex(index);
          });
        },
        onExit: (_) {
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(milliseconds: 50), () {
            _updateHoveredIndex(-1);
          });
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, _) => FadeTransition(
                      opacity: animation,
                      child: LocationDetailScreen(
                        locationName: data.title,
                        imagePath: data.imagePath,
                        locationData: data,
                      ),
                    ),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: baseHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      isHovered
                          ? theme.primaryColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.15),
                  blurRadius: isHovered ? 20 : 10,
                  spreadRadius: isHovered ? 2 : 0,
                  offset: Offset(0, isHovered ? 8 : 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
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
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                  ),

                  // Gradient overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(isHovered ? 0.7 : 0.5),
                          Colors.black.withOpacity(isHovered ? 0.85 : 0.7),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data.tag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                data.tag.toUpperCase(),
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          Text(
                            data.title,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isHovered) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Explore',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
