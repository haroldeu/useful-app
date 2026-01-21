import '../models/route_model.dart';
import '../models/station_model.dart';

class Journey {
  final String id;
  final String description; // e.g., "LRT + Jeepney"
  final List<JourneyLeg> legs;
  final double totalPrice;
  final int totalDurationMinutes;
  final double totalDistanceKm;
  final int transferCount;
  final String convenienceRating; // "Very Convenient", "Convenient", "Moderate", "Less Convenient"

  Journey({
    required this.id,
    required this.description,
    required this.legs,
    required this.totalPrice,
    required this.totalDurationMinutes,
    required this.totalDistanceKm,
    required this.transferCount,
    required this.convenienceRating,
  });

  // Calculate convenience score (lower is better)
  double get convenienceScore {
    double score = 0;
    score += totalPrice * 0.3; // 30% weight for price
    score += totalDurationMinutes * 0.4; // 40% weight for time
    score += transferCount * 50; // Each transfer adds 50 points
    return score;
  }
}

class JourneyLeg {
  final String transportType; // 'lrt', 'mrt', 'jeepney', 'bus', 'walk'
  final String startPoint;
  final String endPoint;
  final double startLat;
  final double startLon;
  final double endLat;
  final double endLon;
  final String? routeName; // e.g., "LRT Line 1", "EDSA Jeepney"
  final double price;
  final int durationMinutes;
  final double distanceKm;
  final List<List<double>> routeCoordinates; // [[lat, lon], [lat, lon], ...] - actual path coordinates

  JourneyLeg({
    required this.transportType,
    required this.startPoint,
    required this.endPoint,
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
    this.routeName,
    required this.price,
    required this.durationMinutes,
    required this.distanceKm,
    this.routeCoordinates = const [],
  });
}
