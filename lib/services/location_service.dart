import 'package:location/location.dart';

class LocationService {
  Future<String> getCurrentLocation() async {
    Location location = Location();
    final currentLocation = await location.getLocation();
    return '${currentLocation.latitude}, ${currentLocation.longitude}';
  }
}
