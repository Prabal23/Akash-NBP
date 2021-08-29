import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:option_one_new/attendance.dart';
import 'package:option_one_new/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  DateTime _date = DateTime.now();
  var dd, ddADD, finalDate, finalDateAdd;
  String dateAdd = "dd-MM-yyyy",
      date = "Select Date",
      name = "",
      cell_num = "",
      sub_id = "",
      types_sales = "",
      coupon_number = "",
      remarks = "",
      user_name = "";
  final FocusNode _focusNode = FocusNode();
  TextEditingController nameController = new TextEditingController();
  TextEditingController cellNumController = new TextEditingController();
  TextEditingController subIDController = new TextEditingController();
  TextEditingController typeController = new TextEditingController();
  TextEditingController couponNumController = new TextEditingController();
  TextEditingController remarksController = new TextEditingController();
  var salesList, bestPerformerList;
  bool isLoading = true,
      nodata = false,
      bestPerformerNoData = false,
      isAddData = false;
  List items = ["Retail Shop", "D2D", "kiosk Activation", "Lead Conversion"];
  SharedPreferences prefs;
  List loadDataList = [];
  int storeCount = 0;
  String salesStored = "salesStored";

  @override
  void initState() {
    super.initState();
    getFromLocal();
  }

  getFromLocal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      user_name = prefs.getString(SHARED_PREF_USER);
    });
    getSalesData(user_name, "");

    print(user_name);
  }

  getSalesData(String user_name, String date) async {
    print(user_name);
    if (!isoffline) {
      addBulkSales();
      final response = await http.post(
        Uri.parse('https://optionone-bd.com/api/view_sales_api.php'),
        body: {
          'user_name': user_name,
          'date': date,
        },
      );
      var recData = json.decode(response.body);
      setState(() {
        if (recData.length == 0) {
          nodata = true;
        } else {
          salesList = recData;
          print(salesList.length);
          nodata = false;
        }
      });
      getBestPerformerData();
    } else {
      print("no internet");
      setState(() {
        nodata = true;
        isLoading = false;
      });
    }
  }

  getBestPerformerData() async {
    if (!isoffline) {
      final response = await http.get(
        Uri.parse('https://optionone-bd.com/api/best_performer_api.php'),
      );
      print(response.body);
      var recData = json.decode(response.body);
      setState(() {
        isLoading = false;
        if (recData.length == 0) {
          bestPerformerNoData = true;
        } else {
          bestPerformerList = recData;
          print(bestPerformerList.length);
          bestPerformerNoData = false;
        }
      });
    } else {
      print("no internet");
      setState(() {
        bestPerformerNoData = true;
        isLoading = false;
      });
    }
  }

  addSalesData() async {
    setState(() {
      isAddData = true;
    });
    print(user_name);
    if (!isoffline) {
      final response = await http.post(
        Uri.parse('https://optionone-bd.com/api/add_sales_api.php'),
        body: {
          'user_name': user_name,
          'customer_name': nameController.text,
          'cell_number': cellNumController.text,
          'sub_id': subIDController.text,
          'type_of_sales': typeController.text,
          'coupon': couponNumController.text,
          'remarks': remarksController.text,
        },
      );
      var recData = json.decode(response.body);
      print(response.body);
      salesMsg(recData["error"]);
    } else {
      setState(() {
        loadDataList = [];
        if (prefs.getString(salesStored) != null) {
          var data = json.decode(prefs.getString(salesStored));
          for (int i = 0; i < data.length; i++) {
            loadDataList.add(data[i]);
          }
        }

        var loadData = {
          'user_name': user_name,
          'customer_name': nameController.text,
          'cell_number': cellNumController.text,
          'sub_id': subIDController.text,
          'type_of_sales': typeController.text,
          'coupon': couponNumController.text,
          'remarks': remarksController.text,
        };
        loadDataList.add(loadData);

        storeToLocal(jsonEncode(loadDataList));
      });
    }

    setState(() {
      isAddData = false;
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
      String day = dd.day.toString();
      if (day.length == 1) {
        day = "0" + day;
      }
      String month = dd.month.toString();
      if (month.length == 1) {
        month = "0" + month;
      }
      finalDate = "${dd.year}-$month-$day";
      date = finalDate.toString();
      //print('Birth Date : $finalDate');
      //print('Birth Date : $date');
      setState(() {
        _date = picked;
        var dd1 = DateTime.parse(_date.toString());
        String day1 = dd1.day.toString();
        if (day1.length == 1) {
          day1 = "0" + day1;
        }
        String month1 = dd1.month.toString();
        if (month1.length == 1) {
          month1 = "0" + month1;
        }
        var finalDate1 = "${dd1.year}-$month1-$day1";
        date = finalDate1.toString();
        isLoading = true;
        getSalesData(user_name, date);
        // DateTime dateTime = DateTime.parse(date);
        // Fluttertoast.showToast(msg: dateTime.toString(),toastLength: Toast.LENGTH_SHORT);
        // _date = dateTime;
      });
    }
  }

  void salesMsg(String msg) {
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
                          msg == "Give your attendance first and then try"
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AttendancePage()))
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SalesPage()));
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
            height: 300,
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
                              typeController.text = items[index];
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
                      child: Text("Sales",
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
                length: 3,
                child: SafeArea(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
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
                                  text: "My Sales",
                                ),
                                new Tab(
                                  // icon: Container(
                                  //     height: 30,
                                  //     child: Image.asset('assets/add_att.png')),
                                  text: "Add Sales",
                                ),
                                new Tab(
                                  // icon: Container(
                                  //     height: 30,
                                  //     child: Image.asset('assets/add_att.png')),
                                  text: "Best Performer",
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
                                                              "${salesList.length} ",
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
                                                              "Sales",
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
                                                            top: 0, right: 0),
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
                                                          salesList.length,
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
                                                                                0),
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
                                                                            "${salesList[index]["customer_name"]}",
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
                                                                              Icon(Icons.phone, size: 13, color: Colors.grey),
                                                                              Container(
                                                                                margin: EdgeInsets.only(top: 2, left: 3),
                                                                                child: Text(
                                                                                  "${salesList[index]["cell_number"]}",
                                                                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(top: 3),
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: 2, left: 3),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  salesList[index]["remarks"] == "" ? "Remarks: ---" : "Remarks: ${salesList[index]["remarks"]}",
                                                                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: header),
                                                                                ),
                                                                                Row(
                                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                                  children: [
                                                                                    Icon(Icons.info_outline, size: 13, color: header),
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(left: 3),
                                                                                      child: Text(
                                                                                        salesList[index]["status"],
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: 12,
                                                                                          color: salesList[index]["status"] == "pending" ? Colors.grey : header,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
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
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(top: 2, left: 3),
                                                                                      child: Text(
                                                                                        "Sub ID: ${salesList[index]["sub_id"]}",
                                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                margin: EdgeInsets.only(top: 3),
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: <Widget>[
                                                                                    Container(
                                                                                      margin: EdgeInsets.only(top: 2, left: 3),
                                                                                      child: Text(
                                                                                        "Coupon: ${salesList[index]["coupon"]}",
                                                                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
                                                                                      ),
                                                                                    ),
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
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 24.0, right: 24.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: nameController,
                                      autofocus: false,
                                      //initialValue: 'prabal@gmail.com',
                                      decoration: InputDecoration(
                                        hintText: 'Enter Customer Name',
                                        //hintStyle: TextStyle(color: Colors.black38),
                                        labelText: 'Customer Name',
                                        labelStyle:
                                            TextStyle(color: Color(0xFF1B8E99)),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 20.0, 10.0),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) => val.isEmpty
                                          ? 'Customer Name is empty'
                                          : null,
                                      onSaved: (val) => name = val,
                                      //validator: _validateEmail,
                                    ),
                                    new Divider(color: Colors.grey),
                                    TextField(
                                      controller: cellNumController,
                                      autofocus: false,
                                      keyboardType: TextInputType.phone,
                                      //initialValue: 'prabal@gmail.com',
                                      decoration: InputDecoration(
                                        hintText:
                                            'Registered Mobile Number (RMN)',
                                        //hintStyle: TextStyle(color: Colors.black38),
                                        labelText: 'Enter RMN',
                                        labelStyle:
                                            TextStyle(color: Color(0xFF1B8E99)),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 20.0, 10.0),
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          if (cellNumController.text.length >
                                              11) {
                                            cellNumController.text =
                                                cellNumController.text
                                                    .substring(0, 11);
                                            cellNumController.selection =
                                                TextSelection.fromPosition(
                                                    TextPosition(
                                                        offset:
                                                            cellNumController
                                                                .text.length));
                                          }
                                        });
                                      },
                                    ),
                                    new Divider(color: Colors.grey),
                                    TextFormField(
                                      controller: subIDController,
                                      autofocus: false,
                                      keyboardType: TextInputType.phone,
                                      //initialValue: 'prabal@gmail.com',
                                      decoration: InputDecoration(
                                        hintText: 'Sub ID',
                                        //hintStyle: TextStyle(color: Colors.black38),
                                        labelText: 'Enter Sub ID',
                                        labelStyle:
                                            TextStyle(color: Color(0xFF1B8E99)),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 20.0, 10.0),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) => val.isEmpty
                                          ? 'Sub ID is empty'
                                          : null,
                                      onSaved: (val) => sub_id = val,
                                      //validator: _validateEmail,
                                    ),
                                    new Divider(color: Colors.grey),
                                    GestureDetector(
                                      onTap: () {
                                        typeOfSalesItems();
                                      },
                                      child: TextFormField(
                                        controller: typeController,
                                        autofocus: false,
                                        enabled: false,
                                        //initialValue: 'prabal@gmail.com',
                                        decoration: InputDecoration(
                                          hintText: 'Type of sales',
                                          //hintStyle: TextStyle(color: Colors.black38),
                                          labelText: 'Select type of sales',
                                          labelStyle: TextStyle(
                                              color: Color(0xFF1B8E99)),
                                          contentPadding: EdgeInsets.fromLTRB(
                                              0.0, 10.0, 20.0, 10.0),
                                          border: InputBorder.none,
                                        ),
                                        validator: (val) => val.isEmpty
                                            ? 'Type of sales is empty'
                                            : null,
                                        onSaved: (val) => types_sales = val,
                                        //validator: _validateEmail,
                                      ),
                                    ),
                                    new Divider(color: Colors.grey),
                                    TextFormField(
                                      controller: couponNumController,
                                      autofocus: false,
                                      //initialValue: 'prabal@gmail.com',
                                      decoration: InputDecoration(
                                        hintText: 'Coupon Number',
                                        //hintStyle: TextStyle(color: Colors.black38),
                                        labelText: 'Enter Coupon Number',
                                        labelStyle:
                                            TextStyle(color: Color(0xFF1B8E99)),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 20.0, 10.0),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) => val.isEmpty
                                          ? 'Coupon Number is empty'
                                          : null,
                                      onSaved: (val) => coupon_number = val,
                                      //validator: _validateEmail,
                                    ),
                                    new Divider(color: Colors.grey),
                                    TextFormField(
                                      controller: remarksController,
                                      autofocus: false,
                                      //initialValue: 'prabal@gmail.com',
                                      decoration: InputDecoration(
                                        hintText: 'Remarks',
                                        //hintStyle: TextStyle(color: Colors.black38),
                                        labelText: 'Enter Remarks',
                                        labelStyle:
                                            TextStyle(color: Color(0xFF1B8E99)),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 20.0, 10.0),
                                        border: InputBorder.none,
                                      ),
                                      validator: (val) => val.isEmpty
                                          ? 'Remarks is empty'
                                          : null,
                                      onSaved: (val) => remarks = val,
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
                                                    const EdgeInsets.all(10.0),
                                                child:
                                                    CircularProgressIndicator(),
                                              ))
                                            : Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                                child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            24),
                                                  ),
                                                  //onPressed: _submit,
                                                  onPressed: () {
                                                    addSalesData();
                                                  },
                                                  padding: EdgeInsets.fromLTRB(
                                                      20.0, 15.0, 20.0, 15.0),
                                                  color: Color(0xFF1B8E99),
                                                  child: Text('Save and Post',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: header,
                                  ))
                                : Container(
                                    child: Column(
                                      children: <Widget>[
                                        bestPerformerNoData
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
                                                              "${bestPerformerList.length} ",
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
                                                              "Perfomers",
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
                                                    //                 color: Colors.grey[700],
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
                                              child: bestPerformerNoData
                                                  ? Center(
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 0, right: 0),
                                                        child: Text(
                                                          "No best performer available!",
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
                                                          bestPerformerList
                                                              .length,
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
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            left:
                                                                                0),
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
                                                                            bestPerformerList[index]["bp_code"],
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
                                                                              Icon(Icons.location_on, size: 13, color: Colors.grey),
                                                                              Container(
                                                                                margin: EdgeInsets.only(top: 2, left: 3),
                                                                                child: Text(
                                                                                  bestPerformerList[index]["territory"],
                                                                                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Colors.black45),
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
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              3),
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        top: 2,
                                                                        left:
                                                                            3),
                                                                    child: Text(
                                                                      "${bestPerformerList[index]["total_sales"]} Sales",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              header),
                                                                    ),
                                                                  ),
                                                                ),
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

  addBulkSales() async {
    if (prefs.getString(salesStored) != null) {
      setState(() {
        isLoading = true;
      });
      loadDataList = [];
      print(prefs.getString(salesStored));
      loadDataList = json.decode(prefs.getString(salesStored));
      for (int i = 0; i < loadDataList.length; i++) {
        final response = await http.post(
          Uri.parse('https://optionone-bd.com/api/add_sales_api.php'),
          body: loadDataList[i],
        );
        var recData = json.decode(response.body);
        print(response.statusCode);

        if (response.statusCode == 200) {
          print(loadDataList[i]);
          if (recData["error"] != null) {
            storeCount++;
          } else {
            loadDataList.remove(i);
          }
        }
        // leadsMsg(recData["error"]);
      }
      print(storeCount);
      if (storeCount == 0) {
        salesMsg("All data synced successfully!");
        await prefs.remove(salesStored);
      } else {
        salesMsg("Attendance already done!");
        await prefs.remove(salesStored);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> storeToLocal(String listSales) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString(salesStored, listSales);
    salesMsg(
        "Data stored to local. It will be sync with server when internet arrives!");
  }
}
