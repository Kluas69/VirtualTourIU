import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get theme => _isDark ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

final ThemeData _lightTheme = ThemeData(
  scaffoldBackgroundColor: const Color.fromARGB(
    255,
    220,
    221,
    222,
  ), // Soft off-white for clean look
  secondaryHeaderColor: Colors.transparent,
  primaryColor: const Color(0xFF3F51B5), // Deep indigo for primary elements
  colorScheme: ColorScheme.light(
    primary: Color(0xFF3F51B5), // Indigo
    secondary: Color(0xFF26A69A), // Teal accent
    surface: Color(0xFFFFFFFF),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.grey.shade400,
  ),
  cardColor: Colors.white,
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.poppins(
      color: const Color(0xFF212121),
      fontWeight: FontWeight.w400,
      fontSize: 16.0,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: const Color(0xFF212121),
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: const Color(0xFF212121),
      fontWeight: FontWeight.bold,
      fontSize: 24.0,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3F51B5), // Indigo
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: const Color(0xFF3F51B5).withOpacity(0.3),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFF212121),
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    shadowColor: Colors.black.withOpacity(0.1),
  ),
  dividerColor: Colors.grey[300],
);

final ThemeData _darkTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF121212), // Dark grey for depth
  secondaryHeaderColor: Colors.transparent,
  primaryColor: const Color(0xFF5C6BC0), // Lighter indigo for dark mode
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF5C6BC0), // Lighter indigo
    secondary: Color.fromARGB(255, 255, 255, 255), // Teal accent
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.grey.shade100,
  ),
  cardColor: const Color(0xFF1E1E1E),
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.poppins(
      color: const Color(0xFFE0E0E0),
      fontWeight: FontWeight.w400,
      fontSize: 16.0,
    ),
    bodyLarge: GoogleFonts.poppins(
      color: const Color(0xFFE0E0E0),
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: const Color(0xFFE0E0E0),
      fontWeight: FontWeight.bold,
      fontSize: 24.0,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF5C6BC0), // Lighter indigo
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: const Color(0xFF5C6BC0).withOpacity(0.3),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: Color(0xFFE0E0E0),
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    shadowColor: Colors.black.withOpacity(0.2),
  ),
  dividerColor: Colors.grey[800],
);
