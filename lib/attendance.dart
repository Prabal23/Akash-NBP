import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:option_one_new/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _date = DateTime.now();
  var dd, finalDate;
  String date = "Select Date",
      bp_code = "",
      job_type = "",
      job_area = "",
      user_name = "",
      attendObj = "attendObj";
  File fileImage;
  final ImagePicker _picker = ImagePicker();
  var attendanceList, attendanceBulk;
  bool isLoading = true, nodata = false, isAddData = false;
  String latitude = '00.00000';
  String longitude = '00.00000';
  List items = ["Retail Shop", "D2D", "kiosk Activation"];
  TextEditingController bpCodeController = new TextEditingController();
  TextEditingController jobAreaController = new TextEditingController();
  TextEditingController jobTypeController = new TextEditingController();
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getFromLocal();
  }

  getFromLocal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_name = prefs.getString(SHARED_PREF_USER);
    });
    getAttendanceData(user_name);

    print(user_name);
  }

  getAttendanceData(String user_name) async {
    print(user_name);
    if (!isoffline) {
      addBulkAttendance();
      print("internet");
      final response = await http.post(
        Uri.parse('https://optionone-bd.com/api/view_attendance_api.php'),
        body: {
          'user_name': user_name,
        },
      );
      var recData = json.decode(response.body);
      setState(() {
        isLoading = false;
        if (recData != null) {
          if (recData.length == 0) {
            nodata = true;
          } else {
            attendanceList = recData;
            print(attendanceList.length);
            nodata = false;
          }
        }
      });
    } else {
      print("no internet");
      setState(() {
        nodata = true;
        isLoading = false;
      });
    }
  }

  pickImagefromGallery(ImageSource src) async {
    var fileImage1 = await ImagePicker.pickImage(source: src);

    setState(() {
      fileImage = fileImage1;
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1915),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      dd = DateTime.parse(_date.toString());
      finalDate = "${dd.day}-${dd.month}-${dd.year}";
      date = finalDate.toString();
      //print('Birth Date : $finalDate');
      //print('Birth Date : $date');
      setState(() {
        _date = picked;
        var dd1 = DateTime.parse(_date.toString());
        var finalDate1 = "${dd1.day}-${dd1.month}-${dd1.year}";
        date = finalDate1.toString();
        // DateTime dateTime = DateTime.parse(date);
        // Fluttertoast.showToast(msg: dateTime.toString(),toastLength: Toast.LENGTH_SHORT);
        // _date = dateTime;
      });
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  _getCurrentLocation() async {
    Position currentLocation = await locateUser();
    setState(() {
      latitude = currentLocation.latitude.toString();
      longitude = currentLocation.longitude.toString();
    });
    print(latitude);
    print(longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFF1B8E99)),
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Manage ",
                        style: TextStyle(fontSize: 17, color: Colors.black54)),
                    Container(
                      padding:
                          EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 0),
                      child: Text("Attendance",
                          style: TextStyle(
                              fontSize: 17, color: Color(0xFF1B8E99))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                isLoading = true;
              });
              getFromLocal();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(Icons.refresh),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            children: [
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
              DefaultTabController(
                length: 2,
                child: SafeArea(
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        color: Colors.white,
                        child: new Material(
                          color: Colors.white,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(0),
                            margin: EdgeInsets.only(left: 0, right: 0, top: 5),
                            decoration: BoxDecoration(
                                // color: Colors.grey[200],
                                // boxShadow: [
                                //   BoxShadow(
                                //     blurRadius: 3.0,
                                //     color: Colors.black.withOpacity(.2),
                                //     //offset: Offset(6.0, 7.0),
                                //   ),
                                // ],
                                //border: Border.all(color: sub_white, width: 0.3),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: new TabBar(
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 13),
                              tabs: [
                                new Tab(
                                  // icon: Container(
                                  //     height: 30,
                                  //     child: Image.asset('assets/add_attendance.png')),
                                  text: "View Attendance",
                                ),
                                new Tab(
                                  // icon: Container(
                                  //     height: 30,
                                  //     child: Image.asset('assets/add_att.png')),
                                  text: "My Attendance",
                                ),
                              ],
                              indicatorColor: header,
                              unselectedLabelColor: Colors.black45,
                              unselectedLabelStyle: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 12),
                              labelColor: Color(0xFF1B8E99),
                              //labelStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        child: new TabBarView(
                          children: [
                            isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: header,
                                  ))
                                : Container(
                                    child: Column(
                                      children: <Widget>[
                                        nodata
                                            ? Container()
                                            : Container(
                                                //padding: EdgeInsets.all(5),
                                                margin: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 5,
                                                    left: 20,
                                                    right: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Row(
                                                          children: <Widget>[
                                                            Text(
                                                              "${attendanceList.length} ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                  fontSize: 12),
                                                            ),
                                                            Text(
                                                              "Attendance",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                          .grey[
                                                                      700],
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          width: 100,
                                                          child: Divider(
                                                            color: Color(
                                                                0xFF1B8E99),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    // GestureDetector(
                                                    //   onTap: () {
                                                    //     _selectDate(context);
                                                    //   },
                                                    //   child: Column(
                                                    //     crossAxisAlignment:
                                                    //         CrossAxisAlignment.start,
                                                    //     children: <Widget>[
                                                    //       Row(
                                                    //         children: <Widget>[
                                                    //           Icon(
                                                    //             Icons.calendar_today,
                                                    //             color: Colors.grey[700],
                                                    //             size: 14,
                                                    //           ),
                                                    //           SizedBox(width: 5),
                                                    //           Text(
                                                    //             date,
                                                    //             style: TextStyle(
                                                    //                 fontWeight:
                                                    //                     FontWeight.w400,
                                                    //                 color: Colors
                                                    //                     .grey[700],
                                                    //                 fontSize: 12),
                                                    //           ),
                                                    //         ],
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                        Expanded(
                                          child: Container(
                                              child: nodata
                                                  ? Center(
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 0, right: 0),
                                                        child: Text(
                                                          "No record available!",
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    )
                                                  : ListView.separated(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      itemCount:
                                                          attendanceList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          ///contentPadding: EdgeInsets.all(0),
                                                          title: Container(
                                                            //color: Colors.grey.withOpacity(0.1),
                                                            //padding: EdgeInsets.all(5),
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 3,
                                                                    right: 5),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                10),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              left: 0,
                                                                              right: 20),
                                                                          child:
                                                                              Text(
                                                                            "${attendanceList[index]["date"]}",
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.w400,
                                                                                fontSize: 15,
                                                                                color: Colors.black),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(top: 3),
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Icon(Icons.business_center, size: 13, color: Colors.grey),
                                                                              Container(
                                                                                margin: EdgeInsets.only(top: 2, left: 3),
                                                                                child: Text(
                                                                                  "${attendanceList[index]["job_type"]}",
                                                                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Container(
                                                                                margin: EdgeInsets.only(top: 3),
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Icon(Icons.arrow_downward, size: 13, color: header),
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(top: 2, left: 3),
                                                                                      child: Text(
                                                                                        "${attendanceList[index]["in_time"]}",
                                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(top: 0, left: 3),
                                                                                      child: Text(
                                                                                        " | ",
                                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.grey),
                                                                                      ),
                                                                                    ),
                                                                                    Icon(Icons.arrow_upward, size: 13, color: Colors.redAccent),
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(top: 2, left: 3),
                                                                                      child: Text(
                                                                                        "${attendanceList[index]["out_time"]}",
                                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin: EdgeInsets.only(
                                                                              top: 5,
                                                                              left: 0),
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Row(
                                                                            children: <Widget>[
                                                                              Icon(Icons.location_on, size: 13, color: Colors.grey),
                                                                              Flexible(
                                                                                child: Container(
                                                                                  margin: EdgeInsets.only(top: 2, left: 3),
                                                                                  child: Text(
                                                                                    "${attendanceList[index]["job_location"]}",
                                                                                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                // Container(
                                                                //   width: 45,
                                                                //   padding: EdgeInsets.all(5),
                                                                //   decoration: BoxDecoration(
                                                                //       color: header.withOpacity(0.8),
                                                                //       borderRadius:
                                                                //           BorderRadius.circular(5)),
                                                                //   child: Row(
                                                                //     mainAxisAlignment:
                                                                //         MainAxisAlignment.center,
                                                                //     children: <Widget>[
                                                                //       Text(
                                                                //         "Call",
                                                                //         style: TextStyle(
                                                                //             fontWeight: FontWeight.w500,
                                                                //             fontSize: 11,
                                                                //             color: Colors.white),
                                                                //       ),
                                                                //     ],
                                                                //   ),
                                                                // ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      separatorBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Divider(
                                                            color: Colors
                                                                .grey[300]);
                                                      },
                                                    )),
                                        ),
                                      ],
                                    ),
                                  ),
                            SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 25.0),
                                    fileImage != null
                                        ? CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage:
                                                FileImage(fileImage),
                                            //radius: 48.0,
                                            minRadius: 70,
                                            maxRadius: 70,
                                            //child: Image.file(snapshot.data),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: ExactAssetImage(
                                                'assets/person.png'),
                                            //radius: 48.0,
                                            minRadius: 70,
                                            maxRadius: 70,
                                            //child: Image.asset('assets/person.png'),
                                          ),
                                    // new FutureBuilder<File>(
                                    //   future: fileImage,
                                    //   builder: (BuildContext context,
                                    //       AsyncSnapshot<File> snapshot) {
                                    //     if (snapshot.connectionState ==
                                    //             ConnectionState.done &&
                                    //         snapshot.data != null) {
                                    //       return CircleAvatar(
                                    //         backgroundColor: Colors.transparent,
                                    //         backgroundImage:
                                    //             FileImage(snapshot.data),
                                    //         //radius: 48.0,
                                    //         minRadius: 70,
                                    //         maxRadius: 70,
                                    //         //child: Image.file(snapshot.data),
                                    //       );
                                    //       // return Image.file(
                                    //       //   snapshot.data,
                                    //       //   width: 100,
                                    //       //   height: 100,
                                    //       // );

                                    //     } else if (snapshot.error != null) {
                                    //       return const Text(
                                    //         'Error Picking Image',
                                    //         textAlign: TextAlign.center,
                                    //       );
                                    //     } else {
                                    //       return CircleAvatar(
                                    //         backgroundColor: Colors.transparent,
                                    //         backgroundImage: ExactAssetImage(
                                    //             'assets/person.png'),
                                    //         //radius: 48.0,
                                    //         minRadius: 70,
                                    //         maxRadius: 70,
                                    //         //child: Image.asset('assets/person.png'),
                                    //       );

                                    //       // return const Text(
                                    //       //   'No Image Selected',
                                    //       //   textAlign: TextAlign.center,
                                    //       // );
                                    //     }
                                    //   },
                                    // ),
                                    SizedBox(height: 10.0),
                                    Padding(
                                      padding: EdgeInsets.all(7.0),
                                      child: RaisedButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        //onPressed: _submit,
                                        onPressed: () {
                                          pickImagefromGallery(
                                              ImageSource.camera);
                                        },
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 7.0, 10.0, 7.0),
                                        //color: Colors.grey,
                                        child: Text('Take selfie',
                                            style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 24.0, right: 24.0),
                                      child: Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              typeOfSalesItems();
                                            },
                                            child: TextFormField(
                                              controller: jobTypeController,
                                              autofocus: false,
                                              enabled: false,
                                              //initialValue: 'prabal@gmail.com',
                                              decoration: InputDecoration(
                                                hintText: 'Type of Work',
                                                //hintStyle: TextStyle(color: Colors.black38),
                                                labelText:
                                                    'Select Type of Work',
                                                labelStyle: TextStyle(
                                                    color: Color(0xFF1B8E99)),
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        0.0, 10.0, 20.0, 10.0),
                                                border: InputBorder.none,
                                              ),
                                              validator: (val) => val.isEmpty
                                                  ? 'Job type is empty'
                                                  : null,
                                              onSaved: (val) => job_area = val,
                                              //validator: _validateEmail,
                                            ),
                                          ),
                                          new Divider(color: Colors.grey),
                                          TextFormField(
                                            controller: jobAreaController,
                                            autofocus: false,
                                            //initialValue: 'prabal@gmail.com',
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Retail Shop Name or Location',
                                              //hintStyle: TextStyle(color: Colors.black38),
                                              labelText:
                                                  'Enter Retail Shop Name or Location',
                                              labelStyle: TextStyle(
                                                  color: Color(0xFF1B8E99)),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0.0, 10.0, 20.0, 10.0),
                                              border: InputBorder.none,
                                            ),
                                            validator: (val) => val.isEmpty
                                                ? 'Job area is empty'
                                                : null,
                                            onSaved: (val) => job_area = val,
                                            //validator: _validateEmail,
                                          ),
                                          new Divider(color: Colors.grey),
                                          new Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              //SizedBox(height: 10),
                                              isAddData
                                                  ? Center(
                                                      child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ))
                                                  : Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0),
                                                      child: RaisedButton(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(24),
                                                        ),
                                                        //onPressed: _submit,
                                                        onPressed: () {
                                                          giveAttendance();
                                                        },
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                20.0,
                                                                15.0,
                                                                20.0,
                                                                15.0),
                                                        color:
                                                            Color(0xFF1B8E99),
                                                        child: Text(
                                                            'Save and Post',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void typeOfSalesItems() {
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
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    "Select Types",
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
                    child: Column(
                      children: List.generate(items.length, (index) {
                        return ListTile(
                          title: Text("${items[index]}",
                              style: TextStyle(color: Colors.grey[500])),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              jobTypeController.text = "${items[index]}";
                            });
                          },
                        );
                      }),
                    )),
              ],
            ),
          );
        });
  }

  giveAttendance() async {
    setState(() {
      isAddData = true;
    });
    print(user_name);

    var dio = Dio();

    if (!isoffline) {
      if (jobAreaController.text == "") {
        _performError("Job Area is blank!");
      } else if (jobTypeController.text == "") {
        _performError("Job Type is blank!");
      } else {
        var formData = new FormData.fromMap({
          "job_area": jobAreaController.text,
          "category": jobTypeController.text,
          "lat": latitude,
          "lon": longitude,
          "user_name": user_name,
          "postimage": await MultipartFile.fromFile(fileImage.path)
        });
        var response = await dio.post(
            "https://optionone-bd.com/api/add_attendance_api.php",
            data: formData);

        var recData = json.decode(response.data);
        print(response.data);

        attendanceMsg(recData["message"]);
      }
      setState(() {
        isAddData = false;
      });
    } else {
      if (jobAreaController.text == "") {
        _performError("Job Area is blank!");
      } else if (jobTypeController.text == "") {
        _performError("Job Type is blank!");
      } else {
        attendanceBulk = {};
        setState(() {
          if (prefs.getString(attendObj) != null) {
            attendanceBulk = json.decode(prefs.getString(attendObj));
          }

          var loadData = {
            "job_area": jobAreaController.text,
            "category": jobTypeController.text,
            "lat": latitude,
            "lon": longitude,
            "user_name": user_name,
            "postimage": fileImage.path
          };

          storeToLocal(jsonEncode(loadData));

          isAddData = false;
        });
      }
    }
  }

  _performError(String msg) {
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

  addBulkAttendance() async {
    if (prefs.getString(attendObj) != null) {
      setState(() {
        isLoading = true;
      });
      attendanceBulk = {};
      print(prefs.getString(attendObj));
      attendanceBulk = json.decode(prefs.getString(attendObj));

      var dio = Dio();
      var formData = new FormData.fromMap({
        "job_area": attendanceBulk["job_area"],
        "category": attendanceBulk["category"],
        "lat": attendanceBulk["lat"],
        "lon": attendanceBulk["lon"],
        "user_name": attendanceBulk["user_name"],
        "postimage": await MultipartFile.fromFile(attendanceBulk["postimage"])
      });

      var response = await dio.post(
          "https://optionone-bd.com/api/add_attendance_api.php",
          data: formData);

      var recData = json.decode(response.data);
      print(response.data);

      if (response.statusCode == 200) {
        attendanceMsg(recData["message"]);
        await prefs.remove(attendObj);
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> storeToLocal(String loadData) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(attendObj, loadData);
    attendanceMsg(
        "Data stored to local. It will be sync with server when internet arrives!");
  }

  void attendanceMsg(String msg) {
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
                    "Alert",
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
}
