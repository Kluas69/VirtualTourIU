import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:virtualtouriu/Reponsive/Responsive_Layout.dart';
import 'package:virtualtouriu/Screens/categories.dart';
import 'package:virtualtouriu/Screens/desktop_home_screen.dart';
import 'package:virtualtouriu/Screens/mobile_home_screen.dart';
import 'package:virtualtouriu/Screens/tablet_home_screen.dart';

import 'package:virtualtouriu/core/constants.dart';
import 'package:virtualtouriu/core/widgets/location_card.dart';
import 'package:virtualtouriu/themes/Themes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Tour'),
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
          ),
        ],
      ),
      body: const ResponsiveLayout(
        mobileBody: MobileHomeScreen(),
        tabletBody: TabletHomeScreen(),
        desktopBody: DesktopHomeScreen(),
      ),
    );
  }

  // Shared Hero Section
  static Widget buildHeroSection(
    BuildContext context, {
    required double fontSize,
    required double heightFactor,
  }) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * heightFactor,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            'lib/images/main.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  child: const Text('Image Missing'),
                ),
          ),
          Container(
            height: double.infinity,
            color: Colors.black.withOpacity(0.4),
          ),
          Positioned(
            bottom: size.height * 0.03,
            left: size.width * 0.05,
            child: Text(
              'IQRA UNIVERSITY',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize.clamp(20, 50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shared Info Section
  static Widget buildInfoSection(
    BuildContext context, {
    required bool isMobile,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "VIRTUAL TOUR",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            "Explore Iqra University",
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            "Take an interactive tour of our modern facilities.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          SizedBox(height: size.height * 0.03),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.015,
              ),
            ),
            child: const Text("Start Tour"),
          ),
        ],
      ),
    );
  }

  // Shared Carousel
  static Widget buildCarousel(
    BuildContext context, {
    required double cardHeight,
    required PageController controller,
    required int tappedIndex,
    required bool isInteracting,
    required Function(int) onTap,
    required Function(bool) setInteracting,
    bool isDesktop = false,
  }) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: cardHeight,
            child:
                locationCards.isEmpty
                    ? const Center(child: Text('No Cards Available'))
                    : ClipRect(
                      child: PageView.builder(
                        clipBehavior: Clip.hardEdge,
                        controller: controller,
                        itemCount: locationCards.length,
                        itemBuilder: (context, index) {
                          return isDesktop
                              ? MouseRegion(
                                onEnter: (_) => setInteracting(true),
                                onExit: (_) => setInteracting(false),
                                child: buildCard(
                                  context,
                                  index,
                                  tappedIndex,
                                  onTap,
                                  setInteracting,
                                ),
                              )
                              : GestureDetector(
                                onTapDown: (_) => setInteracting(true),
                                onTapCancel: () => setInteracting(false),
                                onTap: () => onTap(index),
                                child: buildCard(
                                  context,
                                  index,
                                  tappedIndex,
                                  onTap,
                                  setInteracting,
                                ),
                              );
                        },
                      ),
                    ),
          ),
          Padding(
            padding: EdgeInsets.only(right: size.width * 0.05, top: 10),
            child: SmoothPageIndicator(
              controller: controller,
              count: locationCards.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Theme.of(context).primaryColor,
                dotColor:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.3) ??
                    Colors.grey,
                dotHeight: isDesktop ? 8 : 6,
                dotWidth: isDesktop ? 8 : 6,
                spacing: isDesktop ? 10 : 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Shared Card Builder
  static Widget buildCard(
    BuildContext context,
    int index,
    int tappedIndex,
    Function(int) onTap,
    Function(bool) setInteracting,
  ) {
    final size = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.02),
      transform:
          tappedIndex == index
              ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
              : Matrix4.identity(),
      child: LocationCard(data: locationCards[index]),
    );
  }
}
