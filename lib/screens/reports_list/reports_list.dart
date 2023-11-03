import 'dart:convert';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/repellents.dart';
import 'package:capstone_mobile/screens/reports_list/report_content.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';
import 'package:http/http.dart' as http;

class ReportList extends StatefulWidget {
  final token; final int notificationCount;
  ReportList({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _ReportList createState() => _ReportList();
}
class _ReportList extends State<ReportList> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  late String userId;
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
          fetchUnreadNotifications(userId);
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
          fetchUnreadNotifications(userId);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    } finally {
    }
  }

  List? items;

  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    fetchUnreadNotificationsList();
    fetchUserReports(userId);
    fetchUnreadNotifications(userId);
  }

  Future<void> fetchUserReports(String userId) async {
    try {
      var response = await http.post(
        Uri.parse(getUserReport),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          items = jsonResponse['userReportData'];
          // Sort the items list by 'postedDate' in descending order
          items?.sort((a, b) => b['postedDate'].compareTo(a['postedDate']));

          /**
              // Sort the items list by 'postedDate' in ascending order
              items?.sort((a, b) => a['postedDate'].compareTo(b['postedDate']));
           */
          fetchUnreadNotifications(userId);
          fetchUserReports(userId);
        });
      } else {
        //error message
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    }
  }


  //delete function
  Future<void> deleteReport(String reportId) async {
    try {
      var response = await http.post(
        Uri.parse(deleteUserReport),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"reportId": reportId}),
      );

      if (response.statusCode == 200) {
        // Report successfully deleted, remove it from the UI
        setState(() {
          items?.removeWhere((report) => report['reportId'] == reportId);
        });
        // not done, show a success message or perform other actions.
      } else {
        print("Failed to delete report. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error deleting report: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return Scaffold(

        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'User Reports'),

        //sidenav
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background/background5.png',
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

    return Scaffold(
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'User Reports'),

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

          // Top Row
          Positioned.fill(
            top: 0,
            left: 20,
            right: 20,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                      height: 80,
                                      child: Center(
                                        child: Text(
                                          'List of Sent Reports',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 20,
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

                    (items == null || items!.isEmpty)
                        ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No reports available.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : Container(),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items?.length ?? 0,
                      itemBuilder: (context, index) {
                        var report = items![index];
                        int reportNumber = items!.length - index;
                        return IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                              0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Image.asset(
                                                  'assets/report_list_images/report_icon_2.png',
                                                  width: 55,
                                                  scale: 0.8,
                                                ),
                                                Text("Report $reportNumber",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight
                                                          .bold),),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          //  spacng between the image and text
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Text(
                                                  '${items![index]['report_type']}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight
                                                        .bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                // spacing between the two texts
                                                Text(
                                                  '${items![index]['report_subject']}',
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign
                                                      .justify,
                                                  maxLines: 2,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                                SizedBox(height: 10),
                                                // spacing between the two texts
                                                Padding(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Text(
                                                    "Date: " +
                                                        DateFormat('yyyy-MM-dd').format(DateTime.parse(report['postedDate'])),
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 11,
                                                    ),
                                                    textAlign: TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReportContent(
                                                              token: widget
                                                                  .token,
                                                              PassReportIdObject: report['_id'],
                                                              PassReportSubject: report['report_subject'],
                                                              PassReportType: report['report_type'],
                                                              PassReportBarangay: report['barangay'],
                                                              PassReportId: report['reportId'],
                                                              PassReportNumber: "Report $reportNumber",
                                                              PassReportDescription: report['report_description'],
                                                              PassReportDate: report['postedDate'],
                                                              PassUploadedFile: (report['uploaded_file'] as List).map((item) => item.toString()).toList(),
                                                              notificationCount: widget.notificationCount,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    primary: Color(0xff28376d),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(15),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.email_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    ' Open ',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(30.0),
                                                          ),
                                                          elevation: 4,
                                                          shadowColor: Colors.black,
                                                          content: SingleChildScrollView(
                                                            child: Container(
                                                              width: MediaQuery.of(context).size.width * 0.8,
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/exit_images/caution.png',
                                                                      width: 100,
                                                                      height: 100
                                                                  ),
                                                                  SizedBox(height: 10),
                                                                  Text(
                                                                    'Caution',
                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                                                                  ),
                                                                  SizedBox(height: 20),
                                                                  Text(
                                                                    'Are you sure you want to delete a report?',
                                                                    style: TextStyle(fontSize: 16, color: Color(0xFF338B93), fontWeight: FontWeight.bold),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            Center(
                                                              child: Wrap(
                                                                alignment: WrapAlignment.center,
                                                                spacing: 10,
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
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Text(
                                                                        'Cancel',
                                                                        style: TextStyle(color: Colors.white),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      deleteReport(report['reportId']);
                                                                      Navigator.of(context).pop(); // Close the dialog
                                                                    },
                                                                    style: TextButton.styleFrom(
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(30.0),
                                                                      ),
                                                                      backgroundColor: Colors.red,
                                                                    ),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Text(
                                                                        'Delete',
                                                                        style: TextStyle(color: Colors.white),
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    primary: Colors.redAccent,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius
                                                          .circular(15),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.white,
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
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 125),
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
                      //already in report list
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
