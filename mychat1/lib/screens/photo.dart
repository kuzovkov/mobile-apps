import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:mychat1/modules/user.dart';
import 'package:mychat1/modules/style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final User responseUser;
  const TakePictureScreen({
    Key key,
    @required this.responseUser
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  CameraDescription camera;
  String _error;
  List<File> _images = [];
  int imagesLimit = 4;

  @override
  void initState() {
    initCamera();
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.

  }

   Future<CameraDescription> _getCamera() async{
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
     CameraDescription firstCamera = cameras.first;
    return firstCamera;
  }

  void initCamera(){
    _getCamera().then((camera){
      setState((){
        this.camera = camera;
        this._controller = CameraController(
          // Get a specific camera from the list of available cameras.
          this.camera,
          // Define the resolution to use.
          ResolutionPreset.medium,
        );
        // Next, initialize the controller. This returns a Future.
        this._initializeControllerFuture = this._controller.initialize();
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Make photo for ${widget.responseUser.nickname}'), backgroundColor: Colors.orange),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.orange,
        // Provide an onPressed callback.
        onPressed: _makePhoto,
      ),
    );
  }

  Widget _buildBody(contex){
    return Stack(
      children: <Widget>[
        _buildCameraPreview(context),
        _images.length > 0 ? _buildImagePreview(): Container(),
        _error != null ? _showError(_error) : Container(),
        _images.length > 0 ? _buildSendButton() : Container()
      ],
    );
  }

  Widget _showError(msg){
    return Container(
        child: Center(
            child:
            Text(msg, style: bold24Roboto)
        )
    );
  }

  Widget _buildSendButton(){
    return Positioned(
      child: FloatingActionButton(
          child: Icon(Icons.send),
          backgroundColor: Colors.orange,
          // Provide an onPressed callback.
          onPressed: _sendPhoto,
      ),
      left: 15.0,
      bottom: 15.0,
    );
  }

  Widget _buildCameraPreview(context){
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return CameraPreview(_controller);
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildImagePreview(){
    return Container(
      child: GridView.extent(
          maxCrossAxisExtent: 150,
          padding: const EdgeInsets.all(4),
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          children: _buildGridTileList(_images.length)),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 2.0, color: Colors.grey),
        left: BorderSide(width: 2.0, color: Colors.grey),
        right: BorderSide(width: 2.0, color: Colors.grey),
        bottom: BorderSide(width: 2.0, color: Colors.grey)
    ),
    borderRadius: BorderRadius.circular(2.0),
    shape: BoxShape.rectangle,
      ),
    );
  }

  List<Opacity> _buildGridTileList(int count) => List.generate(
      count, (i) {
        return Opacity(opacity: 0.7, child: Stack(
          alignment: const Alignment(0.6, 0.6),
          children: <Widget>[
            Container(child: Image.file(_images[i])),
            Row(
              children: <Widget>[
            GestureDetector(child: Icon(Icons.delete, size: 50.0), onTap: (){
                _deleteImage(i); setState(() {});
                },
              ),
            GestureDetector(child: Icon(Icons.rotate_right, size: 50.0), onTap: () async {
              File rotatedImage = await FlutterExifRotation.rotateImage(path: _images[i].path);
                _images.removeAt(i);
                _images.add(rotatedImage);
                setState(() {});
                },
              ),
            ],
            )

      ]));
      });

  void _deleteImage(i){
    if (_images.length > i){
      _images.removeAt(i);
    }
  }

  void _sendPhoto(){
    Navigator.pop(context, _images);
  }

  _makePhoto() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);
      if (_images.length < imagesLimit){
        _images.add(File(path));
        print(_images.length);
        setState(() {

        });
      }else{
        Fluttertoast.showToast(msg: "You can't do more than ${imagesLimit} photos!");
      }

      // If the picture was taken, display it on a new screen.
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
      _error = e.toString();
    }
  }
}


