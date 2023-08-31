import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/report_status.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../about_app/about_app.dart';
import '../notification/notification.dart';
import '../user_profile/user_profile.dart';


class ReportContent extends StatefulWidget {
  final token;
  final String PassReportSubject;
  final String PassReportNumber;
  final String PassReportId;
  final String PassReportDescription;
  final String PassReportDate;
  ReportContent({@required this.token,Key? key, required this.PassReportSubject, required this.PassReportNumber, required this.PassReportId, required this.PassReportDate, required this.PassReportDescription}) : super(key: key);
  @override
  _ReportContent createState() => _ReportContent();
}

class _ReportContent extends State<ReportContent> {

  List<String> reportStatus = [
    'Received',
  ];

  List<String> images = [
    'assets/report_list_images/report_icon.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
              image: AssetImage('assets/sidenav_images/sidenav_background.png'),
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
                  backgroundImage: AssetImage('assets/sidenav_images/lebron1.png'),
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.white,),
                    title: Text('Language', style: TextStyle(color: Colors.white),),
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
                    title: Text('About App', style: TextStyle(color: Colors.white),),
                    onTap: () {
                      Navigator.pop(context); // Hide the navigation before going to the nexxt screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutApp(token: widget.token), // go to the next screen
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.white,),
                    title: Text('Developers', style: TextStyle(color: Colors.white),),
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
                      leading: Icon(Icons.exit_to_app_sharp, color: Colors.black,),
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
                                          borderRadius: BorderRadius.circular(30.0),
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
                                          borderRadius: BorderRadius.circular(30.0),
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
                                          widget.PassReportNumber,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 5.0, 0.0, 0.0),
                          child: SizedBox(
                            child: Text(
                              'Barangay',
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
                                initialValue: 'Palatiw', style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Barangay',
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
                              'Subject of Report',
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
                                initialValue: widget.PassReportSubject, style: TextStyle(color: Colors.black),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.white,
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  //file upload
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.attach_file,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Upload Picture/Video',
                                      style: TextStyle(
                                        color: Color(0xff666666),
                                        fontSize: 16.0,
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
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
                    ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
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
                                          SizedBox(width: 8), // spacing between the image and text
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  reportStatus[0], // Use the first status
                                                  style: TextStyle(
                                                    color: Colors.black,
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
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ReportStatus(token: widget.token),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    primary: Colors.blue,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                  ),
                                                  icon: Icon(
                                                    Icons.content_paste_search,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    ' View Status ',
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
                              'Description of Report',
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
                            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black),
                              ),
                              child: TextFormField(
                                enabled: false,
                                initialValue:widget.PassReportDescription, style: TextStyle(color: Colors.black),
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
                          builder: (context) => MainMenu(token: widget.token),
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
                          builder: (context) => ReportList(token: widget.token),
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
                          builder: (context) => UserProfile(token: widget.token),
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