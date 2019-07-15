import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:survey/screens/photo.dart';
import 'package:survey/screens/result.dart';
import 'package:survey/screens/menu.dart';


enum Sex { male, female }

class SurveyScreen extends StatelessWidget {
  static const String routeName = "/survey";
  static const String _title = "Survey form";

  @override
   Widget build(BuildContext context) {
    return new Scaffold(
      body: new SurveyFormWidget()
      );
  }
}


class SurveyFormWidget extends StatefulWidget {
  static String name = "";
  static String lastName = "";
  static String email = "";
  static DateTime birthday;
  static Sex sex = Sex.male;
  static String birthdayText = "Select bithday";
  static String imagePath = "";

  SurveyFormWidget({Key key}) : super(key: key);
    @override
  _SurveyFormWidgetState createState() => _SurveyFormWidgetState();
}


class _SurveyFormWidgetState extends State<SurveyFormWidget>{

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime(1980),
        firstDate: DateTime(1920, 8),
        lastDate: DateTime(2010));

    if (picked != null)
      setState(() {
        SurveyFormWidget.birthday = picked;
        SurveyFormWidget.birthdayText = "Birthday:  ${SurveyFormWidget.birthday.year}-${SurveyFormWidget.birthday.month}-${SurveyFormWidget.birthday.day}";
      });
  }

  void _fillForm(){
      nameCtl.text = SurveyFormWidget.name;
      lastNameCtl.text = SurveyFormWidget.lastName;
      emailCtl.text = SurveyFormWidget.email;
  }

  var nameCtl = TextEditingController();
  var lastNameCtl = TextEditingController();
  var emailCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // name field
    TextField name = new TextField(
      keyboardType: TextInputType.text,
      onChanged: (String value) {
        try {
          SurveyFormWidget.name = value;
        } catch (exception) {
          SurveyFormWidget.name = "";
        }
      },
      decoration: new InputDecoration(labelText: "Name"),
      controller: nameCtl
    );

    // lastName field
    TextField lastName = new TextField(
      keyboardType: TextInputType.text,
      onChanged: (String value) {
        try {
          SurveyFormWidget.lastName = value;
        } catch (exception) {
          SurveyFormWidget.lastName = "";
        }
      },
      decoration: new InputDecoration(labelText: "LastName"),
      controller: lastNameCtl
    );

    // email field
    TextField email = new TextField(
      keyboardType: TextInputType.emailAddress,
      onChanged: (String value) {
        try {
          SurveyFormWidget.email = value;
        } catch (exception) {
          SurveyFormWidget.email = "";
        }
      },
      decoration: new InputDecoration(labelText: "Email"),
      controller: emailCtl
    );

    // birthday field
    RaisedButton birthdayfld= RaisedButton(
      child: Text("${SurveyFormWidget.birthdayText}"),
      onPressed: () =>_selectDate(context)
    );

    // sex field
    Column sexradio = Column(
      children: <Widget>[
        RadioListTile<Sex>(
          title: const Text('Male'),
          value: Sex.male,
          groupValue: SurveyFormWidget.sex,
          onChanged: (Sex value) { setState((){SurveyFormWidget.sex = value;} );},
        ),
        RadioListTile<Sex>(
          title: const Text('Female'),
          value: Sex.female,
          groupValue: SurveyFormWidget.sex,
          onChanged: (Sex value) { setState((){SurveyFormWidget.sex = value;});},
        ),
      ],
    );


    // Create button
    RaisedButton readyButton = new RaisedButton(
        child: new Text("Ready"),
        onPressed: () {
            print(SurveyFormWidget.name);
            print(SurveyFormWidget.lastName);
            print(SurveyFormWidget.email);
            print(SurveyFormWidget.sex);
            print(SurveyFormWidget.birthday);
            print(SurveyFormWidget.imagePath);
            Navigator.of(context).pushNamed(ResultScreen.routeName);
        });

    // Create button
    RaisedButton photoButton = new RaisedButton(
        child: new Text("Make Photo"),
        onPressed: () {
          setState(() {
            Navigator.of(context).pushNamed(TakePictureScreen.routeName);
          });
        });

    Container container = new Container(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
            children: [name, lastName, email, sexradio, birthdayfld, photoButton, readyButton])

    );

    ListView listview = ListView(
      padding: const EdgeInsets.all(8.0),
      children: <Widget>[container],
    );

    _fillForm();

    return new Scaffold(
        appBar: new AppBar(
          title: new Text(SurveyScreen._title),
          backgroundColor: Color.fromRGBO(100, 100, 100, 0.5),
        ),
        body: listview,
        // Set the nav drawer
        drawer: Menu.getNavDrawer(context, this));
  }

}

