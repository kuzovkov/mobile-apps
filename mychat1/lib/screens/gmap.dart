import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mychat1/modules/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GMapSample extends StatefulWidget {
  final LocationData currentLocation;
  const GMapSample({
    Key key,
    @required this.currentLocation,
  }) : super(key: key);

  @override
  State<GMapSample> createState() => GMapSampleState();
}

class GMapSampleState extends State<GMapSample> {
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Firestore firestore = Firestore.instance;
  Map<String, User> _users = {};
  bool _showUsers = false;

  @override
  void initState() {
    super.initState();
  }

  _createMarker(String id, double lat, double lng, String title, String snippet){
    // creating a new MARKER
    print(title);
    print(snippet);
    final MarkerId markerId = MarkerId(id);
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: title, snippet: snippet),
      onTap: () {
        print(markerId);
      },
    );
    markers[markerId] = marker;
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
            _buildMapWithMarkers(),
            (_showUsers) ? _buildUsersList() : Container(),
            _buildHomeButton(),
            _buildUsersButton()
        ],
        )
        ,)
    ],
    direction: Axis.vertical,);
  }

  Widget _buildHomeButton(){
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

  Widget _buildUsersButton(){
    return Positioned(
      child: FloatingActionButton(
        child: (_showUsers) ? Icon(Icons.clear) : Icon(Icons.list),
        backgroundColor: Colors.orange,
        // Provide an onPressed callback.
        onPressed: (){
          setState(() {
            _showUsers = !_showUsers;
          });
        },
        heroTag: "btn1",
      ),
      right: 15.0,
      bottom: 15.0,
    );
  }

  Widget _buildUsersList(){
    return Opacity(
      child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _users.length,
              itemBuilder: (BuildContext context, int index) {
                User user = List<User>.of(_users.values)[index];
                return Card(
                  color: (user.location != null) ? Colors.white70 : Colors.grey,
                  child: ListTile(
                   leading: user.getUserAvatar(),
                    title: Text(user.nickname),
                    subtitle: Text(user.getLastSeen()),
                    onTap: (){
                     if (user.location != null)
                        _goToLocation(user.location['lat'], user.location['lng']);
                        setState(() {
                          _showUsers = false;
                        });
                    },
                    enabled: (user.location != null) ? true : false,
                  ),
                );
              }

      ),
      opacity: 0.5,
    );
  }

  Widget _buildGoogleMap(){
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

  Widget _buildMapWithMarkers(){
    return StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
          final int userCount = snapshot.data.documents.length;
          List<DocumentSnapshot> documents = snapshot.data.documents;
          if (_users == null)
            _users = {};
          for (var document in documents){
            _users[document['id']] = User.fromDocument(document);
            if (document['location'] != null){
              _createMarker(document['id'], document['location']['lat'], document['location']['lng'], document['nickname'], document['email']);
            }
          }
          return _buildGoogleMap();
        },
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

  Future<void> _goToLocation(double lat, double lng, {double zoom=18.0}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: zoom)));
  }

}