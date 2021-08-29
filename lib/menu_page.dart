import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:option_one_new/attendance.dart';
import 'package:option_one_new/leads.dart';
import 'package:option_one_new/login_page.dart';
import 'package:option_one_new/main.dart';
import 'package:option_one_new/sales.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool isBalance = false;
  String currentTime = "", currentDate = "", user_name = "";
  bool isLoadingCheckout = false, isLoadingLogout = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getFromLocal();
    setState(() {
      Timer(Duration(seconds: 1), () {
        DateTime _date = DateTime.now();
        var dd1 = DateTime.parse(_date.toString());
        var finalDate = "${dd1.day}-${dd1.month}-${dd1.year}";
        var finalDate1 = "${dd1.hour}:${dd1.minute}:${dd1.second}";
        currentDate = finalDate.toString();
        currentTime = finalDate1.toString();
      });
    });
  }

  getFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_name = prefs.getString(SHARED_PREF_USER);
    });

    print(user_name);
  }

  doLogout(String user_name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(user_name);
    final response = await http.post(
      Uri.parse('https://optionone-bd.com/api/logout_api.php'),
      body: {
        'user_name': user_name,
      },
    );
    var recData = json.decode(response.body);
    print(recData);
    setState(() {
      isLoadingLogout = false;
      if (recData["message"] == "Checkout First") {
        // checkout();
      } else {
        if (recData != null) {
          prefs.clear();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        }
      }
    });
  }

  void logout() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    "Sign out",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        fontSize: 15),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Divider(
                    color: Color(0xFF1B8E99),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Text('Do you want to sign out from this app?',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Text(
                            "No",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            isLoadingLogout = true;
                          });
                          doLogout(user_name);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: header.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Text(
                            "Yes",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  doCheckout(String user_name) async {
    print(user_name);
    final response = await http.post(
      Uri.parse('https://optionone-bd.com/api/checkout_api.php'),
      body: {
        'user_name': user_name,
      },
    );
    var recData = json.decode(response.body);
    print(recData);
    setState(() {
      isLoadingCheckout = false;
      if (recData != null) {
        checkoutMsg(recData["message"]);
      }
    });
  }

  void checkoutMsg(String msg) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    "Checkout Alert",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        fontSize: 15),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Divider(
                    color: Color(0xFF1B8E99),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListTile(
                      title:
                          Text(msg, style: TextStyle(color: Colors.grey[500]))),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: header.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Text(
                            "OK",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void checkout() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    "Checkout",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        fontSize: 15),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Divider(
                    color: Color(0xFF1B8E99),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListTile(
                      title: Text('Do you want to checkout now?',
                          style: TextStyle(color: Colors.grey[500]))),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Text(
                            "No",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            isLoadingCheckout = true;
                          });
                          doCheckout(user_name);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: header.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          child: Text(
                            "Yes",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 0.4, color: Colors.grey),
                    color: Colors.white),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.2),
                          borderRadius: BorderRadius.circular(25)),
                      margin: EdgeInsets.only(top: 5),
                      child: Container(
                        padding: EdgeInsets.all(0.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          minRadius: 22,
                          maxRadius: 22,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                          //radius: 68.0,
                          // child: Image.asset(
                          //     'assets/person.png',
                          //     fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 0, right: 0),
                              child: Text(
                                user_name,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 0, top: 3),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 0),
                                    child: Row(
                                      children: <Widget>[
                                        Text("User",
                                            style: TextStyle(
                                                color: Color(0xFF1B8E99),
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.normal)),
                                        // Container(
                                        //     height: 20,
                                        //     width: 20,
                                        //     margin: EdgeInsets.only(
                                        //       left: 5,
                                        //     ),
                                        //     child: Image.asset(
                                        //       section == 1
                                        //           ? 'assets/man.png'
                                        //           : section == 2
                                        //               ? 'assets/doctor.png'
                                        //               : 'assets/transportation.png',
                                        //       fit: BoxFit.cover,
                                        //     )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        logout();
                      },
                      child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(width: 0.4, color: Colors.grey),
                              color: Colors.white),
                          child: isLoadingLogout
                              ? Center(
                                  child: CircularProgressIndicator(
                                  color: header,
                                ))
                              : Row(
                                  children: <Widget>[
                                    Container(
                                        height: 12,
                                        child:
                                            Image.asset('assets/logout.png')),
                                    SizedBox(width: 5),
                                    Text(
                                      "Sign out",
                                      style: TextStyle(
                                          color: header,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )),
                    )
                  ],
                ),
              ),
              Container(
                //padding: EdgeInsets.all(5),
                margin:
                    EdgeInsets.only(top: 25, bottom: 5, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Select from menu",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                              fontSize: 15),
                        ),
                        Container(
                          width: 100,
                          child: Divider(
                            color: Color(0xFF1B8E99),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                child: Column(
                  children: <Widget>[
                    // Container(
                    //   margin: EdgeInsets.only(left: 20, right: 20),
                    //   child: Row(
                    //     children: <Widget>[
                    //       Expanded(
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                     builder: (context) =>
                    //                         DoctorsListPage(1)));
                    //           },
                    //           child: Container(
                    //               height: 120,
                    //               padding: EdgeInsets.all(5),
                    //               margin: EdgeInsets.only(right: 5),
                    //               decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   border: Border.all(
                    //                       width: 0.4, color: Colors.grey),
                    //                   color: Colors.white),
                    //               child: Column(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.center,
                    //                 children: <Widget>[
                    //                   Container(
                    //                       height: 40,
                    //                       child: Image.asset(
                    //                           'assets/doctor.png')),
                    //                   SizedBox(height: 15),
                    //                   Text(
                    //                     "Doctors for Consultancy",
                    //                     style: TextStyle(
                    //                         color: Colors.black45,
                    //                         fontSize: 13,
                    //                         fontWeight: FontWeight.normal),
                    //                   ),
                    //                 ],
                    //               )),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                     builder: (context) =>
                    //                         DoctorsListPage(2)));
                    //           },
                    //           child: Container(
                    //               height: 120,
                    //               padding: EdgeInsets.all(5),
                    //               margin: EdgeInsets.only(left: 5),
                    //               decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(5),
                    //                   border: Border.all(
                    //                       width: 0.4, color: Colors.grey),
                    //                   color: Colors.white),
                    //               child: Column(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.center,
                    //                 children: <Widget>[
                    //                   Container(
                    //                       height: 40,
                    //                       child:
                    //                           Image.asset('assets/d1.png')),
                    //                   SizedBox(height: 15),
                    //                   Text(
                    //                     "Doctors for Visiting",
                    //                     style: TextStyle(
                    //                         color: Colors.black45,
                    //                         fontSize: 13,
                    //                         fontWeight: FontWeight.normal),
                    //                   ),
                    //                 ],
                    //               )),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AttendancePage()));
                              },
                              child: Container(
                                  height: 120,
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          width: 0.4, color: Colors.grey),
                                      color: Colors.white),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          height: 40,
                                          child: Image.asset(
                                              'assets/attendance.png')),
                                      SizedBox(height: 15),
                                      Text(
                                        "Attendance",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SalesPage()));
                              },
                              child: Container(
                                  height: 120,
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          width: 0.4, color: Colors.grey),
                                      color: Colors.white),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          height: 40,
                                          child:
                                              Image.asset('assets/sale.png')),
                                      SizedBox(height: 15),
                                      Text(
                                        "Sales",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LeadsPage()));
                              },
                              child: Container(
                                  height: 120,
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          width: 0.4, color: Colors.grey),
                                      color: Colors.white),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          height: 40,
                                          child:
                                              Image.asset('assets/leads.png')),
                                      SizedBox(height: 15),
                                      Text(
                                        "Leads",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 13,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                checkout();
                              },
                              child: Container(
                                  height: 120,
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          width: 0.4, color: Colors.grey),
                                      color: Colors.white),
                                  child: isLoadingCheckout
                                      ? Center(
                                          child: CircularProgressIndicator(
                                          color: header,
                                        ))
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                                height: 40,
                                                child: Image.asset(
                                                    'assets/checkout.png')),
                                            SizedBox(height: 15),
                                            Text(
                                              "Checkout",
                                              style: TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ],
                                        )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}
