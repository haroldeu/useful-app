class TransportRoute {
  final String id;
  final String name;
  final String type; // 'jeepney', 'mrt', 'lrt'
  final List<String> stops;
  final double fare;

  TransportRoute({
    required this.id,
    required this.name,
    required this.type,
    required this.stops,
    required this.fare,
  });
}
