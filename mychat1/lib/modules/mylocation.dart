import 'package:location/location.dart';

class MyLocation extends Object {

  static LocationData currentLocation;

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

}