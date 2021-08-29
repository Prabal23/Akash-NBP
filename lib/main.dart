import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:async';

int section = 1;
String SHARED_PREF_USER = "userName";
Color header = Color(0xFF1B8E99);

StreamSubscription internetconnection;
bool isoffline = false;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String user_name = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFromLocal();

    internetconnection = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // whenevery connection status is changed.
      if (result == ConnectivityResult.none) {
        //there is no any connection
        setState(() {
          isoffline = true;
        });
      } else if (result == ConnectivityResult.mobile) {
        //connection is mobile data network
        setState(() {
          isoffline = false;
        });
      } else if (result == ConnectivityResult.wifi) {
        //connection is from wifi
        setState(() {
          isoffline = false;
        });
      }
    });
  }

  getFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_name = prefs.getString(SHARED_PREF_USER);
    });

    print(user_name);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'BP',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          fontFamily: 'Nunito',
        ),
        home: user_name == "" || user_name == null
            ? LoginPage()
            : HomePage(section));
  }

  @override
  dispose() {
    super.dispose();
    internetconnection.cancel();
    //cancel internent connection subscription after you are done
  }
}
