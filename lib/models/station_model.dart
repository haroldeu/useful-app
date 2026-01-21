class Station {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type; // 'jeepney_stop', 'mrt_station', 'lrt_station'

  Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
  });
}
