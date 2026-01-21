import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/route_model.dart';

class GoogleMapsService {
  // TODO: Replace with your actual Google Maps API key
  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  // Get directions between two locations
  Future<DirectionsResult?> getDirections(
    String origin,
    String destination,
  ) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin'
        '&destination=$destination'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'OK' && json['routes'].isNotEmpty) {
          final route = json['routes'][0];
          final legs = route['legs'][0];
          
          final distance = legs['distance']['value']; // in meters
          final duration = legs['duration']['value']; // in seconds
          final steps = legs['steps'] as List;
          
          final instructions = steps.map<String>((step) {
            return step['html_instructions']
                .replaceAll(RegExp(r'<[^>]*>'), ''); // Remove HTML tags
          }).toList();

          return DirectionsResult(
            distance: distance,
            durationSeconds: duration,
            instructions: instructions,
            polylinePoints: route['overview_polyline']['points'],
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }

  // Get distance matrix between multiple points
  Future<List<RouteWithDistance>?> getDistanceToStations(
    String userLocation,
    List<String> stationNames,
  ) async {
    try {
      final destinations = stationNames.join('|');
      final String url =
          'https://maps.googleapis.com/maps/api/distancematrix/json'
          '?origins=$userLocation'
          '&destinations=$destinations'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'OK') {
          final rows = json['rows'][0]['elements'] as List;
          final results = <RouteWithDistance>[];

          for (int i = 0; i < rows.length; i++) {
            final element = rows[i];
            if (element['status'] == 'OK') {
              results.add(RouteWithDistance(
                stationName: stationNames[i],
                distanceMeters: element['distance']['value'],
                durationSeconds: element['duration']['value'],
              ));
            }
          }

          return results;
        }
      }
      return null;
    } catch (e) {
      print('Error getting distance matrix: $e');
      return null;
    }
  }

  // Geocode address to coordinates
  Future<Map<String, double>?> geocodeAddress(String address) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=$address'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['status'] == 'OK' && json['results'].isNotEmpty) {
          final location = json['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'],
            'lng': location['lng'],
          };
        }
      }
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }
}

class DirectionsResult {
  final int distance; // in meters
  final int durationSeconds;
  final List<String> instructions;
  final String polylinePoints;

  DirectionsResult({
    required this.distance,
    required this.durationSeconds,
    required this.instructions,
    required this.polylinePoints,
  });

  String get distanceKm => '${(distance / 1000).toStringAsFixed(2)} km';
  String get duration {
    if (durationSeconds < 60) {
      return '${durationSeconds} secs';
    } else if (durationSeconds < 3600) {
      return '${(durationSeconds / 60).toStringAsFixed(0)} mins';
    } else {
      final hours = durationSeconds ~/ 3600;
      final mins = ((durationSeconds % 3600) / 60).toStringAsFixed(0);
      return '$hours h $mins min';
    }
  }
}

class RouteWithDistance {
  final String stationName;
  final int distanceMeters;
  final int durationSeconds;

  RouteWithDistance({
    required this.stationName,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get distanceDisplay => distanceMeters > 1000
      ? '${(distanceMeters / 1000).toStringAsFixed(2)} km'
      : '${distanceMeters.toStringAsFixed(0)} m';
}
