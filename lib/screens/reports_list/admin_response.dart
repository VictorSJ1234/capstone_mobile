import 'dart:io';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/report_status.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../config.dart';
import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import '../user_profile/user_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class ResponseContent extends StatefulWidget {
  final token; final int notificationCount;
  final String PassResponseId;
  final String PassResponseStatus;
  final String PassResponseDescription;
  final String PassRepondedDate;
  final List<String> PassUploadedFile;

  ResponseContent({@required this.token,Key? key, required this.PassResponseId, required this.PassResponseStatus, required this.PassResponseDescription, required this.PassRepondedDate, required this.PassUploadedFile, required this.notificationCount, }) : super(key: key);
  @override
  _ResponseContent createState() => _ResponseContent();
}

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

class _ResponseContent extends State<ResponseContent> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }


  late String reportId;
  String _reportStatus = '';
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

  @override
  void initState() {
    super.initState();
    reportId = widget.PassResponseId;
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchReportStatus(reportId);
    fetchUnreadNotifications(_id); 
  }

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

  Uint8List decodeBase64ToBytes(String base64String) {
    Uint8List bytes = Uint8List.fromList(base64Decode(base64String));
    return bytes;
  }

  String getFileTypeFromBase64(String base64String) {
    // Detect the file type based on the base64 string

    // Common patterns for image/jpeg (JPEG)
    if (base64String.startsWith('/9j/') || base64String.startsWith('/9J/') || base64String.startsWith('/9f/') || base64String.startsWith('/9F/')
    || base64String.startsWith('/9j/4') || base64String.startsWith('/9J/4')) {
      return 'image/jpeg';
    }

    // Common patterns for image/png (PNG)
    if (base64String.startsWith('iVBORw0') || base64String.startsWith('iVBORw0KGgo') || base64String.startsWith('iVBORw0KGg') || base64String.startsWith('iVBORw0KGgA')) {
      return 'image/png';
    }

    // Common patterns for application/pdf (PDF)
    if (base64String.startsWith('JVBERi0xLj') || base64String.startsWith('JVBERi0xMj') || base64String.startsWith('JVBERi0xNb') || base64String.startsWith('JVBERi0xNT')) {
      return 'application/pdf';
    }

    // Common patterns for application/vnd.openxmlformats-officedocument.wordprocessingml.document (DOCX)
    if (base64String.startsWith('UEsFBgABAA') || base64String.startsWith('UEsFBgACAA') ||
        base64String.startsWith('UEsFBgACAAEA') || base64String.startsWith('UEsFBgACAAIA') ||
        base64String.startsWith('data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,')) {
      return "application/docx";
    }

    // Default to octet-stream if the type cannot be reliably detected
    return 'application/octet-stream';
  }



  List<String> reportStatus = [
    'Received',
  ];

  List<String> images = [
    'assets/report_list_images/report_icon_2.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Response and Status'),

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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      child: Container(
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
                                      'assets/logo/pasig_health_department_logo.png',
                                      width: 100,
                                      scale: 0.8,
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
                                      'Dengue Task Force',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 23,
                                        fontWeight: FontWeight
                                            .bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    // spacing between the two texts
                                    Text(
                                      'denguetaskforce@gmail.com',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign
                                          .justify,
                                      maxLines: 2,
                                      overflow: TextOverflow
                                          .ellipsis,
                                    ),
                                    SizedBox(height: 10),
                                    // spacing between the two texts
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 5.0, 0.0, 0.0),
                          child: SizedBox(
                            child: Text(
                              'Status',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextFormField(
                                enabled: false,
                                initialValue: widget.PassResponseStatus, style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Response Status',
                                  contentPadding: EdgeInsets.all(15.0),
                                  border: InputBorder.none,
                                ),
                                maxLines: null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                          child: SizedBox(
                            child: Text(
                              'Response Date',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextFormField(
                                enabled: false,
                                initialValue: DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.PassRepondedDate)),
                                style: TextStyle(color: Colors.black), // Set the text style here
                                decoration: InputDecoration(
                                  hintText: 'Subject of Report',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(15.0),
                                ),
                                maxLines: null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                            child: Container(
                              child: widget.PassUploadedFile.isNotEmpty
                                  ? Row(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                                        child: SizedBox(
                                          child: Text(
                                            'Attachment',
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                                  : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Center(
                                  child: Text(
                                    'No uploaded file',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: widget.PassUploadedFile.map((base64String) {
                        Uint8List bytes = decodeBase64ToBytes(base64String);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1),
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
                                          images[0],
                                          width: 60,
                                          scale: 0.7,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Attachment ${widget.PassUploadedFile.indexOf(base64String) + 1}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
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
                                            final fileType = getFileTypeFromBase64(base64String);
                                            final fileName = 'report_attachment.extension'; // Set the appropriate file name and extension

                                            // Create a temporary file to write the base64 data to
                                            final tempFile = await File('${(await getTemporaryDirectory()).path}/$fileName').create(recursive: true);
                                            final bytes = base64.decode(base64String);
                                            await tempFile.writeAsBytes(bytes);

                                            // Open the file using the open_file package
                                            OpenFile.open(tempFile.path, type: fileType);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xff28376D),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                          icon: Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            ' View File ',
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
                        );
                      }).toList(),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                          child: SizedBox(
                            child: Text(
                              'Response',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 15.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextFormField(
                                enabled: false,
                                initialValue:widget.PassResponseDescription, style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Description of Report',
                                  contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                                ),
                                maxLines: 5,
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