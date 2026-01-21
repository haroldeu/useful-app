import '../models/route_model.dart';
import '../models/station_model.dart';

class RouteService {
  List<TransportRoute> getAllRoutes() {
    return [
      // LRT Line 1 (South to North)
      TransportRoute(
        id: '1',
        name: 'LRT-1: Baclaran - Roosevelt',
        type: 'lrt',
        stops: [
          'Baclaran',
          'Libertad',
          'Gil Puyat',
          'Quirino',
          'Vito Cruz',
          'Legarda',
          'Blumentritt',
          'Central',
          'Monumento',
          'Carriedo',
          'Roosevelt',
        ],
        fare: 20.0,
      ),
      // LRT Line 2 (West to East)
      TransportRoute(
        id: '2',
        name: 'LRT-2: Recto - Cubao',
        type: 'lrt',
        stops: [
          'Recto',
          'Doroteo Jose',
          'J. Ruiz',
          'Gilmore',
          'Betty Go-Belmonte',
          'Cubao',
        ],
        fare: 18.0,
      ),
      // MRT Line 3 (North to South)
      TransportRoute(
        id: '3',
        name: 'MRT-3: North Avenue - Taft',
        type: 'mrt',
        stops: [
          'North Avenue',
          'Quezon Avenue',
          'Kamuning',
          'Cubao MRT',
          'Ortigas',
          'Shaw Boulevard',
          'Boni',
          'Guadalupe',
          'Buendia',
          'Ayala',
          'Makati',
          'Taft Avenue',
        ],
        fare: 25.0,
      ),
      // Connection routes
      TransportRoute(
        id: '4',
        name: 'Vito Cruz to Cubao Connection',
        type: 'lrt',
        stops: [
          'Vito Cruz',
          'Legarda',
          'Blumentritt',
          'Central',
          'Monumento',
          'Carriedo',
          'Recto',
          'Doroteo Jose',
          'J. Ruiz',
          'Gilmore',
          'Betty Go-Belmonte',
          'Cubao',
        ],
        fare: 20.0,
      ),
      TransportRoute(
        id: '5',
        name: 'Vito Cruz to Ayala via MRT',
        type: 'mrt',
        stops: [
          'Vito Cruz',
          'Cubao MRT',
          'Ortigas',
          'Shaw Boulevard',
          'Boni',
          'Guadalupe',
          'Ayala',
        ],
        fare: 22.0,
      ),
      TransportRoute(
        id: '6',
        name: 'Baclaran to Taft Avenue',
        type: 'lrt',
        stops: [
          'Baclaran',
          'Libertad',
          'Gil Puyat',
          'Quirino',
          'Vito Cruz',
          'Legarda',
          'Blumentritt',
          'Central',
          'Monumento',
          'Carriedo',
          'Roosevelt',
        ],
        fare: 20.0,
      ),
    ];
  }

  List<TransportRoute> findRoutes(String origin, String destination) {
    final originLower = origin.toLowerCase().trim();
    final destinationLower = destination.toLowerCase().trim();

    print('Finding routes from: "$originLower" to: "$destinationLower"');

    final results = getAllRoutes().where((route) {
      // Find stops that match origin and destination
      final originStops = route.stops
          .where((stop) =>
              stop.toLowerCase().contains(originLower) ||
              originLower.contains(stop.toLowerCase()))
          .toList();

      final destStops = route.stops
          .where((stop) =>
              stop.toLowerCase().contains(destinationLower) ||
              destinationLower.contains(stop.toLowerCase()))
          .toList();

      // Check if both origin and destination are in the route
      final hasRoute = originStops.isNotEmpty && destStops.isNotEmpty;

      if (hasRoute) {
        print('  ✓ Found route: ${route.name}');
      }

      return hasRoute;
    }).toList();

    print('Total routes found: ${results.length}');
    return results;
  }

  List<Station> getAllStations() {
    return [
      // LRT Line 1 (Southbound/Northbound)
      Station(
        id: '1',
        name: 'Baclaran',
        latitude: 14.5433,
        longitude: 120.9841,
        type: 'lrt_station',
      ),
      Station(
        id: '2',
        name: 'Libertad',
        latitude: 14.5517,
        longitude: 120.9823,
        type: 'lrt_station',
      ),
      Station(
        id: '3',
        name: 'Gil Puyat',
        latitude: 14.5600,
        longitude: 120.9808,
        type: 'lrt_station',
      ),
      Station(
        id: '4',
        name: 'Quirino',
        latitude: 14.5678,
        longitude: 120.9783,
        type: 'lrt_station',
      ),
      Station(
        id: '5',
        name: 'Vito Cruz',
        latitude: 14.5751,
        longitude: 120.9754,
        type: 'lrt_station',
      ),
      Station(
        id: '6',
        name: 'Legarda',
        latitude: 14.5873,
        longitude: 120.9845,
        type: 'lrt_station',
      ),
      Station(
        id: '7',
        name: 'Blumentritt',
        latitude: 14.5971,
        longitude: 120.9876,
        type: 'lrt_station',
      ),
      Station(
        id: '8',
        name: 'Central',
        latitude: 14.6011,
        longitude: 120.9898,
        type: 'lrt_station',
      ),
      Station(
        id: '9',
        name: 'Monumento',
        latitude: 14.6144,
        longitude: 120.9967,
        type: 'lrt_station',
      ),
      Station(
        id: '10',
        name: 'Carriedo',
        latitude: 14.5976,
        longitude: 120.9921,
        type: 'lrt_station',
      ),
      Station(
        id: '11',
        name: 'Roosevelt',
        latitude: 14.5890,
        longitude: 120.9834,
        type: 'lrt_station',
      ),
      // LRT Line 2 (East-West)
      Station(
        id: '12',
        name: 'Recto',
        latitude: 14.5976,
        longitude: 120.9921,
        type: 'lrt_station',
      ),
      Station(
        id: '13',
        name: 'Doroteo Jose',
        latitude: 14.6011,
        longitude: 121.0012,
        type: 'lrt_station',
      ),
      Station(
        id: '14',
        name: 'J. Ruiz',
        latitude: 14.6105,
        longitude: 121.0145,
        type: 'lrt_station',
      ),
      Station(
        id: '15',
        name: 'Gilmore',
        latitude: 14.6180,
        longitude: 121.0234,
        type: 'lrt_station',
      ),
      Station(
        id: '16',
        name: 'Betty Go-Belmonte',
        latitude: 14.6210,
        longitude: 121.0287,
        type: 'lrt_station',
      ),
      Station(
        id: '17',
        name: 'Cubao',
        latitude: 14.6264,
        longitude: 121.0356,
        type: 'lrt_station',
      ),
      // MRT Line 3
      Station(
        id: '18',
        name: 'North Avenue',
        latitude: 14.6456,
        longitude: 121.0389,
        type: 'mrt_station',
      ),
      Station(
        id: '19',
        name: 'Quezon Avenue',
        latitude: 14.6327,
        longitude: 121.0390,
        type: 'mrt_station',
      ),
      Station(
        id: '20',
        name: 'Kamuning',
        latitude: 14.6231,
        longitude: 121.0262,
        type: 'mrt_station',
      ),
      Station(
        id: '21',
        name: 'Cubao MRT',
        latitude: 14.6191,
        longitude: 121.0520,
        type: 'mrt_station',
      ),
      Station(
        id: '22',
        name: 'Ortigas',
        latitude: 14.5944,
        longitude: 121.0556,
        type: 'mrt_station',
      ),
      Station(
        id: '23',
        name: 'Shaw Boulevard',
        latitude: 14.5830,
        longitude: 121.0634,
        type: 'mrt_station',
      ),
      Station(
        id: '24',
        name: 'Boni',
        latitude: 14.5762,
        longitude: 121.0701,
        type: 'mrt_station',
      ),
      Station(
        id: '25',
        name: 'Guadalupe',
        latitude: 14.5678,
        longitude: 121.0792,
        type: 'mrt_station',
      ),
      Station(
        id: '26',
        name: 'Buendia',
        latitude: 14.5564,
        longitude: 121.0186,
        type: 'mrt_station',
      ),
      Station(
        id: '27',
        name: 'Ayala',
        latitude: 14.5639,
        longitude: 121.0244,
        type: 'mrt_station',
      ),
      Station(
        id: '28',
        name: 'Makati',
        latitude: 14.5519,
        longitude: 121.0223,
        type: 'mrt_station',
      ),
      Station(
        id: '29',
        name: 'Taft Avenue',
        latitude: 14.5388,
        longitude: 121.0161,
        type: 'mrt_station',
      ),
    ];
  }
}
