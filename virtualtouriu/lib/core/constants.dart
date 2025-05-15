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
    tag: "NEW",
    title: "Class Rooms",
    imagePath: "lib/images/class.jpg",
  ),
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
];
