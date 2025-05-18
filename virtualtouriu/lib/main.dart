import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/themes/Themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MyApp...');
    return ChangeNotifierProvider(
      create: (_) {
        debugPrint('Creating ThemeProvider...');
        return ThemeProvider();
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          debugPrint(
            'Building MaterialApp with theme: ${themeProvider.isDark}',
          );
          return MaterialApp(
            title: 'Iqra University Virtual Tour',
            theme: themeProvider.theme,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
