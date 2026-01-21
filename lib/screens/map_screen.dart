import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/station_model.dart';
import '../services/location_service.dart';
import '../services/route_service.dart';
import 'route_search_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final RouteService _routeService = RouteService();
  Position? _userLocation;
  List<StationWithDistance> _nearbyStations = [];
  bool _isLoading = true;
  bool _showMap = true; // Changed to true to show map by default
  String? _errorMessage;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getUserLocationAndNearbyStations();
  }

  Future<void> _getUserLocationAndNearbyStations() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = position;
        });
        print('User Location: ${position.latitude}, ${position.longitude}');
        _calculateNearbyStations();
      } else {
        // Ask user to input their location for testing
        _showLocationInputDialog();
      }
    } catch (e) {
      print('Error getting location: $e');
      // Ask user to input their location for testing
      _showLocationInputDialog();
    }
  }

  void _showLocationInputDialog() {
    final latController = TextEditingController();
    final lonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Your Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter your latitude and longitude for testing:'),
            const SizedBox(height: 12),
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Latitude (e.g., 14.5805)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lonController,
              decoration: const InputDecoration(
                labelText: 'Longitude (e.g., 120.9789)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            const Text(
              'Examples:\n'
              '• San Andres, Manila: 14.5805, 120.9789\n'
              '• Vito Cruz: 14.5751, 120.9754\n'
              '• Cubao: 14.6191, 121.0520',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              try {
                final lat = double.parse(latController.text);
                final lon = double.parse(lonController.text);

                setState(() {
                  _userLocation = Position(
                    longitude: lon,
                    latitude: lat,
                    timestamp: DateTime.now(),
                    accuracy: 0,
                    altitude: 0,
                    altitudeAccuracy: 0,
                    heading: 0,
                    headingAccuracy: 0,
                    speed: 0,
                    speedAccuracy: 0,
                  );
                });

                print('User Location (Manual): $lat, $lon');
                _calculateNearbyStations();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid coordinates')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _calculateNearbyStations() {
    if (_userLocation == null) return;

    print('Calculating nearby stations from: ${_userLocation!.latitude}, ${_userLocation!.longitude}');

    // Get only MRT and LRT stations
    final allStations = _routeService.getAllStations();
    final mrtLrtStations = allStations
        .where((station) =>
            station.type == 'mrt_station' || station.type == 'lrt_station')
        .toList();

    // Calculate distance and sort
    final stationsWithDistance = mrtLrtStations.map((station) {
      final distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        station.latitude,
        station.longitude,
      );
      print('${station.name}: ${distance.toStringAsFixed(0)}m');
      return StationWithDistance(station: station, distanceInMeters: distance);
    }).toList();

    stationsWithDistance.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

    setState(() {
      _nearbyStations = stationsWithDistance;
      _isLoading = false;
      _updateMapMarkers();
    });
  }

  void _updateMapMarkers() {
    // This method is kept for compatibility but markers are now built in _buildMapView
  }

  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];

    // Add user location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.person_pin_circle,
                color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Add station markers
    for (int i = 0; i < _nearbyStations.length; i++) {
      final stationWithDistance = _nearbyStations[i];
      final station = stationWithDistance.station;
      final distance = stationWithDistance.distanceInMeters;
      final distanceStr = distance > 1000
          ? '${(distance / 1000).toStringAsFixed(2)} km'
          : '${distance.toStringAsFixed(0)} m';

      final isLrt = station.type == 'lrt_station';
      final color = isLrt ? Colors.green : Colors.blue;

      markers.add(
        Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showStationDetails(station),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                isLrt ? Icons.train : Icons.train_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _showStationDetails(Station station) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  station.type == 'mrt_station' ? Icons.train : Icons.tram,
                  color: station.type == 'mrt_station'
                      ? Colors.blue
                      : Colors.green,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        station.type == 'mrt_station' ? 'MRT Station' : 'LRT Station',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Coordinates: ${station.latitude.toStringAsFixed(4)}, ${station.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          RouteSearchScreen(originStation: station),
                    ),
                  );
                },
                icon: const Icon(Icons.route),
                label: const Text('Find Routes from Here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _animateCameraToUser() {
    if (_userLocation != null) {
      _mapController.move(
        LatLng(_userLocation!.latitude, _userLocation!.longitude),
        15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stations'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
            tooltip: _showMap ? 'Show List' : 'Show Map',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getUserLocationAndNearbyStations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _nearbyStations.isEmpty
                  ? const Center(
                      child: Text('No MRT/LRT stations found nearby'),
                    )
                  : _showMap
                      ? _buildMapView()
                      : _buildListView(),
      floatingActionButton: _showMap && _userLocation != null
          ? FloatingActionButton(
              onPressed: _animateCameraToUser,
              child: const Icon(Icons.location_searching),
              tooltip: 'Go to my location',
            )
          : null,
    );
  }

  Widget _buildMapView() {
    if (_userLocation == null) {
      return const Center(child: Text('Loading map...'));
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(
              _userLocation!.latitude,
              _userLocation!.longitude,
            ),
            initialZoom: 15,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(
              markers: _buildMapMarkers(),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nearby Stations',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Found ${_nearbyStations.length} stations',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showMap = false;
                        });
                      },
                      icon: const Icon(Icons.list, size: 16),
                      label: const Text('List'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nearbyStations.length,
      itemBuilder: (context, index) {
        final stationWithDistance = _nearbyStations[index];
        final station = stationWithDistance.station;
        final distance = stationWithDistance.distanceInMeters;
        final distanceStr = distance > 1000
            ? '${(distance / 1000).toStringAsFixed(2)} km'
            : '${distance.toStringAsFixed(0)} m';
        final walkingTimeMinutes = (distance / 1.4 / 60).ceil();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              station.type == 'mrt_station' ? Icons.train : Icons.tram,
              color: station.type == 'mrt_station' ? Colors.blue : Colors.green,
              size: 32,
            ),
            title: Text(
              station.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Distance: $distanceStr • Walking: ~${walkingTimeMinutes}min',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      RouteSearchScreen(originStation: station),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class StationWithDistance {
  final Station station;
  final double distanceInMeters;

  StationWithDistance({
    required this.station,
    required this.distanceInMeters,
  });
}

