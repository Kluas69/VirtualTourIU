import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocationCardData {
  final String tag;
  final String title;
  final String imagePath;

  const LocationCardData({
    required this.tag,
    required this.title,
    required this.imagePath,
  });

  factory LocationCardData.fromJson(Map<String, dynamic> json) {
    return LocationCardData(
      tag: json['tag'] as String,
      title: json['title'] as String,
      imagePath: json['imagePath'] as String,
    );
  }
}

class AppAssets {
  static const String mainImage = 'lib/images/main2.jpg';
}

class AppConstants {
  // Static future to cache the initialization
  static final Future<void> initializationFuture = initialize();

  static List<LocationCardData>? _locationCards;
  static List<LocationCardData>? _topFiveCards;
  static Map<String, String>? _panoramaImages;
  static String? _fallbackPanoramaImage;
  static Map<String, List<Map<String, dynamic>>>? _panoramaHotspots;
  static Map<String, List<Map<String, dynamic>>>? _locationFeatures;

  static Future<void> initialize() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/app_data.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Parse locationCards
      _locationCards =
          (jsonData['locationCards'] as List<dynamic>)
              .map(
                (item) =>
                    LocationCardData.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      // Compute topFiveCards
      _topFiveCards = _locationCards?.toSet().take(5).toList();

      // Parse panoramaImages
      _panoramaImages =
          (jsonData['panoramaImages'] as Map<String, dynamic>)
              .cast<String, String>();

      // Parse fallbackPanoramaImage
      _fallbackPanoramaImage = jsonData['fallbackPanoramaImage'] as String;

      // Parse panoramaHotspots
      _panoramaHotspots = (jsonData['panoramaHotspots'] as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>)
                  .map((item) => item as Map<String, dynamic>)
                  .toList(),
            ),
          );

      // Parse locationFeatures
      _locationFeatures = (jsonData['locationFeatures'] as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(
              key,
              (value as List<dynamic>)
                  .map((item) => item as Map<String, dynamic>)
                  .toList(),
            ),
          );
    } catch (e) {
      // Handle errors (e.g., file not found, JSON parsing error)
      print('Error loading app_data.json: $e');
      // Initialize with empty data to prevent crashes
      _locationCards = [];
      _topFiveCards = [];
      _panoramaImages = {};
      _fallbackPanoramaImage = '';
      _panoramaHotspots = {};
      _locationFeatures = {};
    }
  }

  static List<LocationCardData> get locationCards {
    return _locationCards ?? [];
  }

  static List<LocationCardData> get topFiveCards {
    return _topFiveCards ?? [];
  }

  static Map<String, String> get panoramaImages {
    return _panoramaImages ?? {};
  }

  static String get fallbackPanoramaImage {
    return _fallbackPanoramaImage ?? '';
  }

  static Map<String, List<Map<String, dynamic>>> get panoramaHotspots {
    return _panoramaHotspots ?? {};
  }

  static Map<String, List<Map<String, dynamic>>> get locationFeatures {
    return _locationFeatures ?? {};
  }
}
