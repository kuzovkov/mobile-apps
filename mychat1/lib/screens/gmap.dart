import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mychat1/modules/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Firestore firestore = Firestore.instance;

  @override
  void initState() {
    //_createMarker(widget.currentLocation.latitude, widget.currentLocation.longitude);
    super.initState();
  }

  _createMarker(String id, double lat, double lng, String title, String snippet){
    // creating a new MARKER
    final MarkerId markerId = MarkerId(id);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: snippet),
      onTap: () {
        print(markerId);
      },
    );
    return marker;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('Google map sample'), backgroundColor: Colors.orange),
      body: _buildUserListOnMap(),
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

  Widget _buildUserListOnMap(){
    return
      Flex(
        children: <Widget>[
          Flexible(
              child:
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('users').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
                  final int userCount = snapshot.data.documents.length;
                  List<DocumentSnapshot> documents = snapshot.data.documents;
                  Set<Marker> markers = {};
                  for (var document in documents){
                    if (document['location'] != null){
                      markers.add(_createMarker(document['id'], document['location']['lat'], document['location']['lng'], document['nicname'], document['email']));
                    }
                  }
                  return GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.currentLocation.latitude, widget.currentLocation.longitude),
                        zoom: 18,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      markers: markers
                  );
                },
              )
          )
        ],
        direction: Axis.vertical,
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