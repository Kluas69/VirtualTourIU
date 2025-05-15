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
  scaffoldBackgroundColor: Colors.white,
  secondaryHeaderColor: Colors.transparent,
  primaryColor: Colors.orange,
  cardColor: Colors.white,
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.roboto(color: Colors.black),
    bodyLarge: GoogleFonts.roboto(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
);

final ThemeData _darkTheme = ThemeData(
  secondaryHeaderColor: Colors.transparent,
  scaffoldBackgroundColor: Colors.grey[900],
  primaryColor: Colors.orange,
  cardColor: Colors.grey[850],
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.roboto(color: Colors.white),
    bodyLarge: GoogleFonts.roboto(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
);
