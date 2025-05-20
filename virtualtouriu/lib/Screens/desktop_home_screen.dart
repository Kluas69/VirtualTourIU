import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtualtouriu/Screens/HomeScreen.dart';
import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/themes/Themes.dart';
import 'package:animate_do/animate_do.dart';

class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen> {
  PageController? _controller;
  int _selectedIndex = -1;
  Timer? _shuffleTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewportFraction = _computeViewportFraction(
        MediaQuery.of(context).size.width,
      );
      final middleIndex =
          locationCards.isNotEmpty ? locationCards.length ~/ 2 : 0;
      if (mounted) {
        setState(() {
          _controller = PageController(
            viewportFraction: viewportFraction,
            initialPage: middleIndex,
          );
          _selectedIndex = middleIndex;
          _controller!.addListener(() {
            if (_controller!.hasClients) {
              final newIndex = _controller!.page?.round() ?? middleIndex;
              if (newIndex != _selectedIndex) {
                setState(() {
                  _selectedIndex = newIndex;
                  _isInteracting = true;
                });
              }
            }
          });
        });
      }
    });
    _startShuffleTimer();
  }

  double _computeViewportFraction(double width) {
    if (width > 1800) return 0.25;
    if (width > 1400) return 0.40;
    if (width > 1000) return 0.42;
    return 0.45;
  }

  void _startShuffleTimer() {
    _shuffleTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isInteracting && mounted) {
        setState(() => locationCards.shuffle());
      }
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(() {});
    _controller?.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = MediaQuery.of(context).size;
        final heroHeight = (size.height * 0.5).clamp(400.0, 600.0);
        final paddingHorizontal = (size.width * 0.07).clamp(3.0, 6.0);
        final paddingVertical = (size.height * 0.55).clamp(3.0, 6.0);
        final fontSize = (size.width * 0.05).clamp(26.0, 50.0);
        final cardHeight = (size.height * 0.35).clamp(325.0, 1200.0);

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
            ),
            _controller == null
                ? FadeIn(
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
                : SingleChildScrollView(
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
                            heightFactor: 1.0,
                          ),
                        ),
                      ),
                      FadeIn(
                        duration: const Duration(milliseconds: 300),
                        delay: const Duration(milliseconds: 50),
                        child: Divider(
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.5),
                          thickness: 1.0,
                          indent: paddingHorizontal,
                          endIndent: paddingHorizontal,
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 100),
                        delay: const Duration(milliseconds: 50),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: paddingVertical,
                          ),
                          width: double.infinity,
                          child: HomeScreen.buildInfoSection(
                            context: context,
                            isMobile: false,
                          ),
                        ),
                      ),
                      FadeIn(
                        duration: const Duration(milliseconds: 300),
                        delay: const Duration(milliseconds: 150),
                        child: Divider(
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.5),
                          thickness: 1.0,
                          indent: paddingHorizontal,
                          endIndent: paddingHorizontal,
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: paddingVertical * 0.5,
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
                            isDesktop: true,
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
  }
}
