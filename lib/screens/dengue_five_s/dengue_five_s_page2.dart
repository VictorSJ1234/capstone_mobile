import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:capstone_mobile/sidenav.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';


class Dengue5sPage2 extends StatefulWidget {
  final String PassCaption;
  final String PassImage;
  final token; final int notificationCount;
  Dengue5sPage2({@required this.token,Key? key, required this.PassCaption, required this.PassImage, required this.notificationCount}) : super(key: key);
  @override
  _Dengue5sPage2 createState() => _Dengue5sPage2();
}

class _Dengue5sPage2 extends State<Dengue5sPage2> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  late String _id;
  List? readItems;
  List? unreadItems;
  String details = "";

final Map<String, String> dengue5sDetails = {
  'Search and Destroy': "The 'Search and Destroy' strategy involves identifying and eliminating breeding sites of mosquitoes. This includes emptying containers that collect and store water, as stagnant water is a breeding ground for mosquitoes.",
  'Self-Protect': "The 'Self-Protect' strategy focuses on personal protection measures to prevent mosquito bites. This includes wearing long sleeves and using mosquito repellent on exposed skin.",
  'Seek Consultation': "If you or someone you know experiences symptoms of dengue, it is crucial to seek medical consultation immediately. Symptoms may include sudden high fever, severe headache, joint and muscle pain, vomiting, and skin rashes.",
  'Support Fogging in Outbreak Areas': "Supporting fogging operations in outbreak areas is part of community efforts to control mosquito populations. Fogging helps reduce adult mosquito numbers and prevent the spread of diseases.",
  'Sustain Hydration': "Sustaining hydration is vital, especially during a dengue outbreak. Dengue can cause dehydration, so it's essential to drink plenty of fluids to stay hydrated.",
};
Future<void> fetchUnreadNotificationsList() async {

    try {
      var response = await http.post(
        Uri.parse(getNotificationStatus),
        headers: {
        "Content-Type": "application/json",
        "x-api-key": 'pasigdtf',
      },
        body: jsonEncode({"userId": userId, "notificationStatus": "Unread".toString()}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          unreadItems = jsonResponse['notifications'];
          unreadItems?.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

          // Fetch and set the read notifications
          fetchReadNotifications();
          fetchUnreadNotifications(_id);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    } finally {
    }
  }

  Future<void> fetchReadNotifications() async {

    try {
      var response = await http.post(
        Uri.parse(getNotificationStatus),
        headers: {
        "Content-Type": "application/json",
        "x-api-key": 'pasigdtf',
      },
        body: jsonEncode({"userId": userId, "notificationStatus": "Read".toString()}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          readItems = jsonResponse['notifications'];
          readItems?.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

          // Fetch and set the read notifications
          fetchUnreadNotificationsList();
          fetchUnreadNotifications(_id);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    } finally {
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchReadNotifications();
    fetchUnreadNotifications(_id);
  }

  Widget build(BuildContext context) {
    details = dengue5sDetails[widget.PassCaption]!;

    return Scaffold(
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Dengue 5s'),

      //sidenav
      drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

      //content
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/background6.png',
              fit: BoxFit.cover,
            ),
          ),

          // Top Row
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60, top: 15, left: 10, right: 10),
              child: Container(
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 8.0),
                                    child: Container(
                                      height: 70,
                                      child: Center(
                                        child: Text(
                                          'Community Dengue Awareness\n 5S Strategy',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12, // Shadow color
                                                blurRadius: 2.0, // Spread of the shadow
                                                offset: Offset(0, 5), // Offset of the shadow
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            color: Color(0xffF5F5F5),
                                            elevation: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              child: SizedBox(
                                                child: Text(
                                                  widget.PassCaption,
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 2.0, 15.0, 2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.asset(
                              widget.PassImage,
                              width: 260,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Color(0xffF5F5F5),
                      elevation: 25,
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                                                  child: SizedBox(
                                                    child: Text(
                                                      'Details',
                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 15.0),
                                                  child: Text(
                                                    details,
                                                    style: TextStyle(fontSize: 15, color: Color(0xff8B8B8B), fontFamily: 'Outfit'),
                                                    textAlign: TextAlign.justify,
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
          ),


          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: EdgeInsets.only(bottom: 15.0, right: 15, left: 15), //margin of the botnav
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(50.0),
                  bottom: Radius.circular(50.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/home.png'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenu(token: widget.token, notificationCount: widget.notificationCount),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/list.png'),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportList(token: widget.token, notificationCount: widget.notificationCount),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/user.png'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfile(token: widget.token, notificationCount: widget.notificationCount),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
