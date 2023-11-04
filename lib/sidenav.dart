import 'dart:convert';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/about_app/about_app.dart';
import 'package:capstone_mobile/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SideNavigation extends StatefulWidget  {
  final token;
  final int notificationCount;
  SideNavigation({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _SideNavigation createState() => _SideNavigation();
}

class _SideNavigation extends State<SideNavigation> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  late String _id;

  //fetched data container
  String _name = '';
  String _birthday = '';
  String _gender = '';
  String _contactNumber = '';
  String _barangay = '';
  String _email = '';
  String? profilePhotoBase64;
  List? items;

  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    _id = jwtDecodedToken['_id'];
    fetchUserInformation(_id);
  }

  Future<void> fetchUserInformation(String _id) async {
    try {
      var response = await http.post(
        Uri.parse(getUserData),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"_id": _id}),
      );

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse != null && jsonResponse['userInformationData'] != null) {
        setState(() {
          items = jsonResponse['userInformationData'];
          if (items!.isNotEmpty) {
            _name = items![0]['name'].toString();
            _email = items![0]['email'].toString();
            _birthday = items![0]['birthday'].toString();
            _gender = items![0]['gender'].toString();
            _contactNumber = items![0]['contact_number'].toString();
            profilePhotoBase64 = items![0]['profilePicture'].toString();
          }
        });
      }
    }  catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('token')) {
      final bool isRememberMe = prefs.containsKey('temporary_token');

      if (isRememberMe) {
        prefs.remove('token'); // Remove the permanent token
      } else {
        prefs.remove('token'); // Remove the permanent token
        prefs.remove('temporary_token'); // Remove the temporary token
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
  }



@override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/sidenav_images/sidenav_background_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _name,
                style: TextStyle(color: Colors.white),
              ),
              accountEmail: Text(
                _email,
                style: TextStyle(color: Colors.white),
              ),
              currentAccountPicture:  CircleAvatar(
                backgroundImage: profilePhotoBase64 != null
                    ? MemoryImage(base64Decode(profilePhotoBase64!))  as ImageProvider
                    : AssetImage('assets/sidenav_images/defaultProfile.jpg'),
                radius: 85,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            Column(
              children: [
                /**
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
                    **/
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
                                .token, notificationCount: widget.notificationCount,), // go to the next screen
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
                    title: Text('Logout'),
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
                                    'Are you sure you want to logout?',
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
                                      logout(); // Call the logout method
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Login(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            30.0),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text(
                                      'Logout',
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
    );
  }
}
