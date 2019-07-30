import 'package:location/location.dart';

class MyLocation extends Object {

  static LocationData currentLocation;
  static Location locationService;

  static getCurrentLocation() async {
    var location = new Location();
// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();
      return currentLocation;
    }  catch (e) {
      print(e.toString());
      currentLocation = null;
    }
  }

  static onChangeLocation(Function callback){
    locationService = new Location();
    locationService.onLocationChanged().listen((LocationData newLocation) {
      if (newLocation.latitude != currentLocation.latitude || newLocation.longitude != currentLocation.longitude){
        print(newLocation.latitude);
        print(newLocation.longitude);
        currentLocation = newLocation;
        callback(newLocation);
      }
    });
  }
}