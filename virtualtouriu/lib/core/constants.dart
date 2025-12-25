import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocationCardData {
  final String tag;
  final String title;
  final String imagePath;

  LocationCardData({
    required this.tag,
    required this.title,
    required this.imagePath,
  });

  factory LocationCardData.fromJson(Map<String, dynamic> json) {
    return LocationCardData(
      tag: json['tag'] ?? '',
      title: json['title'] ?? '',
      imagePath: json['imagePath'] ?? '',
    );
  }
}

class AppConstants {
  static late List<LocationCardData> locationCards;
  static late Map<String, String> panoramaImages;
  static late String fallbackPanoramaImage;
  static late Map<String, List<Map<String, dynamic>>> panoramaHotspots;
  static late Map<String, List<Map<String, dynamic>>> locationFeatures;

  static Future<void> initialize() async {
    try {
      // 1. Hardcoded local asset images for location cards → super fast loading
      locationCards = [
        LocationCardData(
          tag: "Discover",
          title: "Library",
          imagePath: "lib/images/library.jpg",
        ),
        LocationCardData(
          tag: "Exclusive",
          title: "Play Area",
          imagePath: "lib/images/ground.jpg",
        ),
        LocationCardData(
          tag: "NEW",
          title: "Auditorium",
          imagePath: "lib/images/auditorium.jpg",
        ),
        LocationCardData(
          tag: "NEW",
          title: "Class Rooms",
          imagePath: "lib/images/class.jpg",
        ),
        LocationCardData(
          tag: "Discover",
          title: "Amphitheater",
          imagePath: "lib/images/Amphitheater.jpg",
        ),
        LocationCardData(
          tag: "Discover",
          title: "Cafeteria",
          imagePath: "lib/images/cafe.jpg",
        ),
        LocationCardData(
          tag: "Discover",
          title: "Common Room",
          imagePath: "lib/images/commonroom.jpg",
        ),
        LocationCardData(
          tag: "Discover",
          title: "Playground",
          imagePath: "lib/images/playground.jpg",
        ),
        LocationCardData(
          tag: "Discover",
          title: "Swimming Pool",
          imagePath: "lib/images/swimming.jpg",
        ),
        LocationCardData(
          tag: "Discover",
          title: "Webinar Room",
          imagePath: "lib/images/webinarroom.jpg",
        ),
      ];

      // 2. Load the rest (panoramas, hotspots, features) from JSON
      final String jsonString = await rootBundle.loadString(
        'assets/app_data.json',
      );
      final Map<String, dynamic> json = jsonDecode(jsonString);

      panoramaImages = Map<String, String>.from(json['panoramaImages'] ?? {});

      fallbackPanoramaImage = json['fallbackPanoramaImage'] ?? '';

      final Map<String, dynamic> hotspotsJson = json['panoramaHotspots'] ?? {};
      panoramaHotspots = hotspotsJson.map((key, value) {
        return MapEntry(key, List<Map<String, dynamic>>.from(value));
      });

      final Map<String, dynamic> featuresJson = json['locationFeatures'] ?? {};
      locationFeatures = featuresJson.map((key, value) {
        return MapEntry(key, List<Map<String, dynamic>>.from(value));
      });
    } catch (e) {
      print('Error initializing AppConstants: $e');
      rethrow;
    }
  }

  // Determine view type (WebGL or Panorama)
  static String viewTypeFor(String locationName) {
    if (locationName == 'Class Rooms') {
      return 'webgl';
    }
    return 'panorama';
  }

  // Return WebGL URL if applicable
  static String? webglUrlFor(String locationName) {
    if (locationName == 'Class Rooms') {
      return 'https://virtual-tour-iu.web.app';
    }
    return null;
  }

  // Single future to ensure initialize() is called only once
  static final Future<void> initializationFuture = initialize();
}
