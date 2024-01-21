import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:capstone_mobile/sidenav.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';


class DengueTaskForce extends StatefulWidget {
  final token; final int notificationCount;
  DengueTaskForce({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _DengueTaskForce createState() => _DengueTaskForce();
}

class _DengueTaskForce extends State<DengueTaskForce> {
  void updateUnreadCardCountGlobally(int count) {
    updateUnreadCardCount(count);


  }
  late String _id;
  List? readItems;
  List? unreadItems;
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
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
    fetchUnreadNotificationsList();
    fetchReadNotifications();
    fetchUnreadNotifications(_id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Anti-Dengue Task Force'),

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
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100, top: 15, left: 10, right: 10),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Image.asset(
                            'assets/logo/pasig_health_department_logo.png',
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                                  child: SizedBox(
                                    child: Text(
                                      'Information',
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Outfit'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 15.0),
                                  child: Text(
                                    'Pasig Anti-Dengue Task Force is tasked to clean, fumigate, and monitor high-risk areas in the city against dengue-causing mosquitoes.',
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

                    //contact information
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
                      child: SizedBox(
                        child: Text(
                          'Contact Information',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Outfit'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Button 1
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 1, 20, 9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/task_force_images/email.png',
                              width: 65,
                              height: 60,
                            ),
                            Expanded(
                              child: Text(
                                'pasigdenguetaskforce@gmail.com',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Button 2
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/task_force_images/phone.png',
                              width: 65,
                              height: 60,
                            ),
                            Expanded(
                              child: Text(
                                '(02) 8643 8047',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Button 3
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/task_force_images/location.png',
                              width: 65,
                              height: 60,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 7, 0),
                                child: Text(
                                  "Room 12, 5th floor, City Government of Pasig, 1600 Caruncho Ave, Pasig, Metro Manila.",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //services
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 10.0),
                      child: SizedBox(
                        child: Text(
                          'Services',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Outfit'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Button 1
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 1, 20, 9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/task_force_images/service.png',
                              width: 65,
                              height: 60,
                            ),
                            Expanded(
                              child: Text(
                                'Community Teaching: Larvae Control of Infestation',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Button 2
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/task_force_images/service.png',
                              width: 65,
                              height: 60,
                            ),
                            Expanded(
                              child: Text(
                                'Clean-Up Drive',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Button 3
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/task_force_images/service.png',
                              width: 65,
                              height: 60,
                            ),
                            Expanded(
                              child: Text(
                                'Fumigation',
                                style: TextStyle(color: Colors.black),
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
                    color: Colors.black.withOpacity(0.3), // Shadow color
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