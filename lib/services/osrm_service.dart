import 'package:http/http.dart' as http;
import 'dart:convert';

class OsrmService {
  // OSRM API - Free, no API key needed
  static const String _osrmUrl = 'https://router.project-osrm.org';

  /// Get route between two points
  /// Returns distance in km and duration in minutes
  Future<RouteResult?> getRoute(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) async {
    try {
      // Add geojson=true to get unencoded coordinates
      final String url =
          '$_osrmUrl/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        
        if (result['routes'] != null && result['routes'].isNotEmpty) {
          final route = result['routes'][0];
          
          return RouteResult(
            distance: (route['distance'] as num).toDouble() / 1000, // Convert to km
            duration: ((route['duration'] as num).toDouble() / 60).toInt(), // Convert to minutes
            coordinates: _parseCoordinates(route['geometry']),
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting route from OSRM: $e');
      return null;
    }
  }

  /// Get distance matrix between multiple points
  /// Useful for finding nearest stations
  Future<Map<String, dynamic>?> getDistanceMatrix(
    List<List<double>> coordinates,
  ) async {
    try {
      // Format: lon1,lat1;lon2,lat2;lon3,lat3...
      final coordString = coordinates
          .map((coord) => '${coord[1]},${coord[0]}')
          .join(';');

      final String url = '$_osrmUrl/table/v1/driving/$coordString';

      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting distance matrix from OSRM: $e');
      return null;
    }
  }

  /// Parse coordinates from OSRM geometry response
  /// Now supports GeoJSON format after requesting geometries=geojson
  List<List<double>> _parseCoordinates(dynamic geometry) {
    List<List<double>> coordinates = [];
    
    try {
      if (geometry is String) {
        // Encoded polyline string
        print('Note: Geometry returned as encoded polyline');
        return coordinates;
      }
      
      if (geometry is Map<String, dynamic>) {
        // GeoJSON format
        final type = geometry['type'] as String?;
        
        if (type == 'LineString') {
          final coords = geometry['coordinates'] as List?;
          if (coords != null) {
            for (var coord in coords) {
              if (coord is List && coord.length >= 2) {
                // GeoJSON is [longitude, latitude]
                coordinates.add([
                  (coord[1] as num).toDouble(), // latitude
                  (coord[0] as num).toDouble(), // longitude
                ]);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing geometry: $e');
    }
    
    return coordinates;
  }
}

class RouteResult {
  final double distance; // in km
  final int duration; // in minutes
  final List<List<double>> coordinates; // [[lat, lon], ...]

  RouteResult({
    required this.distance,
    required this.duration,
    required this.coordinates,
  });

  /// Calculate walking time (1.4 m/s average)
  int getWalkingTime(double distanceKm) {
    return (distanceKm * 1000 / 1.4 / 60).ceil();
  }

  /// Estimate transit time for jeepney/bus (15 km/h average)
  int getJeepneyTime(double distanceKm) {
    return (distanceKm / 15 * 60).ceil();
  }

  /// Estimate MRT/LRT time (30 km/h average + waiting)
  int getTransitTime(double distanceKm) {
    return ((distanceKm / 30 * 60) + 5).ceil(); // +5 min wait time
  }
}
