class LocationCardData {
  final String tag;
  final String title;
  final String imagePath;

  const LocationCardData({
    required this.tag,
    required this.title,
    required this.imagePath,
  });
}

List<LocationCardData> locationCards = [
  const LocationCardData(
    tag: "Discover",
    title: "Library",
    imagePath: "lib/images/library.jpg",
  ),
  const LocationCardData(
    tag: "Exclusive",
    title: "Play Area",
    imagePath: "lib/images/ground.jpg",
  ),
  const LocationCardData(
    tag: "NEW",
    title: "Auditorium",
    imagePath: "lib/images/auditorium.jpg",
  ),
  const LocationCardData(
    tag: "NEW",
    title: "Class Rooms",
    imagePath: "lib/images/class.jpg",
  ),
  const LocationCardData(
    tag: "Exclusive",
    title: "Play Area",
    imagePath: "lib/images/ground.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "Amphitheater",
    imagePath: "lib/images/Amphitheater.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "cafe",
    imagePath: "lib/images/cafe.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "commonroom",
    imagePath: "lib/images/commonroom.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "playground",
    imagePath: "lib/images/playground.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "swimming",
    imagePath: "lib/images/swimming.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "webinarroom",
    imagePath: "lib/images/webinarroom.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "commonroom",
    imagePath: "lib/images/commonroom.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "playground",
    imagePath: "lib/images/playground.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "swimming",
    imagePath: "lib/images/swimming.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "webinarroom",
    imagePath: "lib/images/webinarroom.jpg",
  ),
];

// Compute the top 5 unique cards (simulating "most searched")
List<LocationCardData> topFiveCards = locationCards.toSet().take(5).toList();

class AppAssets {
  static const String mainImage = 'lib/images/main2.jpg';
}

// constants.dart
class AppConstants {
  // Map of location names to their panorama image paths
  // Ensure image files exist in lib/images/panoramas/ with exact filenames (case-sensitive)
  static const Map<String, String> panoramaImages = {
    'Library': 'lib/images/panoramas/library_panorama.jpg',
    'Play Area': 'lib/images/panoramas/play_area_panorama.jpg',
    'Cafeteria': 'lib/images/panoramas/cafeteria_panorama.jpg',
    'Lecture Hall': 'lib/images/panoramas/lecture_hall_panorama.jpg',
    'Computer Lab': 'lib/images/panoramas/computer_lab_panorama.jpg',
  };

  // Fallback image path for missing panoramas
  // Ensure fallback_panorama.jpg exists in lib/images/panoramas/
  static const String fallbackPanoramaImage =
      'lib/images/panoramas/fallback_panorama.jpg';

  // Map of location names to their hotspot configurations
  static const Map<String, List<Map<String, dynamic>>> panoramaHotspots = {
    'Library': [
      {
        'pitch': 0,
        'yaw': 90,
        'type': 'scene',
        'sceneId': 'Cafeteria',
        'text': 'Go to Cafeteria',
      },
      {
        'pitch': 10,
        'yaw': -45,
        'type': 'info',
        'text': 'Library Info Desk',
        'URL': 'https://example.com/library-info',
      },
    ],
    'Cafeteria': [
      {
        'pitch': 0,
        'yaw': -90,
        'type': 'scene',
        'sceneId': 'Library',
        'text': 'Back to Library',
      },
      {
        'pitch': -10,
        'yaw': 30,
        'type': 'scene',
        'sceneId': 'Play Area',
        'text': 'Go to Play Area',
      },
    ],
    'Play Area': [
      {
        'pitch': 0,
        'yaw': 180,
        'type': 'scene',
        'sceneId': 'Cafeteria',
        'text': 'Back to Cafeteria',
      },
    ],
    'Lecture Hall': [
      {
        'pitch': 5,
        'yaw': 0,
        'type': 'info',
        'text': 'Main Stage',
        'URL': 'https://example.com/lecture-hall',
      },
    ],
    'Computer Lab': [
      {
        'pitch': 0,
        'yaw': 45,
        'type': 'scene',
        'sceneId': 'Library',
        'text': 'Go to Library',
      },
    ],
  };
}
