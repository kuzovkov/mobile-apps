import 'package:flutter/material.dart';
import 'package:survey/screens/result.dart';
import 'package:survey/screens/home.dart';
import 'package:survey/screens/survey.dart';
import 'package:survey/screens/view.dart';
import 'package:camera/camera.dart';
import 'package:survey/screens/photo.dart';

Future<void> main() async {
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new HomeScreen(), // route for home is '/' implicitly
    routes: <String, WidgetBuilder>{
      // define the routes
      SurveyScreen.routeName: (BuildContext context) => new SurveyScreen(),
      ResultScreen.routeName: (BuildContext context) => new ResultScreen(),
      ViewScreen.routeName: (BuildContext context) => new ViewScreen(),
      TakePictureScreen.routeName: (BuildContext context) => new TakePictureScreen(camera: firstCamera)
    },
  ));
}