import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/themes/Themes.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  int _hoveredIndex = -1;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Virtual Tour")),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed:
                () =>
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount =
              constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: locations.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 6.8,
              ),
              itemBuilder: (context, index) {
                final isHovered = _hoveredIndex == index;
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = -1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    decoration: BoxDecoration(
                      color:
                          isHovered
                              ? Theme.of(context).primaryColor.withOpacity(0.2)
                              : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          isHovered
                              ? [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                              : [],
                    ),
                    child: Center(
                      child: Text(
                        locations[index],
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
