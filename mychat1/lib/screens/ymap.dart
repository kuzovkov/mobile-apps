import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat1/modules/user.dart';

class YMapSample extends StatefulWidget {
  final LocationData currentLocation;
  const YMapSample({
    Key key,
    @required this.currentLocation
  }) : super(key: key);

  @override
  _YMapSampleState createState() => _YMapSampleState();
}

class _YMapSampleState extends State<YMapSample> {
  YandexMapController _yandexMapController;
  Map<String, Placemark> markers = <String, Placemark>{};
  Firestore firestore = Firestore.instance;
  Map<String, User> _users = {};
  bool _showUsers = false;


  @override
  void initState() {
    super.initState();
  }

  _createMarker(String id, double lat, double lng, String title, String snippet){
    // creating a new MARKER
    _removeMarker(id).then((e){
      Placemark marker = Placemark(
          point: Point(latitude: lat, longitude: lng),
          iconName: 'assets/img/place.png',
          onTap: (latitude, longitude) => print('Tapped me at $latitude,$longitude')
      );
      markers[id] = marker;
    });
  }

  Future<Null> _removeMarker(String id) async {
    if (markers[id] != null && _yandexMapController != null){
      Placemark marker = markers[id];
      await _yandexMapController.removePlacemark(marker);
      markers.remove(id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('Yandex map sample'), backgroundColor: Colors.orange),
      body: _buildBody(),
    );
  }

  Widget _buildYandexMap(){
    return YandexMap(
      onMapCreated: (controller) async {
        _yandexMapController = controller;
        await _syncMarkers();
        await _goToCurrentLocation();
      },
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

  Future<void> _syncMarkers()async{
    if (_yandexMapController != null){
      for (int i=0; i < _yandexMapController.placemarks.length; i++){
        var placemark = _yandexMapController.placemarks[i];
        await _yandexMapController.removePlacemark(placemark);
      }
      for (Placemark marker in List<Placemark>.of(markers.values)){
        await _yandexMapController.addPlacemark(marker);
      }
    }
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
        _syncMarkers();
        return _buildYandexMap();
      },
    );
  }


  Future<void> _goToCurrentLocation() async {
    await _yandexMapController.move(
        point: Point(latitude: widget.currentLocation.latitude, longitude: widget.currentLocation.longitude),
        animation: MapAnimation(smooth: true, duration: 2.0)
    );
  }

  Future<void> _goToLocation(double lat, double lng, {double zoom=18.0}) async {
    await _yandexMapController.move(
        point: Point(latitude: lat, longitude: lng),
        animation: MapAnimation(smooth: true, duration: 2.0)
    );
  }


}