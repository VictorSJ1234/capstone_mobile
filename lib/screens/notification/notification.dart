import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/repellents.dart';
import 'package:capstone_mobile/screens/reports_list/report_content.dart';
import 'package:capstone_mobile/screens/reports_list/report_status.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../config.dart';
import 'package:capstone_mobile/sidenav.dart';
import '../community_projects/community_projects_page2.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';
import 'package:http/http.dart' as http;

class NotificationPage extends StatefulWidget {
  final token; final int notificationCount;
  NotificationPage({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _NotificationPage createState() => _NotificationPage();
}

enum SelectedContentType {
  unread,
  read,
}

class _NotificationPage extends State<NotificationPage> {

  void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }


  SelectedContentType selectedContentType = SelectedContentType.unread;

  late String userId;
  List? readItems;
  List? unreadItems;

Future<void> fetchUnreadNotificationsList() async {
    setState(() {
      _isLoading = true;
    });

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchReadNotifications() async {
    setState(() {
      _isLoading = true;
    });

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  late String projectId;
  List<ImageProvider?> projectImage = [];
  String? projectImageBase64;
  final String defaultImage = 'assets/community_projects_images/community_project.png';
  bool _isLoading = false;
  String _reportStatus = '';

  Future<void> fetchReportStatus(String reportId) async {
    try {
      var response = await http.post(
        Uri.parse(getAdminResponse), // api endpoint
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"reportId": reportId}),
      );

      var jsonResponse = jsonDecode(response.body);
      setState(() {
        if (jsonResponse != null && jsonResponse['adminResponseData'] != null) {
          final adminResponseData = jsonResponse['adminResponseData'];
          if (adminResponseData.isNotEmpty) {
            // Sort adminResponseData by date in descending order
            adminResponseData.sort((a, b) {
              final dateA = DateTime.parse(a['date_responded']);
              final dateB = DateTime.parse(b['date_responded']);
              return dateB.compareTo(dateA);
            });

            final latestResponse = adminResponseData[0];
            _reportStatus = latestResponse['report_status'];
          }
        }
      });
    } catch (error) {
      print(error);
    }
  }

  void viewNotification(String projectId) async {
    if (projectId == 'Not Applicable') {
      // Show a dialog to the user
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
                      'assets/send_report_images/submit_successfully.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Account Validation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your account has been successfully validated. You can now access the "Send Report" feature.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF338B93)),
                      textAlign: TextAlign.justify,
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
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          var regBody = {
                            "projectId": "Not Applicable",
                            "userId": userId,
                            "newStatus": "Read",
                          };

                          var response = await http.put(
                            Uri.parse(updateNotificationStatus),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(regBody),
                          );

                          var jsonResponse = jsonDecode(response.body);
                          setState(() {
                            _isLoading = false;
                          });

                          if (response.statusCode == 200 && jsonResponse['status'] == true) {
                            fetchUnreadNotificationsList();
                          } else {
                            print('Notification status update failed');
                          }
                        } catch (error) {
                          print(error);
                        }
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else if(projectId == 'For Report' && projectId != 'Not Applicable'){
      fetchUnreadNotificationsList();
    }
    else {
      setState(() {
        _isLoading = true;
      });

      try {
        var regBody = {
          "projectId": projectId,
          "userId": userId,
          "newStatus": "Read",
        };

        var response = await http.put(
          Uri.parse(updateNotificationStatus),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody),
        );

        var jsonResponse = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 && jsonResponse['status'] == true) {
          fetchUnreadNotificationsList();
        } else {
          print('Notification status update failed');
        }
      } catch (error) {
        print(error);
      }
    }
  }

  void viewReportNotification(String reportId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var regBody = {
        "userId": userId,
        "_id": reportId,
        "newStatus": "Read",
      };

      var response = await http.put(
        Uri.parse(updateReportNotificationStatus),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponse = jsonDecode(response.body);
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        fetchUnreadNotificationsList();
      } else {
        print('Notification status update failed');
      }
    } catch (error) {
      print(error);
    }
  }


  List? reportData;
  String? reportType;

  Future<void> fetchUserReportData(String _id) async {
    try {
      var response = await http.post(
        Uri.parse(getReportById),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"_id": _id}),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse != null && jsonResponse['userReport'] != null) {
        // Access 'userReport' from the response
        reportData = jsonResponse['userReport'];
        if (reportData != null && reportData!.isNotEmpty) {
          // Access 'report_type' from 'userReport'
          setState(() {
            reportType = reportData![0]['report_type'].toString();
            print(reportType);
          });
        } else {
          // Handle the case where 'userReport' data is empty or missing
        }
      }
    }  catch (error) {
      print(error);
    }
  }





  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    fetchUnreadNotificationsList();
    fetchReadNotifications();
    fetchUnreadNotifications(userId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Notification'),

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
                                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 20.0, 0.0),
                                    child: Container(
                                      height: 80,
                                      child: Center(
                                        child: Text(
                                          'Latest Posts and Reports Update',
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


                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedContentType == SelectedContentType.unread
                                      ?  Colors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedContentType = SelectedContentType.unread;
                                    });
                                  },
                                  child: Text(
                                    'Unread',
                                    style: TextStyle(fontSize: 13.0, color: selectedContentType == SelectedContentType.unread
                                        ? Colors.white
                                        : Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 30.0,
                              width: 20.0,
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedContentType == SelectedContentType.read
                                      ?  Colors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedContentType = SelectedContentType.read;
                                    });
                                  },
                                  child: Text(
                                    'Read',
                                    style: TextStyle(fontSize: 13.0, color: selectedContentType == SelectedContentType.read
                                        ?  Colors.white
                                        : Colors.blue),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (selectedContentType == SelectedContentType.unread)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: unreadItems?.length ?? 0,
                        itemBuilder: (context, index) {
                          return IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/logo/pasig_health_department_logo.png',
                                                    width: 60,
                                                    scale: 0.7,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8), //  spacng between the image and text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${unreadItems![index]['title']}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),

                                                  SizedBox(height: 4), // spacing between the two texts
                                                  Text(
                                                    '${unreadItems![index]['message']}',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 11,
                                                    ),
                                                    textAlign: TextAlign.justify,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 10), // spacing between the two texts
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 10),
                                                    child: Text(
                                                      "Date: " +
                                                          DateFormat('yyyy-MM-dd').format(DateTime.parse(unreadItems![index]['dateCreated'])),
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () async {
                                                      if (unreadItems![index]['projectId'] != 'Not Applicable' &&  unreadItems![index]['projectId'] != 'For Report') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => CommunityProjects2(
                                                              token: widget.token,
                                                              PassProjectId: unreadItems![index]['projectId'],
                                                              notificationCount: widget.notificationCount,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      else if (unreadItems![index]['projectId'] == 'For Report' && unreadItems![index]['projectId'] != 'Not Applicable') {
                                                        final reportId = unreadItems![index]['_id'];
                                                        final reportIdConnection = unreadItems![index]['reportId'];

                                                        setState(() {
                                                          fetchUserReportData(reportIdConnection);
                                                        });
                                                        final userReport = fetchUserReportData(reportIdConnection);
                                                        if (userReport != null) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ReportStatus(
                                                                token: widget.token,
                                                                notificationCount: widget.notificationCount,
                                                                reportStatus: _reportStatus,
                                                                reportId: unreadItems![index]['reportId'],
                                                                reportNumber: reportType.toString(),
                                                              ),
                                                            ),
                                                          );
                                                          viewReportNotification(unreadItems![index]['_id']);
                                                        }
                                                        else if (unreadItems![index]['projectId'] == 'Not Applicable'){
                                                          viewNotification(unreadItems![index]['projectId']);
                                                        }
                                                        else {
                                                          viewNotification(unreadItems![index]['projectId']);
                                                        }
                                                      }
                                                      viewNotification(unreadItems![index]['projectId']);

                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.blue,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15),
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

                    if (selectedContentType == SelectedContentType.read)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: readItems?.length ?? 0,
                        itemBuilder: (context, index) {
                          return IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/logo/pasig_health_department_logo.png',
                                                    width: 60,
                                                    scale: 0.7,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8), //  spacng between the image and text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${readItems![index]['title']}',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),

                                                  SizedBox(height: 4), // spacing between the two texts
                                                  Text(
                                                    '${readItems![index]['message']}',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 11,
                                                    ),
                                                    textAlign: TextAlign.justify,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 10), // spacing between the two texts
                                                  Padding(
                                                    padding: EdgeInsets.only(right: 10),
                                                    child: Text(
                                                      "Date: " +
                                                          DateFormat('yyyy-MM-dd').format(DateTime.parse(readItems![index]['dateCreated'])),
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
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: ()  async{
                                                      if (readItems![index]['projectId'] != 'Not Applicable' &&  readItems![index]['projectId'] != 'For Report') {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => CommunityProjects2(
                                                              token: widget.token,
                                                              PassProjectId: readItems![index]['projectId'],
                                                              notificationCount: widget.notificationCount,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                      else if (readItems![index]['projectId'] == 'For Report' && readItems![index]['projectId'] != 'Not Applicable') {
                                                        final reportId = readItems![index]['_id'];
                                                        final reportIdConnection = readItems![index]['reportId'];

                                                        setState(() {
                                                          fetchUserReportData(reportIdConnection);
                                                        });
                                                        final userReport = fetchUserReportData(reportIdConnection);
                                                        if (userReport != null) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ReportStatus(
                                                                token: widget.token,
                                                                notificationCount: widget.notificationCount,
                                                                reportStatus: _reportStatus,
                                                                reportId: readItems![index]['reportId'],
                                                                reportNumber: reportType.toString(),
                                                              ),
                                                            ),
                                                          );
                                                          viewReportNotification(readItems![index]['_id']);
                                                        }
                                                        else if (readItems![index]['projectId'] == 'Not Applicable'){
                                                        }
                                                        else {
                                                        }
                                                      }

                                                      else {
                                                        showDialog(
                                                          context: context,
                                                          builder: (
                                                              BuildContext context) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .circular(
                                                                    30.0),
                                                              ),
                                                              elevation: 4,
                                                              shadowColor: Colors
                                                                  .black,
                                                              content: SingleChildScrollView(
                                                                child: Container(
                                                                  width: MediaQuery
                                                                      .of(
                                                                      context)
                                                                      .size
                                                                      .width *
                                                                      0.8,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment
                                                                        .center,
                                                                    crossAxisAlignment: CrossAxisAlignment
                                                                        .center,
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/send_report_images/submit_successfully.png',
                                                                        width: 50,
                                                                        height: 50,
                                                                      ),
                                                                      SizedBox(
                                                                          height: 20),
                                                                      Text(
                                                                        'Account Validation',
                                                                        style: TextStyle(
                                                                            fontSize: 20,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .blue),
                                                                        textAlign: TextAlign
                                                                            .center,
                                                                      ),
                                                                      SizedBox(
                                                                          height: 20),
                                                                      Text(
                                                                        'Your account has been successfully validated. You can now access the "Send Report" feature.',
                                                                        style: TextStyle(
                                                                            fontSize: 16,
                                                                            color: Color(
                                                                                0xFF338B93)),
                                                                        textAlign: TextAlign
                                                                            .justify,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              actions: [
                                                                Center(
                                                                  child: Wrap(
                                                                    alignment: WrapAlignment
                                                                        .center,
                                                                    spacing: 10,
                                                                    children: [
                                                                      TextButton(
                                                                        onPressed: () async {
                                                                          Navigator
                                                                              .of(
                                                                              context)
                                                                              .pop();
                                                                        },
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius
                                                                                .circular(
                                                                                30.0),
                                                                          ),
                                                                          backgroundColor: Colors
                                                                              .blue,
                                                                        ),
                                                                        child: Text(
                                                                          'Back',
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .white),
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      primary: Colors.blue,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15),
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

                    SizedBox(height: 10,),

                    if (_isLoading)
                      Center(
                        child: CircularProgressIndicator(), //loading
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

class UserReport {
  final String reportId;
  final String report_type;  // Add other fields as needed

  UserReport({required this.reportId, required this.report_type});
}
