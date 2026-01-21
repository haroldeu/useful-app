import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/destination_model.dart';
import '../models/journey_model.dart';
import '../services/journey_planner_service.dart';
import '../services/location_service.dart';

class JourneyPlannerScreen extends StatefulWidget {
  final Position? initialUserLocation;

  const JourneyPlannerScreen({super.key, this.initialUserLocation});

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  final JourneyPlannerService _plannerService = JourneyPlannerService();
  final LocationService _locationService = LocationService();
  final TextEditingController _destinationController = TextEditingController();

  Position? _userLocation;
  List<Destination> _filteredDestinations = [];
  List<Journey> _suggestedJourneys = [];
  Destination? _selectedDestination;
  bool _isLoading = false;
  bool _showDestinationList = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialUserLocation != null) {
      setState(() {
        _userLocation = widget.initialUserLocation;
      });
    } else {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _userLocation = position;
        });
      }
    }
  }

  void _onDestinationChanged(String value) {
    final allDestinations = _plannerService.getAllDestinations();
    if (value.isEmpty) {
      setState(() {
        _filteredDestinations = [];
        _showDestinationList = false;
      });
    } else {
      setState(() {
        _filteredDestinations = _plannerService.searchDestinations(value);
        _showDestinationList = true;
      });
    }
  }

  void _selectDestination(Destination destination) {
    setState(() {
      _selectedDestination = destination;
      _destinationController.text = destination.name;
      _showDestinationList = false;
      _filteredDestinations = [];
    });
  }

  Future<void> _planJourney() async {
    if (_userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get your location')),
      );
      return;
    }

    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final journeys = await _plannerService.planJourneys(
      _userLocation!,
      _selectedDestination!,
    );

    setState(() {
      _suggestedJourneys = journeys;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Planner'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination Search
              const Text(
                'Where do you want to go?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _destinationController,
                onChanged: _onDestinationChanged,
                decoration: InputDecoration(
                  hintText: 'Search destinations (MOA, BGC, etc.)',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              // Destination suggestions
              if (_showDestinationList && _filteredDestinations.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredDestinations.length,
                    itemBuilder: (context, index) {
                      final dest = _filteredDestinations[index];
                      return ListTile(
                        leading: const Icon(Icons.location_on_outlined, size: 20),
                        title: Text(dest.name),
                        subtitle: Text(dest.area, style: const TextStyle(fontSize: 12)),
                        onTap: () => _selectDestination(dest),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              // Plan Journey Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _planJourney,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Find Best Routes'),
                ),
              ),
              const SizedBox(height: 24),
              // Suggested Journeys
              if (_suggestedJourneys.isNotEmpty) ...[
                const Text(
                  'Best Routes for You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._suggestedJourneys.map((journey) =>
                    _buildJourneyCard(journey)).toList(),
              ] else if (!_isLoading && _selectedDestination != null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('Click "Find Best Routes" to see options'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyCard(Journey journey) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      journey.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      journey.convenienceRating,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getConvenienceColor(journey.convenienceRating),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₱${journey.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Journey details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem(
                  Icons.schedule,
                  '${journey.totalDurationMinutes} mins',
                ),
                _buildDetailItem(
                  Icons.straighten,
                  '${journey.totalDistanceKm.toStringAsFixed(1)} km',
                ),
                _buildDetailItem(
                  Icons.swap_horiz,
                  '${journey.transferCount} transfers',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Visual journey summary (no maps needed)
            if (_userLocation != null && _selectedDestination != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'From: Your Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red[700], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To: ${_selectedDestination!.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            // Legs breakdown
            ..._buildJourneyLegs(journey),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showJourneyMap(journey);
                    },
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('View on Map'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navigate using ${journey.description}')),
                      );
                    },
                    icon: const Icon(Icons.navigation, size: 18),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  List<Widget> _buildJourneyLegs(Journey journey) {
    return journey.legs.asMap().entries.map((entry) {
      final index = entry.key;
      final leg = entry.value;
      final isLast = index == journey.legs.length - 1;

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getTransportColor(leg.transportType),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTransportIcon(leg.transportType),
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leg.startPoint,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      '${leg.durationMinutes} min • ${leg.distanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (leg.routeName != null)
                      Text(
                        leg.routeName!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (leg.price > 0)
                      Text(
                        '₱${leg.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLast) const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  Color _getTransportColor(String transportType) {
    switch (transportType) {
      case 'mrt':
        return Colors.blue;
      case 'lrt':
        return Colors.green;
      case 'jeepney':
        return Colors.orange;
      case 'bus':
        return Colors.purple;
      case 'walk':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransportIcon(String transportType) {
    switch (transportType) {
      case 'mrt':
      case 'lrt':
        return Icons.train;
      case 'jeepney':
        return Icons.directions_bus;
      case 'bus':
        return Icons.bus_alert;
      case 'walk':
        return Icons.directions_walk;
      default:
        return Icons.location_on;
    }
  }

  Color _getConvenienceColor(String rating) {
    switch (rating) {
      case 'Very Convenient':
        return Colors.green;
      case 'Convenient':
        return Colors.blue;
      case 'Moderate':
        return Colors.orange;
      case 'Less Convenient':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showJourneyMap(Journey journey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: _JourneyMapView(journey: journey, userLocation: _userLocation),
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }
}

class _JourneyMapView extends StatelessWidget {
  final Journey journey;
  final Position? userLocation;
  final MapController _mapController = MapController();

  _JourneyMapView({required this.journey, required this.userLocation});

  @override
  Widget build(BuildContext context) {
    final markers = _buildJourneyMarkers();
    final polylines = _buildJourneyPolylines();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Route'),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            userLocation?.latitude ?? 14.5995,
            userLocation?.longitude ?? 121.0034,
          ),
          initialZoom: 14,
          minZoom: 5,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          PolylineLayer(
            polylines: polylines,
          ),
          MarkerLayer(
            markers: markers,
          ),
        ],
      ),
    );
  }

  List<Marker> _buildJourneyMarkers() {
    final markers = <Marker>[];

    // Add user location marker
    if (userLocation != null) {
      markers.add(
        Marker(
          point: LatLng(userLocation!.latitude, userLocation!.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person_pin_circle,
                color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Add journey leg markers
    for (int i = 0; i < journey.legs.length; i++) {
      final leg = journey.legs[i];
      final color = _getTransportColor(leg.transportType);

      markers.add(
        Marker(
          point: LatLng(leg.startLat, leg.startLon),
          width: 35,
          height: 35,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              _getTransportIcon(leg.transportType),
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _buildJourneyPolylines() {
    final polylines = <Polyline>[];

    for (final leg in journey.legs) {
      final points = <LatLng>[];

      // If leg has route coordinates from OSRM, use them for actual path
      if (leg.routeCoordinates.isNotEmpty) {
        for (final coord in leg.routeCoordinates) {
          points.add(LatLng(coord[0], coord[1])); // [lat, lon]
        }
      } else {
        // Fallback: simple line from start to end
        points.add(LatLng(leg.startLat, leg.startLon));
        points.add(LatLng(leg.endLat, leg.endLon));
      }

      if (points.isNotEmpty) {
        polylines.add(
          Polyline(
            points: points,
            color: _getTransportColor(leg.transportType),
            strokeWidth: 6, // Make it thicker and more visible
          ),
        );
      }
    }

    return polylines;
  }

  Color _getTransportColor(String transportType) {
    switch (transportType) {
      case 'mrt':
        return Colors.blue.shade700; // Darker blue for better visibility
      case 'lrt':
        return Colors.green.shade700; // Darker green
      case 'jeepney':
        return Colors.deepOrange.shade600; // Brighter orange-red
      case 'bus':
        return Colors.deepPurple.shade700; // Darker purple
      case 'walk':
        return Colors.red.shade600; // Change from gray to red for visibility
      default:
        return Colors.red.shade600;
    }
  }

  IconData _getTransportIcon(String transportType) {
    switch (transportType) {
      case 'mrt':
      case 'lrt':
        return Icons.train;
      case 'jeepney':
        return Icons.directions_bus;
      case 'bus':
        return Icons.bus_alert;
      case 'walk':
        return Icons.directions_walk;
      default:
        return Icons.location_on;
    }
  }
}
