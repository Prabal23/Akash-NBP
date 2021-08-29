import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:option_one_new/home_page.dart';
import 'package:option_one_new/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  SharedPreferences prefs;

  void _submit() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage(section)));
      // Email & password matched our validation rules
      // and are saved to _email and _password fields.
      // _performLogin();
    }
  }

  _performLogin(String msg) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 17, color: Colors.white),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    msg,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        });
  }

  login() async {
    if (usernameController.text == "") {
      _performLogin("Username field is empty!");
    } else if (passwordController.text == "") {
      _performLogin("Password field is empty!");
    } else {
      setState(() {
        _isLoading = true;
      });
      var dio = Dio();
      final response = await http.post(
        Uri.parse('https://optionone-bd.com/api/login_api.php'),
        body: {
          'user_name': usernameController.text,
          'password': passwordController.text,
        },
      );

      print(response.body);
      print(response.statusCode);
      print(usernameController.text);
      print(passwordController.text);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        // final body = response.body;
        var loginInfo = json.decode(response.body);
        print(loginInfo);
        if (loginInfo["error"] == "400") {
          print("not login");
          _performLogin(loginInfo["message"]);
        } else {
          print("login");
          storeToLocal(loginInfo["user"]["user_name"]);
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePage(section)));
        }
      }
    }
  }

  Future<void> storeToLocal(String user_name) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString(SHARED_PREF_USER, user_name);
  }

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/akash.png',
      width: 200,
    );

    var textFormField = TextFormField(
      controller: usernameController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      //initialValue: 'prabal@gmail.com',
      decoration: InputDecoration(
        icon: const Icon(
          Icons.person,
          color: Colors.black38,
        ),
        hintText: 'Your Username',
        labelText: 'Username',
        labelStyle: TextStyle(color: Color(0xFF1B8E99)),
        contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
        border: InputBorder.none,
      ),
      //validator: _validateEmail,
    );
    final email = textFormField;

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      //initialValue: '230193',
      obscureText: true,
      decoration: InputDecoration(
        icon: const Icon(
          Icons.lock,
          color: Colors.black38,
        ),
        hintText: 'Your Password',
        labelText: 'Password',
        labelStyle: TextStyle(color: Color(0xFF1B8E99)),
        contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 20.0, 10.0),
        border: InputBorder.none,
      ),
      //obscureText: true,
    );

    final loginButton = _isLoading
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              //onPressed: _submit,
              onPressed: () {
                login();
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => HomePage(section)));
              },
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              color: Color(0xFF1B8E99),
              child: Text('Sign In', style: TextStyle(color: Colors.white)),
            ),
          );

    return Scaffold(
      //key: scaffoldKey,
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () {
          exit(0);
        },
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24.0),
            child: Container(
              child: Center(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        isoffline
                            ? Container(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                ),
                                height: 30,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        size: 17, color: Colors.white),
                                    Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        "No internet connection!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                        // logo,
                        Container(child: logo),
                        Container(
                            child: Text("National BP Project",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: header,
                                    fontWeight: FontWeight.normal))),
                        SizedBox(height: 20.0),
                        Container(
                        
                            child: Text("Login to your BP account",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold))),
                        SizedBox(height: 20.0),
                        email,
                        SizedBox(
                          height: 2.0,
                        ),
                        new Divider(color: Colors.grey),
                        SizedBox(height: 0.0),
                        password,
                        SizedBox(
                          height: 0.0,
                        ),
                        new Divider(color: Colors.grey),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            //SizedBox(height: 10),
                            loginButton,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
