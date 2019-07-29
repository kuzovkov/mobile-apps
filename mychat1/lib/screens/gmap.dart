import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mychat1/modules/auth.dart';


class GMapSample extends StatefulWidget {
  final LocationData currentLocation;
  const GMapSample({
    Key key,
    @required this.currentLocation
  }) : super(key: key);

  @override
  State<GMapSample> createState() => GMapSampleState();
}

class GMapSampleState extends State<GMapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    _createMarker();
    super.initState();
  }

  _createMarker(){
    // creating a new MARKER
    if (Auth.currentUser != null && widget.currentLocation != null){
      final MarkerId markerId = MarkerId(Auth.currentUser.uid);
      final Marker marker = Marker(
        markerId: markerId,
        position: LatLng(
            widget.currentLocation.latitude,
            widget.currentLocation.longitude
        ),
        infoWindow: InfoWindow(title: Auth.currentUser.nickname, snippet: Auth.currentUser.getLastSeen()),
        onTap: () {
          print(markerId);
        },
      );
      markers[markerId] = marker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('Google map sample'), backgroundColor: Colors.orange),
      body: _buildBody(),
    );
  }

  Widget _buildBody(){
    return Flex(children: <Widget>[
        Flexible(child: Stack(
            children: <Widget>[
            _googleMap(),
        _buildMoveButton()
        ],
        )
        ,)
    ],
    direction: Axis.vertical,);
  }

  Widget _buildMoveButton(){
    return Positioned(
      child: FloatingActionButton(
        child: Icon(Icons.home),
        backgroundColor: Colors.orange,
        // Provide an onPressed callback.
        onPressed: _goToCurrentLocation,
        heroTag: "btn2",
      ),
      left: 15.0,
      bottom: 15.0,
    );
  }

  Widget _googleMap(){
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude),
        zoom: 18,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: Set<Marker>.of(markers.values)
    );
  }

  static CameraPosition _locationToCameraPosition(LocationData location, {double zoom=18.0}){
    print(location.longitude);
    print(location.latitude);
    return CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: zoom);
  }

  Future<void> _goToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_locationToCameraPosition(widget.currentLocation)));
  }
}