import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  PageController? _controller;
  int _selectedIndex = 0;
  Timer? _shuffleTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    final middleIndex =
        AppConstants.locationCards.isNotEmpty
            ? AppConstants.locationCards.length ~/ 2
            : 0;
    _controller = PageController(
      viewportFraction: 0.57,
      initialPage: middleIndex,
    );
    _selectedIndex = middleIndex;
    _startShuffleTimer();
  }

  void _startShuffleTimer() {
    _shuffleTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!_isInteracting && mounted && _controller != null) {
        final nextIndex =
            (_selectedIndex + 1) % AppConstants.locationCards.length;
        _controller!.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return FutureBuilder<void>(
      future: AppConstants.initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading data: ${snapshot.error}',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.of(context).size;
            final heroHeight = (size.height * 0.35).clamp(200.0, 400.0);
            final paddingHorizontal = (size.width * 0.08).clamp(12.0, 16.0);
            final paddingVertical = (size.height * 0.05).clamp(8.0, 10.0);
            final fontSize = (size.width * 0.05).clamp(20.0, 28.0);
            final cardHeight = (size.height * 0.38).clamp(50.0, 250.0);
            final infoMaxWidth = constraints.maxWidth * 0.9;

            return Stack(
              children: [
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
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: isDark ? 8.0 : 5.0,
                        sigmaY: isDark ? 8.0 : 5.0,
                      ),
                      child: Container(
                        color:
                            isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: SizedBox(
                          height: heroHeight,
                          width: double.infinity,
                          child: HomeScreen.buildHeroSection(
                            context: context,
                            fontSize: fontSize,
                            heightFactor: 0.5,
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        from: 10.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: paddingVertical,
                          ),
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: infoMaxWidth),
                          child: HomeScreen.buildInfoSection(
                            context: context,
                            isMobile: true,
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        from: 10.0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: paddingVertical,
                          ),
                          width: double.infinity,
                          child: HomeScreen.buildCarousel(
                            context: context,
                            cardHeight: cardHeight,
                            controller: _controller!,
                            selectedIndex: _selectedIndex,
                            isInteracting: _isInteracting,
                            onTap: (index) {
                              setState(() {
                                _selectedIndex = index;
                                _isInteracting = false;
                              });
                            },
                            setInteracting:
                                (value) =>
                                    setState(() => _isInteracting = value),
                            onPageChanged:
                                (index) => setState(() {
                                  _selectedIndex = index;
                                  _isInteracting = false;
                                }),
                            isDesktop: false,
                          ),
                        ),
                      ),
                      SizedBox(height: paddingVertical * 2),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
