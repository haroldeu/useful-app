import 'package:http/http.dart' as http;
import 'dart:convert';

class NominatimService {
  // Nominatim API - Free, no API key needed
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'useful_app/1.0';

  /// Search for locations by name
  /// Returns list of locations with coordinates
  Future<List<LocationResult>> searchLocation(String query) async {
    try {
      final String url = '$_nominatimUrl/search?q=$query&format=json&limit=10&email=contact@example.com';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        return results
            .map((result) => LocationResult.fromJson(result))
            .toList();
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }

  /// Reverse geocoding - get location name from coordinates
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final String url =
          '$_nominatimUrl/reverse?lat=$latitude&lon=$longitude&format=json&email=contact@example.com';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['address']?['city'] ?? result['name'] ?? result['address_type'];
      }
      return null;
    } catch (e) {
      print('Error in reverse geocoding: $e');
      return null;
    }
  }
}

class LocationResult {
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? type; // tourism, amenity, etc.

  LocationResult({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.type,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      name: json['name'] ?? 'Unknown',
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      address: json['display_name'],
      type: json['type'],
    );
  }
}
