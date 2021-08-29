import 'package:flutter/material.dart';
import 'package:option_one_new/main.dart';
import 'package:option_one_new/menu_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final section;
  HomePage(this.section);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _children = [
    // ProfilePage(),
    // HistoryPage(),
    // CommentPage(),
  ];

  final List<Widget> _children1 = [
    MenuPage(),
    // DoctorListPage(),
    // CommentFarmerPage(),
  ];

  String email = "info@krittimtech.website";

  void _show(BuildContext ctx) {
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
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Text(
                    "For Help?",
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListTile(
                    leading: Icon(Icons.email),
                    title: Text('Email'),
                    subtitle: Text(email),
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 13,
                    ),
                    onTap: () {
                      launch("mailto:$email");
                    },
                  ),
                ),
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
              ),
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Container(
                      padding:
                          EdgeInsets.only(top: 5, bottom: 5, right: 5, left: 5),
                      child: Image.asset(
                        'assets/akash.png',
                        width: 150,
                      )),
                ),
              ),
              Container(
                child: GestureDetector(
                  onTap: () {
                    _show(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 5),
                    padding: EdgeInsets.all(5),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Icon(Icons.help)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
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
            Container(
              color: Colors.white,
              child: widget.section == 1
                  ? _children1[_currentIndex]
                  : _children[_currentIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration:
            BoxDecoration(border: Border.all(width: 0.1, color: Colors.grey)),
        padding: EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "  Developed by  ",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      fontSize: 11),
                ),
                Image.asset("assets/developer_logo.png", height: 35)
              ],
            ),
            Column(
              children: [
                Text(
                  "  Managed by  ",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                      fontSize: 11),
                ),
                Image.asset(
                  "assets/opt_one.png",
                  height: 35,
                  width: 70,
                ),
              ],
            ),
          ],
        ),
      ),
      //body: body,
      // bottomNavigationBar: Theme(
      //   data: Theme.of(context).copyWith(
      //       // sets the background color of the `BottomNavigationBar`
      //       canvasColor: Colors.white,
      //       //backgroundColor: Colors.lightBlue,
      //       // sets the active color of the `BottomNavigationBar` if `Brightness` is light
      //       primaryColor:
      //           widget.section == 1 ? Color(0xFF1B8E99) : Color(0xFF1B8E99),
      //       //disabledColor: Colors.blue,
      //       textTheme: Theme.of(context).textTheme.copyWith(
      //           caption: new TextStyle(
      //               color: widget.section == 1 ? Colors.grey : Colors.grey))),
      //   child: new BottomNavigationBar(
      //     type: BottomNavigationBarType.fixed,
      //     onTap: onTabTapped,
      //     currentIndex:
      //         _currentIndex, // this will be set when a new tab is tapped
      //     items: widget.section == 1
      //         ? [
      //             BottomNavigationBarItem(
      //               icon: new Icon(
      //                 Icons.menu,
      //                 size: 19,
      //               ),
      //               title: new Text(
      //                 'Menu',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //             ),
      //             BottomNavigationBarItem(
      //               icon: new Icon(
      //                 Icons.hourglass_empty,
      //                 size: 19,
      //               ),
      //               title: new Text(
      //                 'Account History',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //             ),
      //             BottomNavigationBarItem(
      //               icon: new Icon(
      //                 Icons.person_outline,
      //                 size: 19,
      //               ),
      //               title: new Text(
      //                 'Profile',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //             ),
      //           ]
      //         : [
      //             BottomNavigationBarItem(
      //               icon: new Icon(
      //                 Icons.person_outline,
      //                 size: 19,
      //               ),
      //               title: new Text(
      //                 'Profile',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //             ),
      //             BottomNavigationBarItem(
      //               icon: new Icon(
      //                 Icons.hourglass_empty,
      //                 size: 19,
      //               ),
      //               title: new Text(
      //                 'View History',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Icon(
      //                 Icons.chat_bubble_outline,
      //                 size: 19,
      //               ),
      //               title: Text(
      //                 'Comment',
      //                 style: TextStyle(fontSize: 12),
      //               ),
      //             )
      //           ],
      //   ),
      // ),
    );
  }
}
