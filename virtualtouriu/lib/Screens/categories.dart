import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          duration: const Duration(milliseconds: 800),
          child: const Text("Virtual Tour"),
        ),
        centerTitle: true,
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
            tooltip: 'Toggle Theme',
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
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: locations.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 6.0,
              ),
              itemBuilder: (context, index) {
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
                        transform:
                            Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:
                                isHovered
                                    ? [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.7),
                                    ]
                                    : [
                                      theme.cardColor,
                                      theme.cardColor.withOpacity(0.8),
                                    ],
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
                            locations[index],
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
              },
            ),
          );
        },
      ),
    );
  }
}
