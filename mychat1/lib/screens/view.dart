import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

// A screen that allows users to view pictire more detail

class ViewScreen extends StatefulWidget {
  final String imageUrl;
  const ViewScreen({
    Key key,
    @required this.imageUrl
  }) : super(key: key);

  @override
  ViewScreenState createState() => ViewScreenState();
}

class ViewScreenState extends State<ViewScreen> {
  double _width;
  double _height;
  double _currWidth;
  double _currHeight;
  GlobalKey _keyImage = GlobalKey();


  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.

  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Image'), backgroundColor: Colors.orange),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save_alt),
        backgroundColor: Colors.orange,
        // Provide an onPressed callback.
        onPressed: _saveImage,
      ),
    );
  }

  Widget _buildBody(contex){
    return Center(
      child:
          _buildNetworkImage(widget.imageUrl, width: _currWidth, height: _currHeight)
    );
  }

  Widget _buildNetworkImage(String url, {double width=200.0, double height=200.0, double border_radius=0.0}){
    if (url == null)
      return Image.asset(
        'assets/img/img_not_available.jpeg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    CachedNetworkImage image = CachedNetworkImage(
          key: _keyImage,
          placeholder: (context, url) => Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
            width: width,
            height: height,
            padding: EdgeInsets.all(70.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(
                Radius.circular(border_radius),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Material(
            child: Image.asset(
              'assets/img/img_not_available.jpeg',
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(border_radius),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          imageUrl: url,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
    return
      GestureDetector(
        child: image,
        onScaleUpdate: (ScaleUpdateDetails e){
          _changeScale(e.scale);
        },
      );
  }

  void _changeScale(scale){
      if (_width == null)
        _width = _getStartSize().width;
      if (_height == null)
        _height = _getStartSize().height;
      _currWidth = _width * scale;
      _currHeight = _height * scale;
      setState(() {

      });
  }

  Size _getStartSize(){
    final RenderBox renderBoxImage = _keyImage.currentContext.findRenderObject();
    final sizeImage = renderBoxImage.size;
    return sizeImage;
  }

  void _saveImage() async {
    var response = await http.get(widget.imageUrl);
    if (response.statusCode == 200){
      try{
        var filePath = await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
        var savedFile= File.fromUri(Uri.file(filePath));
        Fluttertoast.showToast(msg: "File was saved as ${filePath}");
      }catch(e){
        Fluttertoast.showToast(msg: "Error whan save file: ${e.toString()}");
      }
    }else{
      Fluttertoast.showToast(msg: "Error when download file: ${response.body.toString()}");
    }

  }



}


