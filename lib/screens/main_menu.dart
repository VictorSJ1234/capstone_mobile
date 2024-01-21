import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/about_app/about_app.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/dengue_five_s/dengue_five_s.dart';
import 'package:capstone_mobile/screens/dengue_task_force/dengue_task_force.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/notification/notification.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:capstone_mobile/screens/send_report/send_report.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import 'mosquitopedia/diseases.dart';
import 'user_profile/user_profile.dart';

class MainMenu extends StatefulWidget  {
  final token; final int notificationCount;
  MainMenu({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _MainMenu createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  late String email;
  late String _id;
List? readItems;
List? unreadItems;
  String accountStatus = '';
  List? items;
  bool isAccountValidated = false;
  bool _isLoading = false;

  Future<void> fetchUnreadNotificationsList() async {

    try {
      var response = await http.post(
        Uri.parse(getNotificationStatus),
        headers: {"Content-Type": "application/json",
          "x-api-key": 'pasigdtf', },
        body: jsonEncode({"userId": userId, "notificationStatus": "Unread".toString()}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          unreadItems = jsonResponse['notifications'];
          unreadItems?.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

          // Fetch and set the read notificationss
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
        headers: {"Content-Type": "application/json",
          "x-api-key": 'pasigdtf', },
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

  // Fetch user validation status from the backend
  Future<void> fetchUserInformation(String _id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        Uri.parse(getUserData),
        headers: {"Content-Type": "application/json",
          "x-api-key": 'pasigdtf', },
        body: jsonEncode({"_id": _id}),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse != null && jsonResponse['userInformationData'] != null) {
        setState(() {
          items = jsonResponse['userInformationData'];
          if (items!.isNotEmpty) {
           accountStatus= items![0]['accountStatus'].toString();

           isAccountValidated = (accountStatus == "Validated");

           fetchUnreadNotifications(_id);
           print(accountStatus);
           _isLoading = false;
          }
        });
      }
    }  catch (error) {
      print(error);
    }
  }

  //check if user is validated
  Future<void> _sendReportButtonPressed(BuildContext context) async {
    // Check for network/internet connectivity
    try {
      await http.get(Uri.parse('https://www.google.com'));
    } catch (networkError) {
      // Handle network/internet connection error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Network Error"),
            content: Text("Please check your network/internet connection."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }
    if (isAccountValidated) {
      // Enable the "Send a Report" functionality
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SendReport(token: widget.token, notificationCount: widget.notificationCount),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 4,
            shadowColor: Colors.black,
            content: Container(
              height: 180,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/exit_images/caution.png',
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'You can\'t send a report yet as your account is not yet validated. Please wait for approval.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF338B93)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
      /** Show a Snackbar if the account is not validated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your account is not validated.'),
          duration: Duration(seconds: 2),
        ),
      );
          **/
    }
  }

  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    email = jwtDecodedToken['email'];
    _id = jwtDecodedToken['_id'];
    fetchUserInformation(_id);
    fetchUnreadNotificationsList();
    fetchReadNotifications();

    fetchUnreadNotifications(_id);
  }

    @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Main Menu'),


        //sidenav
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),


        //content
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/background/background5.png',
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
                          // mosquitopedia Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 15.0, 5.0, 10.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/main_menu_images/mosquitopedia.png',
                                      width: 95,
                                      height: 105,
                                      scale: 0.8,
                                    ),
                                    SizedBox(height: 5), //space between image and button
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MosquitopediaMenu(token: widget.token, notificationCount: widget.notificationCount),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff28376d),
                                        minimumSize: Size(120, 50),
                                      ),
                                      child: Text('Mosquitopedia', style: TextStyle(fontSize: 15),),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // task force Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 15.0, 10, 10.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/main_menu_images/dengue_5s.png',
                                      width: 95,
                                      height: 105,
                                      scale: 0.8,
                                    ),
                                    SizedBox(height: 5), // space between image and button
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DengueFiveS(token: widget.token, notificationCount: widget.notificationCount),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff28376d),
                                        minimumSize: Size(120, 50),
                                      ),
                                      child: Text('Dengue 5S', style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // mosquitopedia Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // mosquitopedia Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 0, 5.0, 0.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/main_menu_images/community_projects.png',
                                      width: 95,
                                      height: 105,
                                      scale: 0.8,
                                    ),
                                    SizedBox(height: 5), //space between image and button
                                    ElevatedButton(
                                      onPressed: () async {// Check for network/internet connectivity
                                        try {
                                          await http.get(Uri.parse('https://www.google.com'));
                                        } catch (networkError) {
                                          // Handle network/internet connection error
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Network Error"),
                                                content: Text("Please check your network/internet connection."),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context); // Close the dialog
                                                    },
                                                    child: Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          return;
                                        }
                                         Navigator.push(
                                          context,
                                         MaterialPageRoute(
                                         builder: (context) => CommunityProjects(token: widget.token, notificationCount: widget.notificationCount),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shadowColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff28376d),
                                        minimumSize: Size(120, 50),
                                      ),
                                      child: Text('Community \n Projects', style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // task force Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 0, 10.0, 0.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/main_menu_images/reporting.png',
                                      width: 95,
                                      height: 105,
                                      scale: 0.8,
                                    ),
                                    SizedBox(height: 5), // space between image and button

                                    Visibility(
                                      visible: !_isLoading, // Show the ElevatedButton if not loading
                                      replacement: Center(
                                        child: CircularProgressIndicator(), // Show a loading indicator if loading
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _sendReportButtonPressed(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          backgroundColor: Color(0xff28376d),
                                          minimumSize: Size(110, 50),
                                        ),
                                        child: Text(
                                          'Send a \n Report',
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // mosquitopedia Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10.0, 15.0, 5.0, 10.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/logo/pasig_health_department_logo.png',
                                      width: 95,
                                      height: 105,
                                      scale: 0.8,
                                    ),
                                    SizedBox(height: 5), //space between image and button
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DengueTaskForce(token: widget.token, notificationCount: widget.notificationCount),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff28376d),
                                        minimumSize: Size(120, 50),
                                      ),
                                      child: Text('Pasig Dengue \n Task Force', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // task force Card
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(5.0, 15.0, 10, 10.0),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                elevation: 10,
                                shadowColor: Colors.black,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/main_menu_images/about_app.png',
                                      width: 95,
                                      height: 105,
                                      scale: 0.8,
                                    ),
                                    SizedBox(height: 5), // space between image and button
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AboutApp(token: widget.token, notificationCount: widget.notificationCount),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff28376d),
                                        minimumSize: Size(120, 50),
                                      ),
                                      child: Text('About App', style: TextStyle(fontSize: 15),
                                        textAlign: TextAlign.center,),
                                    ),
                                    SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                        // already in home
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
      ),
    );
  }
}