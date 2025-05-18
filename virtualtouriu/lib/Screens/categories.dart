import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:virtualtouriu/themes/Themes.dart';

// Categories screen displaying a grid of location options
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _hoveredIndex = -1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isPressed = false;

  // List of location names
  static const List<String> locations = [
    "Amphitheater",
    "Cafe",
    "NLE Lab",
    "Board Room B",
    "Swimming Pool",
    "Lobby Building A",
    "Webinar Room",
    "Takhleeq",
    "Board Room C",
    "Law Moot Room",
    "CSO",
    "Lobby C Building",
    "Auditorium",
    "VIP Room",
    "Lobby Building B",
    "Production Room",
    "Male Gym",
    "Library",
    "Common Room",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          duration: const Duration(milliseconds: 800),
          child: Text(
            "Virtual Tour",
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap:
                () =>
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme(),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color:
                    _isPressed
                        ? theme.primaryColor
                        : isDark
                        ? Colors.white
                        : Colors.black,
                size: 28,
              ),
              onPressed: null, // Handled by GestureDetector
              tooltip: 'Toggle Theme',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid column count
                final crossAxisCount =
                    constraints.maxWidth > 900
                        ? 3
                        : constraints.maxWidth > 600
                        ? 2
                        : 1;

                // Filter locations based on search query
                final filteredLocations =
                    locations
                        .asMap()
                        .entries
                        .where(
                          (entry) => entry.value.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    itemCount: filteredLocations.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 6.0,
                    ),
                    itemBuilder:
                        (context, index) => _buildGridItem(
                          context,
                          filteredLocations[index].key,
                          theme,
                          filteredLocations[index].value,
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builds the search bar for filtering locations
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: FadeInDown(
        duration: const Duration(milliseconds: 600),
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
    );
  }

  // Builds individual grid item with hover and tap effects
  Widget _buildGridItem(
    BuildContext context,
    int index,
    ThemeData theme,
    String location,
  ) {
    final isHovered = _hoveredIndex == index;

    return FadeInUp(
      duration: Duration(milliseconds: 300 + (index * 100)),
      delay: Duration(milliseconds: index * 50),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(
          onTap: () {
            // Add navigation or action here if needed
            // Example: Navigator.push(...);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:
                    isHovered
                        ? [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.7),
                        ]
                        : [theme.cardColor, theme.cardColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color:
                      isHovered
                          ? theme.primaryColor.withOpacity(0.4)
                          : Colors.black.withOpacity(0.1),
                  blurRadius: isHovered ? 7.0 : 6.0,
                  offset: Offset(0, isHovered ? 5.0 : 4.0),
                ),
              ],
              border: Border.all(
                color:
                    isHovered
                        ? theme.primaryColor.withOpacity(0.8)
                        : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                location,
                style: GoogleFonts.roboto(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color:
                      isHovered
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                  shadows:
                      isHovered
                          ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 2.0,
                              offset: const Offset(2, 2),
                            ),
                          ]
                          : [],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
