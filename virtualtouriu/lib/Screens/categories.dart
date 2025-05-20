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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 900;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Stack(
        children: [
          if (isDesktop)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.shade50,
                    isDark ? Colors.black.withOpacity(0.5) : Colors.white,
                  ],
                ),
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, isDark),
                    const SizedBox(height: 8),
                    _buildAnimatedSearchBar(context),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount =
                            constraints.maxWidth > 900
                                ? 5
                                : constraints.maxWidth > 600
                                ? 4
                                : 3;
                        final spacing = (constraints.maxWidth * 0.00001).clamp(
                          2.0,
                          2.0,
                        );
                        final heightScale = constraints.maxWidth / 1200;

                        final filteredLocations =
                            locationCards
                                .asMap()
                                .entries
                                .where(
                                  (entry) => entry.value.title
                                      .toLowerCase()
                                      .contains(_searchQuery.toLowerCase()),
                                )
                                .toList();

                        if (filteredLocations.isEmpty) {
                          return FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Text(
                                  'No locations found',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.all(spacing),
                          child: MasonryGridView.count(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: spacing,
                            crossAxisSpacing: spacing,
                            itemCount: filteredLocations.length,
                            itemBuilder:
                                (context, index) => _buildGridItem(
                                  context,
                                  filteredLocations[index].key,
                                  theme,
                                  filteredLocations[index].value.title,
                                  filteredLocations[index].value.imagePath,
                                  index,
                                  heightScale,
                                ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Text(
            "Virtual Tour",
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        FadeInDown(
          duration: const Duration(milliseconds: 300),
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
      ],
    );
  }

  Widget _buildAnimatedSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return FadeIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 200),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search locations...',
              hintStyle: GoogleFonts.roboto(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
              prefixIcon: Icon(Icons.search, color: theme.primaryColor),
              filled: true,
              fillColor: theme.cardColor.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: GoogleFonts.roboto(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    int index,
    ThemeData theme,
    String location,
    String imagePath,
    int animationIndex,
    double heightScale,
  ) {
    final isHovered = _hoveredIndex == index;
    final size = MediaQuery.of(context).size;
    final baseHeight =
        index % 3 == 0
            ? 300.0
            : index % 2 == 0
            ? 250.0
            : 200.0;
    final tileHeight = baseHeight * heightScale.clamp(0.7, 1.0);

    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: animationIndex * 50),
      key: ValueKey(index),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => LocationDetailScreen(
                      locationName: location,
                      imagePath: imagePath,
                    ),
              ),
            );
          },
          child: AnimatedScale(
            scale: isHovered ? 1.0008 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              height: tileHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        isHovered
                            ? theme.primaryColor.withOpacity(0.2)
                            : Colors.black.withOpacity(0.15),
                    blurRadius: isHovered ? 3.0 : 6.0,
                    spreadRadius: isHovered ? 1.5 : 0.0,
                    offset: Offset(0, isHovered ? 2.0 : 1.0),
                  ),
                ],
                border: Border.all(
                  color:
                      isHovered
                          ? theme.primaryColor.withOpacity(0.2)
                          : Colors.transparent,
                  width: 2.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey.shade300,
                            child: const Center(child: Text('Image Error')),
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(isHovered ? 0.7 : 0.6),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        location,
                        style: GoogleFonts.roboto(
                          fontSize: size.width * 0.015,
                          fontWeight: FontWeight.w700,
                          color:
                              isHovered
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 3.0,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
