import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';
import 'package:virtualtouriu/core/constants.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _hoveredIndex = -1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isSearchFocused = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  bool _showParallax = true;
  static final Future<void> _initializationFuture = AppConstants.initialize();

  @override
  void initState() {
    super.initState();

    _searchFocusNode.addListener(_onSearchFocusChange);
    _scrollController.addListener(_onScroll);
  }

  void _onSearchFocusChange() {
    if (mounted && _searchFocusNode.hasFocus != _isSearchFocused) {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    }
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Only update parallax when visible (first 500px)
    if (offset < 500 && offset != _scrollOffset) {
      setState(() => _scrollOffset = offset);
    }
    // Disable parallax after scrolling down
    if (offset > 500 && _showParallax) {
      setState(() => _showParallax = false);
    } else if (offset <= 500 && !_showParallax) {
      setState(() => _showParallax = true);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
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
    final isTablet =
        mediaQuery.size.width >= 600 && mediaQuery.size.width < 900;

    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(isDark, theme);
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(isDark, snapshot.error);
        }

        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
          body: Stack(
            children: [
              // Static background - no animations
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
              ),

              // Main scrollable content
              SafeArea(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Floating header bar with blur
                    SliverAppBar(
                      floating: true,
                      pinned: false,
                      snap: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      expandedHeight: 70,
                      collapsedHeight: 70,
                      toolbarHeight: 70,
                      leading: const SizedBox.shrink(),
                      automaticallyImplyLeading: false,
                      flexibleSpace: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.black.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.3),
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      isDark
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.black.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: SafeArea(
                              child: _buildTopNavigationBar(
                                context,
                                isDark,
                                themeProvider,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Hero section with conditional parallax
                    SliverToBoxAdapter(
                      child:
                          _showParallax
                              ? Transform.translate(
                                offset: Offset(0, _scrollOffset * 0.3),
                                child: _buildHeroSection(
                                  context,
                                  isDark,
                                  isDesktop,
                                ),
                              )
                              : _buildHeroSection(context, isDark, isDesktop),
                    ),

                    // Enhanced search bar
                    SliverToBoxAdapter(
                      child: _buildEnhancedSearchBar(
                        context,
                        theme,
                        isDark,
                        isDesktop,
                      ),
                    ),

                    // Quick filters - cached
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        child: _buildQuickFilters(context, theme, isDark),
                      ),
                    ),

                    // Grid content with staggered layout
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            mediaQuery.size.width * (isDesktop ? 0.08 : 0.04),
                        vertical: 24,
                      ),
                      sliver: _buildLocationGrid(
                        context,
                        theme,
                        isDesktop,
                        isTablet,
                      ),
                    ),

                    // Bottom spacing
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen(bool isDark, ThemeData theme) {
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading locations...',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(bool isDark, Object? error) {
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Error: $error',
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

  Widget _buildTopNavigationBar(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.arrow_back_rounded, size: 20),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore Locations',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${AppConstants.locationCards.length} destinations',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Theme toggle
          Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.12)
                        : Colors.black.withOpacity(0.08),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => themeProvider.toggleTheme(),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? Colors.amber : Colors.indigo,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isDark, bool isDesktop) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * (isDesktop ? 0.08 : 0.06),
        vertical: isDesktop ? 48 : 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.15),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.explore_rounded,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'VIRTUAL TOUR',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isDesktop ? 24 : 20),

          // Title
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).textTheme.headlineMedium?.color ??
                        Colors.black,
                    Theme.of(context).primaryColor,
                  ],
                ).createShader(bounds),
            child: Text(
              'Discover IQRA\nUniversity',
              style: GoogleFonts.roboto(
                fontSize: isDesktop ? 64 : 42,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -1.0,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 20 : 16),

          // Description
          Text(
            'Experience every corner of our campus through immersive 360° panoramic views. Choose a location below to begin your virtual journey.',
            style: GoogleFonts.roboto(
              fontSize: isDesktop ? 18 : 16,
              height: 1.7,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.75),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isDesktop,
  ) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * (isDesktop ? 0.08 : 0.06),
        vertical: 12,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color:
                _isSearchFocused
                    ? theme.primaryColor.withOpacity(0.5)
                    : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
            width: _isSearchFocused ? 2 : 1,
          ),
          boxShadow: [
            if (_isSearchFocused)
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.2),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            BoxShadow(
              color:
                  isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
              blurRadius: _isSearchFocused ? 32 : 20,
              offset: Offset(0, _isSearchFocused ? 8 : 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: GoogleFonts.roboto(
            fontSize: 16,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search locations, facilities, buildings...',
            hintStyle: GoogleFonts.roboto(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              letterSpacing: 0.3,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 20, right: 16),
              child: Icon(
                Icons.search_rounded,
                color:
                    _isSearchFocused
                        ? theme.primaryColor
                        : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                size: 24,
              ),
            ),
            suffixIcon:
                _searchQuery.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.close_rounded,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.5),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final filters = ['All', 'Classrooms', 'Labs', 'Facilities', 'Outdoor'];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.06,
        ),
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Padding(
            padding: EdgeInsets.only(right: 12, left: isFirst ? 0 : 0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isFirst
                            ? theme.primaryColor
                            : isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isFirst
                              ? theme.primaryColor
                              : isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    filters[index],
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isFirst
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationGrid(
    BuildContext context,
    ThemeData theme,
    bool isDesktop,
    bool isTablet,
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
      return _buildEmptyState(
        context,
        theme,
        Icons.location_off_rounded,
        'No locations available',
        'Please check app_data.json',
      );
    }

    if (filteredLocations.isEmpty) {
      return _buildEmptyState(
        context,
        theme,
        Icons.search_off_rounded,
        'No locations found',
        'Try adjusting your search',
      );
    }

    final crossAxisCount =
        isDesktop
            ? 4
            : isTablet
            ? 3
            : 2;

    return SliverMasonryGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: isDesktop ? 20 : 16,
      crossAxisSpacing: isDesktop ? 20 : 16,
      itemBuilder: (context, index) {
        final entry = filteredLocations[index];
        return RepaintBoundary(
          child: _buildGridItem(context, entry.key, theme, entry.value, index),
        );
      },
      childCount: filteredLocations.length,
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  Widget _buildGridItem(
    BuildContext context,
    int index,
    ThemeData theme,
    LocationCardData data,
    int animationIndex,
  ) {
    final isHovered = _hoveredIndex == index;
    final isDark = theme.brightness == Brightness.dark;
    final baseHeight =
        index % 3 == 0
            ? 360.0
            : index % 2 == 0
            ? 310.0
            : 330.0;

    return MouseRegion(
      onEnter: (_) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
          _updateHoveredIndex(index);
        });
      },
      onExit: (_) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 100), () {
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
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: baseHeight,
          transform: Matrix4.identity()..translate(0.0, isHovered ? -8.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:
                    isHovered
                        ? theme.primaryColor.withOpacity(0.4)
                        : Colors.black.withOpacity(0.12),
                blurRadius: isHovered ? 32 : 16,
                spreadRadius: isHovered ? 4 : 0,
                offset: Offset(0, isHovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                AnimatedScale(
                  scale: isHovered ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Image.asset(
                    data.imagePath,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    cacheHeight: 800,
                    errorBuilder:
                        (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primaryColor.withOpacity(0.4),
                                theme.primaryColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              size: 56,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                  ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(isHovered ? 0.65 : 0.45),
                        Colors.black.withOpacity(isHovered ? 0.85 : 0.75),
                      ],
                    ),
                  ),
                ),

                // Content
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag badge
                        if (data.tag.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              data.tag.toUpperCase(),
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                        // Title
                        Text(
                          data.title,
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 0.2,
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

                        // Hover action
                        if (isHovered)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Explore Now',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 360° indicator badge
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.threesixty_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '360°',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
      ),
    );
  }
}
