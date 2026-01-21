# 🚇 Useful App - Commuter Guide

A comprehensive Flutter-based commuter guide application designed to help users navigate public transportation and find the best routes to popular destinations in Manila and surrounding areas. The app combines real-time location services, interactive maps, and intelligent route planning to make commuting easier.

## ✨ Features

### 🗺️ Journey Planner
- Plan trips to popular destinations including malls, universities, hospitals, and landmarks
- Search for destinations by name or browse by category
- Get detailed step-by-step navigation instructions
- View estimated travel times and distances
- Multi-modal transport options (walking, jeepney, train stations)

### 📍 Nearby Stations
- Interactive map showing your current location
- Find nearby public transport stations (PNR, LRT, MRT)
- Tap markers to view station details
- Real-time location tracking

### 🔍 Route Search
- Search for specific routes between stations
- View detailed route information including:
  - Jeepney routes
  - Train lines (LRT, MRT, PNR)
  - Fare information
  - Operating hours
- Filter and browse all available routes

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.10.7)
- Dart SDK
- Android Studio / Xcode / Visual Studio (depending on target platform)
- Google Maps API key (optional, see setup below)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/useful-app.git
   cd useful-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Windows
   flutter run -d windows
   
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   ```

### Google Maps Setup (Optional)

For enhanced mapping features, you'll need to configure Google Maps API. See [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) for detailed instructions.

**Quick Setup:**
1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable required APIs (Directions, Distance Matrix, Geocoding)
3. Update the API key in:
   - [lib/services/google_maps_service.dart](lib/services/google_maps_service.dart)
   - [web/index.html](web/index.html) (for web builds)

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 🏗️ Project Structure

```
lib/
├── main.dart                          # Application entry point
├── models/                            # Data models
│   ├── destination_model.dart         # Destination data structure
│   ├── journey_model.dart             # Journey planning models
│   ├── route_model.dart               # Route information models
│   └── station_model.dart             # Station data structure
├── screens/                           # UI screens
│   ├── home_screen.dart               # Main navigation screen
│   ├── journey_planner_screen.dart    # Journey planning interface
│   ├── map_screen.dart                # Interactive map view
│   ├── route_details_screen.dart      # Detailed route information
│   └── route_search_screen.dart       # Route search interface
└── services/                          # Business logic & API services
    ├── google_maps_service.dart       # Google Maps integration
    ├── journey_planner_service.dart   # Journey planning logic
    ├── location_service.dart          # Location tracking
    ├── nominatim_service.dart         # OpenStreetMap geocoding
    ├── osrm_service.dart              # Open Source Routing Machine
    └── route_service.dart             # Route management
```

## 🛠️ Technologies & Packages

### Core Dependencies
- **flutter**: Cross-platform UI toolkit
- **google_maps_flutter** (^2.5.0): Google Maps integration
- **flutter_map** (^6.1.0): Alternative map widget
- **geolocator** (^10.1.0): Location services
- **permission_handler** (^11.0.1): Runtime permissions
- **http** (^1.1.0): HTTP requests
- **latlong2** (^0.9.0): Latitude/longitude calculations

### Services Used
- **OSRM (Open Source Routing Machine)**: Free routing service
- **Nominatim**: OpenStreetMap geocoding service
- **Google Maps API** (optional): Enhanced mapping features

## 🗺️ Key Features Explained

### Journey Planning
The app includes pre-configured destinations across Metro Manila:
- **Malls**: MOA, SM Megamall, Ayala Center, Robinsons Place, and more
- **Universities**: UP Diliman, Ateneo, UST, DLSU, and others
- **Hospitals**: Philippine General Hospital, St. Luke's, Makati Med
- **Landmarks**: Rizal Park, Intramuros, Manila Bay

### Route Information
Comprehensive route database covering:
- **PNR Lines**: Metro Manila routes with station stops
- **LRT Lines**: Line 1 and Line 2 with connections
- **MRT Line**: Line 3 route information
- **Jeepney Routes**: Major jeepney corridors

### Location Services
- Real-time GPS tracking
- Permission handling for Android/iOS
- Fallback to manual location selection
- Distance calculations between points

## 🎨 Design

The app uses Material Design 3 with:
- Modern blue color scheme
- Responsive layouts for all screen sizes
- Bottom navigation for easy access
- Interactive cards and smooth animations

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🐛 Known Issues

- Google Maps integration requires API key configuration
- Some features may require location permissions
- Web version may have limited offline capabilities

## 📧 Support

For issues, questions, or suggestions, please open an issue on GitHub.

## 🙏 Acknowledgments

- OpenStreetMap contributors for map data
- OSRM project for routing services
- Flutter community for excellent documentation and packages

---

**Made with ❤️ using Flutter**
