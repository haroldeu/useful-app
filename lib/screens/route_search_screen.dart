import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_model.dart';
import '../models/station_model.dart';
import '../services/route_service.dart';
import 'route_details_screen.dart';

class RouteSearchScreen extends StatefulWidget {
  final Station? originStation;

  const RouteSearchScreen({super.key, this.originStation});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final RouteService _routeService = RouteService();
  List<TransportRoute> _searchResults = [];
  bool _isSearching = false;
  bool _showMap = false;
  Station? _originStationData;
  Station? _destinationStationData;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Pre-fill origin if a station was passed
    if (widget.originStation != null) {
      _originController.text = widget.originStation!.name;
    }
  }

  void _searchRoutes() async {
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();

    if (origin.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both origin and destination')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showMap = false;
    });

    print('Searching routes from "$origin" to "$destination"');

    // First try local routes
    final localRoutes = _routeService.findRoutes(origin, destination);

    // Find station data for map visualization
    final allStations = _routeService.getAllStations();
    _originStationData = allStations.cast<Station?>().firstWhere(
      (s) => s != null && s.name.toLowerCase().contains(origin.toLowerCase()),
      orElse: () => null,
    );
    _destinationStationData = allStations.cast<Station?>().firstWhere(
      (s) => s != null && s.name.toLowerCase().contains(destination.toLowerCase()),
      orElse: () => null,
    );

    print('Found ${localRoutes.length} local routes');

    setState(() {
      _searchResults = localRoutes;
      _isSearching = false;
      _showMap = _originStationData != null && _destinationStationData != null;
    });

    if (_searchResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No routes found. Try searching for major stations like Cubao, Ayala, Vito Cruz, etc.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Routes'),
        actions: _searchResults.isNotEmpty && _showMap
            ? [
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: RouteMapView(
                          originStation: _originStationData!,
                          destinationStation: _destinationStationData!,
                          routes: _searchResults,
                        ),
                      ),
                    );
                  },
                  tooltip: 'View on Map',
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _originController,
                  decoration: InputDecoration(
                    hintText: 'Origin (e.g., Cubao)',
                    prefixIcon: const Icon(Icons.my_location),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  readOnly: widget.originStation != null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    hintText: 'Destination (e.g., Fairview)',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSearching ? null : _searchRoutes,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search Routes'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for routes to get started',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final route = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Icon(
                            route.type == 'jeepney'
                                ? Icons.directions_bus
                                : Icons.train,
                            size: 40,
                            color: route.type == 'jeepney'
                                ? Colors.orange
                                : Colors.blue,
                          ),
                          title: Text(
                            route.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('₱${route.fare.toStringAsFixed(2)}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RouteDetailsScreen(route: route),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }
}

class RouteMapView extends StatefulWidget {
  final Station originStation;
  final Station destinationStation;
  final List<TransportRoute> routes;

  const RouteMapView({
    super.key,
    required this.originStation,
    required this.destinationStation,
    required this.routes,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final markers = _buildRouteMarkers();
    final polylines = _buildRoutePolylines();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.routes.length} Routes Found'),
        centerTitle: true,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(
            (widget.originStation.latitude + widget.destinationStation.latitude) /
                2,
            (widget.originStation.longitude +
                    widget.destinationStation.longitude) /
                2,
          ),
          initialZoom: 13,
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
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.originStation.name} → ${widget.destinationStation.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.routes.length} ${widget.routes.length == 1 ? 'route' : 'routes'} available',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildRouteMarkers() {
    return [
      Marker(
        point: LatLng(widget.originStation.latitude,
            widget.originStation.longitude),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.location_on_outlined,
              color: Colors.white, size: 20),
        ),
      ),
      Marker(
        point: LatLng(widget.destinationStation.latitude,
            widget.destinationStation.longitude),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
      ),
    ];
  }

  List<Polyline> _buildRoutePolylines() {
    return widget.routes.map((route) {
      return Polyline(
        points: [
          LatLng(widget.originStation.latitude,
              widget.originStation.longitude),
          LatLng(widget.destinationStation.latitude,
              widget.destinationStation.longitude),
        ],
        color: Colors.blue.withOpacity(0.7),
        strokeWidth: 3,
      );
    }).toList();
  }
}
