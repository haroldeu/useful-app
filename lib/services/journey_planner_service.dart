import 'package:geolocator/geolocator.dart';
import '../models/destination_model.dart';
import '../models/journey_model.dart';
import '../models/station_model.dart';
import 'route_service.dart';
import 'osrm_service.dart';

class JourneyPlannerService {
  final RouteService _routeService = RouteService();
  final OsrmService _osrmService = OsrmService();

  // Get all popular destinations in Manila
  List<Destination> getAllDestinations() {
    return [
      // Malls
      Destination(
        id: 'd1',
        name: 'Mall of Asia (MOA)',
        latitude: 14.5536,
        longitude: 120.9389,
        area: 'Pasay City',
        keywords: ['moa', 'mall of asia', 'pasay'],
      ),
      Destination(
        id: 'd2',
        name: 'SM Mall of the South',
        latitude: 14.3507,
        longitude: 120.9837,
        area: 'Las Piñas',
        keywords: ['sm south', 'las piñas'],
      ),
      Destination(
        id: 'd3',
        name: 'Robinsons Place Manila',
        latitude: 14.5957,
        longitude: 120.9732,
        area: 'Ermita',
        keywords: ['robinsons', 'ermita'],
      ),
      Destination(
        id: 'd4',
        name: 'SM Megamall',
        latitude: 14.5827,
        longitude: 121.0634,
        area: 'Mandaluyong',
        keywords: ['megamall', 'mandaluyong'],
      ),
      Destination(
        id: 'd5',
        name: 'Ayala Center Manila',
        latitude: 14.5625,
        longitude: 121.0285,
        area: 'Makati',
        keywords: ['ayala center', 'makati'],
      ),
      Destination(
        id: 'd6',
        name: 'BGC (Bonifacio Global City)',
        latitude: 14.5594,
        longitude: 121.0425,
        area: 'Taguig',
        keywords: ['bgc', 'bonifacio', 'fort bonifacio'],
      ),
      // Landmarks
      Destination(
        id: 'd7',
        name: 'Luneta Park',
        latitude: 14.5794,
        longitude: 120.9789,
        area: 'Manila',
        keywords: ['luneta', 'rizal park'],
      ),
      Destination(
        id: 'd8',
        name: 'Divisoria',
        latitude: 14.5981,
        longitude: 120.9802,
        area: 'Manila',
        keywords: ['divisoria', 'shopping'],
      ),
      Destination(
        id: 'd9',
        name: 'Intramuros',
        latitude: 14.5921,
        longitude: 120.9635,
        area: 'Manila',
        keywords: ['intramuros', 'fort santiago'],
      ),
      Destination(
        id: 'd10',
        name: 'University of the Philippines',
        latitude: 14.6563,
        longitude: 121.0414,
        area: 'Quezon City',
        keywords: ['up', 'diliman', 'university'],
      ),
      Destination(
        id: 'd11',
        name: 'Quezon City Circle',
        latitude: 14.6382,
        longitude: 121.0487,
        area: 'Quezon City',
        keywords: ['qc', 'circle'],
      ),
      Destination(
        id: 'd12',
        name: 'NAIA Airport',
        latitude: 14.5086,
        longitude: 121.0189,
        area: 'Pasay City',
        keywords: ['airport', 'naia'],
      ),
    ];
  }

  // Plan journeys from source to destination
  Future<List<Journey>> planJourneys(
    Position userLocation,
    Destination destination,
  ) async {
    final journeys = <Journey>[];

    // Get real distance and time from OSRM
    final osrmRoute = await _osrmService.getRoute(
      userLocation.latitude,
      userLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    if (osrmRoute != null) {
      // Journey 1: Direct route (best time estimate)
      journeys.add(
        Journey(
          id: 'j1_direct',
          description: 'Direct Route',
          legs: [
            JourneyLeg(
              transportType: 'walk',
              startPoint: 'Your Location',
              endPoint: destination.name,
              startLat: userLocation.latitude,
              startLon: userLocation.longitude,
              endLat: destination.latitude,
              endLon: destination.longitude,
              routeName: 'Walk/Bike/Jeepney',
              price: 25.0,
              durationMinutes: osrmRoute.duration,
              distanceKm: osrmRoute.distance,
              routeCoordinates: osrmRoute.coordinates,
            ),
          ],
          totalPrice: 25.0,
          totalDurationMinutes: osrmRoute.duration,
          totalDistanceKm: osrmRoute.distance,
          transferCount: 0,
          convenienceRating: 'Convenient',
        ),
      );

      // Journey 2: Walk to nearest station + transit
      final nearestStation = _findNearestStation(userLocation);
      if (nearestStation != null) {
        final walkToStation = await _osrmService.getRoute(
          userLocation.latitude,
          userLocation.longitude,
          nearestStation.latitude,
          nearestStation.longitude,
        );

        final stationToDest = await _osrmService.getRoute(
          nearestStation.latitude,
          nearestStation.longitude,
          destination.latitude,
          destination.longitude,
        );

        if (walkToStation != null && stationToDest != null) {
          final totalDuration = walkToStation.duration + stationToDest.duration + 5; // +5 min wait
          final totalDistance = walkToStation.distance + stationToDest.distance;

          journeys.add(
            Journey(
              id: 'j2_transit',
              description: 'Transit via ${nearestStation.name}',
              legs: [
                JourneyLeg(
                  transportType: 'walk',
                  startPoint: 'Your Location',
                  endPoint: nearestStation.name,
                  startLat: userLocation.latitude,
                  startLon: userLocation.longitude,
                  endLat: nearestStation.latitude,
                  endLon: nearestStation.longitude,
                  routeName: 'Walk',
                  price: 0.0,
                  durationMinutes: walkToStation.duration,
                  distanceKm: walkToStation.distance,
                  routeCoordinates: walkToStation.coordinates,
                ),
                JourneyLeg(
                  transportType: nearestStation.type == 'mrt_station' ? 'mrt' : 'lrt',
                  startPoint: nearestStation.name,
                  endPoint: destination.name,
                  startLat: nearestStation.latitude,
                  startLon: nearestStation.longitude,
                  endLat: destination.latitude,
                  endLon: destination.longitude,
                  routeName: nearestStation.type == 'mrt_station' ? 'MRT' : 'LRT',
                  price: 30.0,
                  durationMinutes: stationToDest.duration,
                  distanceKm: stationToDest.distance,
                  routeCoordinates: stationToDest.coordinates,
                ),
              ],
              totalPrice: 30.0,
              totalDurationMinutes: totalDuration,
              totalDistanceKm: totalDistance,
              transferCount: 1,
              convenienceRating: 'Very Convenient',
            ),
          );
        }
      }
    }

    // Sort by convenience score
    journeys.sort((a, b) => a.convenienceScore.compareTo(b.convenienceScore));

    return journeys.isNotEmpty ? journeys : _createFallbackJourneys(userLocation, destination);
  }

  Station? _findNearestStation(Position userLocation) {
    final stations = _routeService.getAllStations();
    final mrtLrtStations = stations
        .where((s) => s.type == 'mrt_station' || s.type == 'lrt_station')
        .toList();

    if (mrtLrtStations.isEmpty) return null;

    Station nearest = mrtLrtStations[0];
    double nearestDistance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      nearest.latitude,
      nearest.longitude,
    );

    for (var station in mrtLrtStations) {
      final distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        station.latitude,
        station.longitude,
      );
      if (distance < nearestDistance) {
        nearest = station;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  /// Fallback method if OSRM fails
  List<Journey> _createFallbackJourneys(
    Position userLocation,
    Destination destination,
  ) {
    final distance = _calculateDistance(userLocation, destination.latitude, destination.longitude);
    
    return [
      Journey(
        id: 'fallback_direct',
        description: 'Direct Route',
        legs: [
          JourneyLeg(
            transportType: 'walk',
            startPoint: 'Your Location',
            endPoint: destination.name,
            startLat: userLocation.latitude,
            startLon: userLocation.longitude,
            endLat: destination.latitude,
            endLon: destination.longitude,
            routeName: 'Walk/Jeepney',
            price: 25.0,
            durationMinutes: ((distance / 1000) / 15 * 60).ceil(),
            distanceKm: distance / 1000,
          ),
        ],
        totalPrice: 25.0,
        totalDurationMinutes: ((distance / 1000) / 15 * 60).ceil(),
        totalDistanceKm: distance / 1000,
        transferCount: 0,
        convenienceRating: 'Convenient',
      ),
    ];
  }

  double _calculateDistance(Position p1, double lat2, double lon2) {
    return Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      lat2,
      lon2,
    );
  }

  // Search destinations by name
  List<Destination> searchDestinations(String query) {
    final queryLower = query.toLowerCase();
    final allDestinations = getAllDestinations();

    return allDestinations
        .where((dest) =>
            dest.name.toLowerCase().contains(queryLower) ||
            dest.area.toLowerCase().contains(queryLower) ||
            dest.keywords.any((kw) => kw.contains(queryLower)))
        .toList();
  }
}
