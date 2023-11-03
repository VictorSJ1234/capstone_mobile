import 'dart:convert';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:capstone_mobile/sidenav.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';
import 'package:http/http.dart' as http;


class CommunityProjects2 extends StatefulWidget {
  final token; final int notificationCount;
  final String PassProjectId;
  CommunityProjects2({@required this.token,Key? key, required this.PassProjectId, required this.notificationCount}) : super(key: key);
  @override
  _CommunityProjects2 createState() => _CommunityProjects2();
}

class _CommunityProjects2 extends State<CommunityProjects2> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  late String projectId;
  late String _id;
List? readItems;
List? unreadItems;
  Future<void> fetchUnreadNotificationsList() async {

    try {
      var response = await http.post(
        Uri.parse(getNotificationStatus),
        headers: {"Content-Type": "application/json"},
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
        headers: {"Content-Type": "application/json"},
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

  //fetched data container
  String _title = '';
  String _date = '';
  String _time = '';
  String _details = '';
  String _location = '';
  String _uploaded_file= '';
  String _attachementDescription = '';

  // Store the image bytes
  late Uint8List projectImageBytes;

  @override
  void initState() {
    super.initState();
    projectId = widget.PassProjectId;
    fetchProject(projectId);
    loadProjectImage();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
    fetchUnreadNotificationsList();
    fetchReadNotifications();
    fetchUnreadNotifications(_id);
  }
  Future<void> loadProjectImage() async {
    try {
      final bytes = base64.decode(_uploaded_file);
      setState(() {
        projectImageBytes = Uint8List.fromList(bytes);
      });
    } catch (error) {
      print(error);
    }
  }

  // Function to format time with AM/PM
  String formatTime(String time) {
    // Assuming time is in HH:mm (24-hour format)
    final parts = time.split(':');
    final int originalHour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    String period = 'AM';
    int hour = originalHour;

    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) {
        hour -= 12;
      }
    }

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> fetchProject(String projectId) async {
    try {
      var response = await http.post(
        Uri.parse(getCommunityProjectsById),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"_id": projectId}),
      );

      var jsonResponse = jsonDecode(response.body);
      setState(() {
        if (jsonResponse != null && jsonResponse['communityProjectsData'] != null) {
          final adminResponseData = jsonResponse['communityProjectsData'];
          if (adminResponseData.isNotEmpty) {
            // Populate the empty strings with fetched data
            _title = adminResponseData[0]['project_title'].toString();
            _date = adminResponseData[0]['project_date'].toString();
            _time = formatTime(adminResponseData[0]['project_time'].toString());
            _details = adminResponseData[0]['details'].toString();
            _location = adminResponseData[0]['location'].toString();
            _uploaded_file = adminResponseData[0]['uploaded_file'].toString();

          }
        }
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_title.toString().isEmpty || _details.toString().isEmpty || _date.toString().isEmpty) {
      return Scaffold(

        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'User Reports'),

        //sidenav
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background/background6.png',
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: EdgeInsets.only(bottom: 15.0, right: 15, left: 15),
                //margin of the botnav
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
                            builder: (context) =>
                                ReportList(token: widget.token, notificationCount: widget.notificationCount),
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
                            builder: (context) =>
                                UserProfile(token: widget.token, notificationCount: widget.notificationCount),
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
    else {
      return Scaffold(
        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Community Projects'),

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
                padding: const EdgeInsets.only(
                    bottom: 60, top: 15, left: 10, right: 10),
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
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 0.0, 20.0, 0.0),
                                      child: Container(
                                        height: 70,
                                        child: Center(
                                          child: Text(
                                            'Community Project',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 23,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            15.0, 0.0, 15.0, 15.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35.0),
                              border: Border.all(
                                color: Colors.white,
                                width: 5.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30.0),
                              child: projectImageBytes.isNotEmpty
                                  ? Image.memory(
                                projectImageBytes,
                                width: 250,
                              )
                                  : Image.asset(
                                'assets/community_projects_images/community_project.png', // Replace with the path to your default image
                                width: 250,
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
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 10.0, 0.0, 0.0),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0.0, 15.0, 0.0, 5.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        0.0, 5.0, 0.0, 0.0),
                                                    child: SizedBox(
                                                      child: Text(
                                                        _title,
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.black,
                                                            fontFamily: 'Outfit'),
                                                        textAlign: TextAlign
                                                            .center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0.0, 0.0, 0.0, 0.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        0.0, 0.0, 0.0, 0.0),
                                                    child: SizedBox(
                                                      child: Text(
                                                        _date +"\n"+ _time,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight
                                                                .normal,
                                                            color: Colors.black,
                                                            fontFamily: 'Outfit'),
                                                        textAlign: TextAlign
                                                            .center,
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
                                  ),
                                ],
                              ),
                            ),
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 1.0, 0.0, 0.0),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 1.0, 15.0, 15.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .stretch,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        20.0, 5.0, 0.0, 0.0),
                                                    child: SizedBox(
                                                      child: Text(
                                                        'Location',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.black,
                                                            fontFamily: 'Outfit'),
                                                        textAlign: TextAlign
                                                            .justify,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        20.0, 5.0, 20.0, 15.0),
                                                    child: Text(
                                                      _location,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xff8B8B8B),
                                                          fontFamily: 'Outfit'),
                                                      textAlign: TextAlign
                                                          .justify,
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
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 1.0, 0.0, 0.0),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 1.0, 15.0, 15.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment
                                                    .stretch,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        20.0, 5.0, 0.0, 0.0),
                                                    child: SizedBox(
                                                      child: Text(
                                                        'Details',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight: FontWeight
                                                                .bold,
                                                            color: Colors.black,
                                                            fontFamily: 'Outfit'),
                                                        textAlign: TextAlign
                                                            .left,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Padding(
                                                    padding: EdgeInsets
                                                        .fromLTRB(
                                                        20.0, 5.0, 20.0, 15.0),
                                                    child: Text(
                                                      _details,
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(
                                                              0xff8B8B8B),
                                                          fontFamily: 'Outfit'),
                                                      textAlign: TextAlign
                                                          .justify,
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
                            SizedBox(height: 30), //bottom padding
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
                margin: EdgeInsets.only(bottom: 15.0, right: 15, left: 15),
                //margin of the botnav
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
                            builder: (context) =>
                                ReportList(token: widget.token, notificationCount: widget.notificationCount),
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
                            builder: (context) =>
                                UserProfile(token: widget.token, notificationCount: widget.notificationCount),
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
}
