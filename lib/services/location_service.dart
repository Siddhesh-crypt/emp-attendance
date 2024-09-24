import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationService {
  Future<Map<String, String>> getCurrentLocation() async {
    // Initialize location service
    Location location = Location();
    LocationData currentLocation = await location.getLocation();

    String coordinates = '${currentLocation.latitude}, ${currentLocation.longitude}';
    String address = 'Unknown Location';

    // Convert coordinates to address using geocoding
    try {
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark placemark = placemarks[0];
        address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      }
    } catch (e) {
      print('Error retrieving address: $e');
    }

    return {'coordinates': coordinates, 'address': address};
  }
}
