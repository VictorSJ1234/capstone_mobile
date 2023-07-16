import 'package:capstone_mobile/screens/about_app/about_app.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/dengue_task_force/dengue_task_force.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/notification/notification.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:capstone_mobile/screens/send_report/send_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mosquitopedia/diseases.dart';
import 'user_profile/user_profile.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
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
            'Main Menu',
            style: TextStyle(fontFamily: 'SquadaOne'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(),
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
                        //
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
                            builder: (context) => AboutApp(), // go to the next screen
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
                'assets/background/background3.png',
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
                                            builder: (context) => MosquitopediaMenu(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff00C3FF),
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
                                      'assets/main_menu_images/dengue_task_force.png',
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
                                            builder: (context) => DengueTaskForce(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff00C3FF),
                                        minimumSize: Size(120, 50),
                                      ),
                                      child: Text('Dengue \n Task Force', style: TextStyle(fontSize: 15),
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
                                      onPressed: () {
                                         Navigator.push(
                                          context,
                                         MaterialPageRoute(
                                         builder: (context) => CommunityProjects(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shadowColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff00C3FF),
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
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                         builder: (context) => SendReport(),
                                        ),
                                         );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        backgroundColor: Color(0xff00C3FF),
                                        minimumSize: Size(110, 50),
                                      ),
                                      child: Text('Send a \n Report', style: TextStyle(fontSize: 15),
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
                            builder: (context) => ReportList(),
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
                            builder: (context) => UserProfile(),
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