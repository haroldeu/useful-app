class Destination {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String area; // e.g., "Mall of Asia", "Makati CBD", etc.
  final List<String> keywords; // for searching

  Destination({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.keywords,
  });
}
