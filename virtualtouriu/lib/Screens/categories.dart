import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:virtualtouriu/Screens/location_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _hoveredIndex = -1;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Stack(
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
            ),
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
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
                  ),
                ),
              ),
              _buildSearchBar(context),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
                            ? 2
                            : 1;

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

                    return filteredLocations.isEmpty
                        ? FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: Center(
                            child: Text(
                              'No locations found',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GridView.builder(
                            itemCount: filteredLocations.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 3.0,
                                ),
                            itemBuilder:
                                (context, index) => _buildGridItem(
                                  context,
                                  filteredLocations[index].key,
                                  theme,
                                  filteredLocations[index].value,
                                  index,
                                ),
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      delay: const Duration(milliseconds: 100),
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
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    int index,
    ThemeData theme,
    String location,
    int animationIndex,
  ) {
    final isHovered = _hoveredIndex == index;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: Duration(milliseconds: animationIndex * 30),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => LocationDetailScreen(locationName: location),
              ),
            );
          },
          child: AnimatedScale(
            scale: isHovered ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Container(
              padding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        isHovered
                            ? theme.primaryColor.withOpacity(0.4)
                            : Colors.black.withOpacity(0.1),
                    blurRadius: isHovered ? 8.0 : 6.0,
                    offset: Offset(0, isHovered ? 6.0 : 4.0),
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
      ),
    );
  }
}
