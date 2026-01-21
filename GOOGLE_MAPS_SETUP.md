# Google Maps API Setup Guide

## Step 1: Get Your Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable these APIs:
   - Google Maps Directions API
   - Google Maps Distance Matrix API
   - Google Maps Geocoding API
4. Create an API key (Credentials > Create Credentials > API Key)
5. Copy your API key

## Step 2: Add API Key to Your App

### Option A: For Web (Recommended for testing)
1. Open `web/index.html`
2. Find this line:
   ```html
   <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
   ```
3. Replace `YOUR_API_KEY_HERE` with your actual API key

### Option B: For Android
1. Open `android/app/build.gradle`
2. Add your API key in the manifest

### Option C: For iOS
1. Open `ios/Runner/Info.plist`
2. Add your Google Maps API key

## Step 3: Update the Service

1. Open `lib/services/google_maps_service.dart`
2. Replace this line:
   ```dart
   static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
   ```
3. With your actual API key:
   ```dart
   static const String apiKey = 'AIzaSy...';
   ```

## Step 4: Enable APIs in Console

Make sure these APIs are enabled in your Google Cloud Console:
- ✅ Maps JavaScript API
- ✅ Directions API
- ✅ Distance Matrix API
- ✅ Geocoding API

## Step 5: Test

Run the app:
```bash
flutter run -d edge
```

Try searching for routes like:
- **Vito Cruz** to **Cubao**
- **Baclaran** to **Ayala**

## API Usage Limits

**Free Tier (Default):**
- 25,000 requests/day for Maps API
- 5,000 directions API calls/day
- 100,000 distance matrix elements/day

For more information, visit:
https://developers.google.com/maps/billing-and-pricing

## Troubleshooting

### "Error 403: Permission Denied"
- Check your API key is correct
- Enable the required APIs in Google Cloud Console
- Make sure billing is enabled

### "Error 400: Invalid Request"
- Check the format of origin/destination (should be address or coordinates)
- Verify the API endpoint URL is correct

### CORS Issues (Web Only)
- Add your domain to the API key restrictions
- For localhost testing, use an unrestricted key (not recommended for production)
