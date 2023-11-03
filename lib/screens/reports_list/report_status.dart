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
import 'package:timeline_tile/timeline_tile.dart';

import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'admin_response.dart';

class ReportStatus extends StatefulWidget {
  final token; final int notificationCount;
  final String reportStatus;
  final String reportId;
  final String reportNumber;
  ReportStatus({@required this.token, required this.reportStatus, Key? key, required this.reportId, required this.reportNumber, required this.notificationCount}) : super(key: key);

  @override
  _ReportStatusPage createState() => _ReportStatusPage();
}

class _ReportStatusPage extends State<ReportStatus> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }


  List<String> statusTitle = [
    'Recieved',
    'Responded',
  ];

  List<String> statusDescription = [
    'Your concern has been received by the Pasig Dengue Task and currently for reviewing.',
    'The team sent a response to your concern ',
    'The Pasig Dengue Task Force has provided necessary action to alleviate your concern. Thank you!',
  ];

  List<String> notificationDate = [
    '2023-07-15',
    '2023-07-16',
    '2023-07-17',
  ];

  List? StatusList;


  //text color of status
  Color getStatusColor(String reportStatus) {
    switch (reportStatus) {
      case 'New Report':
        return Colors.blue;
      case 'Under Review':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.black;
    }
  }


  Future<void> fetchAdminResponse(String reportId) async {
    try {
      final response = await http.post(
        Uri.parse(getAdminResponse),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"reportId": reportId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if adminResponseData is not null
        if (jsonResponse != null && jsonResponse['adminResponseData'] != null) {
          final adminResponseData = jsonResponse['adminResponseData'];

          // Update the StatusList
          setState(() {
            StatusList = jsonResponse['adminResponseData'];
            fetchAdminResponse(widget.reportId);
          });

        }
      } else {
        //print httperror
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
    finally {
    }
  }

  late String reportType = '';
  late String reportDate = '';

  Future<void> fetchReportType(String reportId) async {
    try {
      final response = await http.post(
        Uri.parse(getReportById),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"_id": reportId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Check if userReport is not null
        if (jsonResponse != null && jsonResponse['userReport'] != null) {
          final userReport = jsonResponse['userReport'];
          final userReportType = userReport['report_type'];
          final userReportDate = userReport['postedDate'];
          setState(() {
            reportType = userReportType;
            reportDate = userReportDate;
          });

          print('Report Type: $reportType');
        } else {
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


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
          fetchAdminResponse(widget.reportId);
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
          fetchAdminResponse(widget.reportId);
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
    fetchAdminResponse(widget.reportId);
    fetchReportType(widget.reportId);
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
  fetchUnreadNotificationsList();
    fetchUnreadNotifications(_id);

  }

  @override
  Widget build(BuildContext context) {
    if (StatusList == null || reportType==null || reportType == null ||
      StatusList.toString() == '' || reportType.toString() == '' || reportType.toString == '') {
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
                                        child: Column(
                                          children: [
                                            Text(
                                              reportType,
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              "Report Date: "+DateFormat('yyyy-MM-dd').format(DateTime.parse(reportDate)),
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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

                    (StatusList == null || StatusList!.isEmpty)
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
                      itemCount: StatusList?.length ?? 0,
                      itemBuilder: (context, index) {
                        var adminResponse = StatusList![index];
                        final bool isLastItem = index ==
                            StatusList!.length - 1;
                        final Color dotColor = isLastItem ? Colors
                            .lightGreenAccent : Colors.white;
                        return TimelineTile(
                          alignment: TimelineAlign.start,
                          isFirst: index == 0,
                          isLast: index == StatusList!.length - 1,
                          indicatorStyle: IndicatorStyle(
                            width: 20,
                            color: dotColor,
                            // Set the color based on the condition
                            padding: EdgeInsets.all(4),
                          ),
                          beforeLineStyle: LineStyle(
                            color: Colors.white,
                            thickness: 4,
                          ),
                          endChild: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
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
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          Image.asset(
                                            'assets/report_list_images/report_icon_2.png',
                                            width: 60,
                                            scale: 0.7,
                                          ),
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
                                            '${StatusList![index]['report_status']}',
                                            style: TextStyle(
                                              color: getStatusColor(StatusList![index]['report_status']),
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          // spacing between the two texts
                                          Text(
                                            '${StatusList![index]['response_description']}',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                          SizedBox(height: 10),
                                          // spacing between the two texts
                                          Padding(
                                            padding: EdgeInsets.only(
                                                right: 10),
                                            child: Text(
                                              "Date Responded: " + DateFormat('yyyy-MM-dd').format(DateTime.parse(StatusList![index]['date_responded'])),
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 11,
                                              ),
                                              textAlign: TextAlign.left,
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
                                                      ResponseContent(
                                                        token: widget
                                                            .token,
                                                        PassResponseId: adminResponse['_id'],
                                                        PassResponseStatus: adminResponse['report_status'],
                                                        PassResponseDescription: adminResponse['response_description'],
                                                        PassRepondedDate: adminResponse['date_responded'],
                                                        PassUploadedFile: (adminResponse['uploaded_file'] as List).map((item) => item.toString()).toList(),
                                                        notificationCount: widget.notificationCount,
                                                      ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: Color(0xff28376D),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(15),
                                              ),
                                            ),
                                            icon: Icon(
                                              Icons.content_paste_search,
                                              color: Colors.white,
                                            ),
                                            label: Text(
                                              ' View ',
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


