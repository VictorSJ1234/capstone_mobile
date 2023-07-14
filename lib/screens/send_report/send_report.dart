import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SendReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
                                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 0.0),
                                    child: Container(
                                      height: 80,
                                      child: Center(
                                        child: Text(
                                          'Community Reporting:\nA helping aid for Pasig Dengue\nTask Force',
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
                              color: Colors.white,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  hintText: 'Select Barangay',
                                  contentPadding: EdgeInsets.all(15.0),
                                ),
                                items: ['Barangay 1', 'Barangay 2', 'Barangay 3']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {

                                },
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
                              color: Colors.white,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'Subject of Report',
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
                                borderRadius: BorderRadius.circular(0.0),
                                color: Colors.white,
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
                              color: Colors.white,
                              child: TextFormField(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 50),
                              child: ElevatedButton(
                                onPressed: () {
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  primary: Color(0xff1BCBF9),
                                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  'Send Report',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ),
                          ],
                        )
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