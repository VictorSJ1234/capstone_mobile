import 'dart:convert';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/repellents.dart';
import 'package:capstone_mobile/screens/reports_list/report_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../about_app/about_app.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';
import 'package:http/http.dart' as http;

class ReportList extends StatefulWidget {
  final token;
  ReportList({@required this.token,Key? key}) : super(key: key);
  @override
  _ReportList createState() => _ReportList();
}
class _ReportList extends State<ReportList> {

  late String userId;
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    fetchUserReports(userId);
  }

  Future<void> fetchUserReports(String userId) async {
    try {
      var response = await http.post(
        Uri.parse(getUserReport),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      var jsonResponse = jsonDecode(response.body);
      setState(() {
        items = jsonResponse['userReportData'];
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
        ), // Display a loading indicator while fetching data
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C65DE), Color(0xFF1BC3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            'User Reports',
            style: TextStyle(fontFamily: 'SquadaOne'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(token: widget.token),
                  ),
                );
              },
            ),
          ],
        ),

        //sidenav
        drawer: Drawer(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/sidenav_images/sidenav_background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    'Lebron James',
                    style: TextStyle(color: Colors.white),
                  ),
                  accountEmail: Text(
                    'kingjames@gmail.com',
                    style: TextStyle(color: Colors.white),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage(
                        'assets/sidenav_images/lebron1.png'),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.language, color: Colors.white,),
                      title: Text(
                        'Language', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        // Navigator.pop(context); // Hide the navigation before going to the nexxt screen
                        //Navigator.push(
                        //context,
                        //  MaterialPageRoute(
                        // builder: (context) => LanguageSettings(), // go to the next screen
                        // ),
                        // );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.info, color: Colors.white,),
                      title: Text(
                        'About App', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        Navigator.pop(
                            context); // Hide the navigation before going to the nexxt screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AboutApp(token: widget
                                    .token), // go to the next screen
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.people, color: Colors.white,),
                      title: Text(
                        'Developers', style: TextStyle(color: Colors.white),),
                      onTap: () {
                        //Navigator.pop(context);
                        // Navigator.push(
                        //context,
                        //MaterialPageRoute(
                        // builder: (context) => Developers(),
                        //),
                        // );
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.exit_to_app_sharp, color: Colors.black,),
                        title: Text('Exit'),
                        onTap: () {
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
                                        'Are you sure you want to exit?',
                                        style: TextStyle(fontSize: 16),
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
                                            borderRadius: BorderRadius.circular(
                                                30.0),
                                          ),
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      TextButton(
                                        onPressed: () {
                                          SystemNavigator.pop();
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30.0),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                        child: Text(
                                          'Exit',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        //content
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/background/background4.png',
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
                      if (items == null ||
                          items!.isEmpty) // Check if items is null or empty
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No reports available.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                                                  Text("Report "+'${items![index]['report_number']}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight
                                                            .bold),),
                                                  Image.asset(
                                                    'assets/report_list_images/report_icon.png',
                                                    width: 60,
                                                    scale: 0.7,
                                                  ),
                                                  Text('Report ID#',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight
                                                            .bold),),
                                                  Text(
                                                    '${items![index]['reportId']}',
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        fontWeight: FontWeight
                                                            .normal),),
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
                                                    'Subject of Report',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
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
                                                      fontSize: 11,
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
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Text(
                                                      "Date: " +
                                                          report['postedDate'],
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 11,
                                                      ),
                                                      textAlign: TextAlign
                                                          .justify,
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
                                                                PassReportSubject: report['report_subject'],
                                                                PassReportId: report['reportId'],
                                                                PassReportNumber: "Report $reportNumber",
                                                                PassReportDescription: report['report_description'],
                                                                PassReportDate: report['postedDate'],
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Colors.blue,
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
                                                      // Handle delete button press
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
                            builder: (context) => MainMenu(token: widget.token),
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
                                UserProfile(token: widget.token),
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
