import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/themes/Themes.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WebView platform for Android, iOS, and web
  WebViewPlatform.instance ??= switch (Theme.of(
    WidgetsBinding.instance.rootElement!,
  ).platform) {
    TargetPlatform.android => AndroidWebViewPlatform(),

    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => WebWebViewPlatform(),
    _ => null,
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
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
