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

// Define the list of location cards with unique entries
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
    tag: "Discover",
    title: "Amphitheater",
    imagePath: "lib/images/Amphitheater.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "Cafeteria",
    imagePath: "lib/images/cafe.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "Common Room",
    imagePath: "lib/images/commonroom.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "Playground",
    imagePath: "lib/images/playground.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "Swimming Pool",
    imagePath: "lib/images/swimming.jpg",
  ),
  const LocationCardData(
    tag: "Discover",
    title: "Webinar Room",
    imagePath: "lib/images/webinarroom.jpg",
  ),
];

// Compute the top 5 unique cards (simulating "most searched")
List<LocationCardData> topFiveCards = locationCards.toSet().take(5).toList();

class AppAssets {
  static const String mainImage = 'lib/images/main2.jpg';
}

class AppConstants {
  // Map of location names to their panorama image paths
  static const Map<String, String> panoramaImages = {
    'Library': 'lib/images/panoramas/library_panorama.jpg',
    'Play Area': 'lib/images/panoramas/play_area_panorama.jpg',
    'Auditorium': 'lib/images/panoramas/auditorium_panorama.jpg',
    'Class Rooms': 'lib/images/panoramas/class_rooms_panorama.jpg',
    'Amphitheater': 'lib/images/panoramas/amphitheater_panorama.jpg',
    'Cafeteria': 'lib/images/panoramas/cafeteria_panorama.jpg',
    'Common Room': 'lib/images/panoramas/common_room_panorama.jpg',
    'Playground': 'lib/images/panoramas/playground_panorama.jpg',
    'Swimming Pool': 'lib/images/panoramas/swimming_pool_panorama.jpg',
    'Webinar Room': 'lib/images/panoramas/webinar_room_panorama.jpg',
  };

  // Fallback image path for missing panoramas
  static const String fallbackPanoramaImage =
      'lib/images/panoramas/fallback_panorama.jpg';

  // Map of location names to their hotspot configurations
  static const Map<String, List<Map<String, dynamic>>> panoramaHotspots = {
    'Library': [
      {
        'pitch': 0.0,
        'yaw': 90.0,
        'type': 'scene',
        'sceneId': 'Cafeteria',
        'text': 'Go to Cafeteria',
      },
      {
        'pitch': 10.0,
        'yaw': -45.0,
        'type': 'info',
        'text': 'Library Info Desk',
        'URL': 'https://example.com/library-info',
      },
    ],
    'Cafeteria': [
      {
        'pitch': 0.0,
        'yaw': -90.0,
        'type': 'scene',
        'sceneId': 'Library',
        'text': 'Back to Library',
      },
      {
        'pitch': -10.0,
        'yaw': 30.0,
        'type': 'scene',
        'sceneId': 'Play Area',
        'text': 'Go to Play Area',
      },
    ],
    'Play Area': [
      {
        'pitch': 0.0,
        'yaw': 180.0,
        'type': 'scene',
        'sceneId': 'Cafeteria',
        'text': 'Back to Cafeteria',
      },
      {
        'pitch': 5.0,
        'yaw': 45.0,
        'type': 'scene',
        'sceneId': 'Playground',
        'text': 'Go to Playground',
      },
    ],
    'Auditorium': [
      {
        'pitch': 5.0,
        'yaw': 0.0,
        'type': 'scene',
        'sceneId': 'Class Rooms',
        'text': 'Go to Class Rooms',
      },
      {
        'pitch': -5.0,
        'yaw': 90.0,
        'type': 'info',
        'text': 'Auditorium Info',
        'URL': 'https://example.com/auditorium-info',
      },
    ],
    'Class Rooms': [
      {
        'pitch': 0.0,
        'yaw': -45.0,
        'type': 'scene',
        'sceneId': 'Auditorium',
        'text': 'Back to Auditorium',
      },
      {
        'pitch': 10.0,
        'yaw': 45.0,
        'type': 'scene',
        'sceneId': 'Library',
        'text': 'Go to Library',
      },
    ],
    'Amphitheater': [
      {
        'pitch': 0.0,
        'yaw': 90.0,
        'type': 'scene',
        'sceneId': 'Play Area',
        'text': 'Go to Play Area',
      },
      {
        'pitch': -10.0,
        'yaw': -45.0,
        'type': 'info',
        'text': 'Amphitheater Info',
        'URL': 'https://example.com/amphitheater-info',
      },
    ],
    'Common Room': [
      {
        'pitch': 0.0,
        'yaw': -90.0,
        'type': 'scene',
        'sceneId': 'Cafeteria',
        'text': 'Go to Cafeteria',
      },
      {
        'pitch': 5.0,
        'yaw': 45.0,
        'type': 'scene',
        'sceneId': 'Webinar Room',
        'text': 'Go to Webinar Room',
      },
    ],
    'Playground': [
      {
        'pitch': 0.0,
        'yaw': 180.0,
        'type': 'scene',
        'sceneId': 'Play Area',
        'text': 'Back to Play Area',
      },
      {
        'pitch': -5.0,
        'yaw': -45.0,
        'type': 'scene',
        'sceneId': 'Swimming Pool',
        'text': 'Go to Swimming Pool',
      },
    ],
    'Swimming Pool': [
      {
        'pitch': 0.0,
        'yaw': 45.0,
        'type': 'scene',
        'sceneId': 'Playground',
        'text': 'Back to Playground',
      },
      {
        'pitch': 10.0,
        'yaw': 90.0,
        'type': 'info',
        'text': 'Swimming Pool Info',
        'URL': 'https://example.com/swimming-pool-info',
      },
    ],
    'Webinar Room': [
      {
        'pitch': 0.0,
        'yaw': -45.0,
        'type': 'scene',
        'sceneId': 'Common Room',
        'text': 'Go to Common Room',
      },
      {
        'pitch': 5.0,
        'yaw': 0.0,
        'type': 'info',
        'text': 'Webinar Room Info',
        'URL': 'https://example.com/webinar-room-info',
      },
    ],
  };

  // Map of location names to their features with interactive data
  static final Map<String, List<Map<String, dynamic>>> locationFeatures =
      _initializeLocationFeatures();

  static Map<String, List<Map<String, dynamic>>> _initializeLocationFeatures() {
    return {
      'Library': [
        {
          'title': 'Modern Design',
          'description': 'Sleek architecture with state-of-the-art facilities.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Accessible Location',
          'description':
              'Centrally located for easy access across the H-9 campus.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Extensive Resources',
          'description':
              'Access to a vast collection of books and digital media.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Play Area': [
        {
          'title': 'Open Space',
          'description': 'Spacious area for sports and recreation.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Sports Facilities',
          'description': 'Equipped with modern sports equipment.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Seating Areas',
          'description': 'Comfortable seating for relaxation.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Auditorium': [
        {
          'title': 'Large Capacity',
          'description': 'Accommodates large gatherings and events.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Advanced Audio',
          'description': 'State-of-the-art sound system installed.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Lighting System',
          'description': 'Dynamic lighting for performances.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Class Rooms': [
        {
          'title': 'Smart Technology',
          'description': 'Equipped with smart boards and projectors.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Comfortable Seating',
          'description': 'Ergonomic chairs for long sessions.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Natural Light',
          'description': 'Large windows for a bright environment.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Amphitheater': [
        {
          'title': 'Outdoor Setting',
          'description': 'Open-air venue with scenic views.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Performance Stage',
          'description': 'Ideal for cultural and musical events.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Seating Arrangement',
          'description': 'Tiered seating for optimal viewing.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Cafeteria': [
        {
          'title': 'Diverse Menu',
          'description': 'Offers a wide variety of food options.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Seating Availability',
          'description': 'Ample seating for students and staff.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Clean Environment',
          'description': 'Maintained for hygiene and comfort.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Common Room': [
        {
          'title': 'Relaxation Zone',
          'description': 'A cozy space for students to unwind.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Entertainment',
          'description': 'Equipped with games and media options.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Charging Stations',
          'description': 'Convenient power outlets for devices.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Playground': [
        {
          'title': 'Play Structures',
          'description': 'Safe and fun equipment for all ages.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Safety Features',
          'description': 'Designed with child safety in mind.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Open Area',
          'description': 'Spacious for group activities.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Swimming Pool': [
        {
          'title': 'Lifeguard Service',
          'description': 'Professional supervision for safety.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Clean Facilities',
          'description': 'Well-maintained changing and shower areas.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Poolside Area',
          'description': 'Relaxing area for visitors.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
      'Webinar Room': [
        {
          'title': 'High-Speed Internet',
          'description': 'Ensures seamless virtual meetings.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Video Equipment',
          'description': 'Advanced tools for presentations.',
          'action': () {}, // Placeholder action to be overridden
        },
        {
          'title': 'Soundproofing',
          'description': 'Designed for clear audio quality.',
          'action': () {}, // Placeholder action to be overridden
        },
      ],
    };
  }
}
