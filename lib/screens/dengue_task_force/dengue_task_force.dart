import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class DengueTaskForce extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff10CFF0),
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
        title: Text('Anti-Dengue Task Force', style: TextStyle(fontFamily: 'SquadaOne'),),
      ),

      //sidenav
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_images/123.jpg'),
              colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.6), BlendMode.srcATop),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  'Lebron James',
                  style: TextStyle(color: Colors.black),
                ),
                accountEmail: Text(
                  'kingjames@gmail.com',
                  style: TextStyle(color: Colors.black),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar_images/batman.png'),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_images/sidenav_back.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.white,),
                    title: Text('Language'),
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
                    leading: Icon(Icons.settings, color: Colors.white,),
                    title: Text('Theme Settings'),
                    onTap: () {
                      //Navigator.pop(context);
                      // Navigator.push(
                      // context,
                      // MaterialPageRoute(
                      //   builder: (context) => ThemeSettings(),
                      // ),
                      //  );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.white,),
                    title: Text('About'),
                    onTap: () {
                      // Navigator.pop(context);
                      // Navigator.push(
                      // context,
                      // MaterialPageRoute(
                      //  builder: (context) => About(),
                      // ),
                      //);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.white,),
                    title: Text('Developers'),
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
                      leading: Icon(Icons.exit_to_app, color: Colors.white,),
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
                                      'assets/avatar_images/Logo.png',
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
                                    'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit.',
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
                      padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 10.0),
                      child: SizedBox(
                        child: Text(
                          'Contact Information',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Outfit'),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Button 1
                        Container(
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
                          child: TextButton(
                            onPressed: () {
                              // email
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/task_force_images/email.png',
                                  width: 65,
                                  height: 60,
                                ),
                                Text(
                                  'Email',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Button 2
                        Container(
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
                          child: TextButton(
                            onPressed: () {
                              // tel. no.
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/task_force_images/phone.png',
                                  width: 65,
                                  height: 60,
                                ),
                                Text(
                                  'Tel. No.',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Button 3
                        Container(
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
                          child: TextButton(
                            onPressed: () {
                              // location
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/task_force_images/location.png',
                                  width: 65,
                                  height: 60,
                                ),
                                Text(
                                  'Location',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Button 1
                        Container(
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
                          child: TextButton(
                            onPressed: () {
                              // email
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/task_force_images/service.png',
                                  width: 65,
                                  height: 60,
                                ),
                                Text(
                                  'Service 1',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Button 2
                        Container(
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
                          child: TextButton(
                            onPressed: () {
                              // tel. no.
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/task_force_images/service.png',
                                  width: 65,
                                  height: 60,
                                ),
                                Text(
                                  'Service 2',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Button 3
                        Container(
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
                          child: TextButton(
                            onPressed: () {
                              // location
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/task_force_images/service.png',
                                  width: 65,
                                  height: 60,
                                ),
                                Text(
                                  'Service 3',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
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
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                       builder: (context) => MainMenu(),
                      ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/list.png'),

                    onPressed: () {
                      //Navigator.push(
                      //context,
                      //MaterialPageRoute(
                      // builder: (context) => LeaderBoard(),
                      //),
                      //);
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/user.png'),
                    onPressed: () {
                      //Navigator.push(
                      //context,
                      //MaterialPageRoute(
                      //builder: (context) => UserProfile(),
                      //),
                      //);
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