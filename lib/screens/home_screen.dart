import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'route_search_screen.dart';
import 'journey_planner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const JourneyPlannerScreen(),
    const MapScreen(),
    const RouteSearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions),
            label: 'Journey Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Nearby Stations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Route Search',
          ),
        ],
      ),
    );
  }
}
