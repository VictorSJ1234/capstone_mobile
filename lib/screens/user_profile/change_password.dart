import 'dart:convert';
import 'dart:io';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import 'package:http/http.dart' as http;


class ChangePassword extends StatefulWidget  {
  final token; final int notificationCount;

  ChangePassword({
    @required this.token, Key? key, required this.notificationCount,}) : super(key: key);
  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  void updateUnreadCardCountGlobally(int count) {
    updateUnreadCardCount(count);
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
  bool _isLoading = false;

  final formKey = GlobalKey<FormState>();
  bool isButtonPressed = false; //initial button status

  var currentPasswordController = new TextEditingController();
  var passwordController = new TextEditingController();
  var repeatPasswordController = new TextEditingController();
  bool _isPasswordVisible = false;
  bool passwordsMatch = true;

  Future<void> updateUserInformation() async {
    setState(() {
      _isLoading = true;
    });
    // Check if any of the required fields are empty
    if (passwordController.text.isEmpty || repeatPasswordController.text.isEmpty || currentPasswordController.text.isEmpty ||
        !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[.!@#$%^&*_-])[A-Za-z\d.!@#$%^&*_-]{10,}$').hasMatch(passwordController.text)) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
        _isLoading = false;
      });
    }

    else if (passwordController.text != repeatPasswordController.text) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
        passwordsMatch = false;
        _isLoading = false;
      });
    }

    else {
      setState(() {
        _isLoading = true;
      });
      passwordsMatch = true;
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
                      'Are you sure you want to edit your password?',
                      style: TextStyle(fontSize: 16, color: Color(0xFF338B93), fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10,),
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
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
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
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        _confirmChange();
                        setState(() {
                          _isLoading = true;
                        });
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
                          'Confirm',
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
    }
  }

  Future <void> _confirmChange() async{
    setState(() {
      _isLoading = true;
    });
    try {
      // Prepare the updated user information
      var updatedData = {
        "password" : currentPasswordController.text.toString(),
        "newPassword": passwordController.text.toString(),
      };

      // Make an HTTP PUT request to update the user information
      var response = await http.put(
        Uri.parse(editPassword + '/$_id'),
        // api end point
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        _clearFields();
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
                          width: 100,
                          height: 100
                      ),
                      SizedBox(height: 10),
                      SizedBox(height: 20),
                      Text(
                        'Your password has been changed successfully!',
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
                          setState(() {
                            _isLoading = false;
                          });
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
                            'Done',
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
        // User information updated successfully
        // done na
      }
      else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
        });
        // Registration failed due to duplicate email
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Failed Changing Password"),
              content: Text("Your current password is incorrect."),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
      else {
        setState(() {
          _isLoading = false;
        });
        // Handle errors, e.g., display an error message
        print("Error updating user information: ${response.statusCode}");
      }
    } catch (error) {
      print(error);
    }
  }
  void _clearFields(){
    currentPasswordController.text="";
    passwordController.text="";
    repeatPasswordController.text="";
  }



  @override
  void initState() {
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchUnreadNotifications(_id);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'User Profile'),

      //sidenav
      drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

      //content
      body: Stack(
        children: [
          // Background Image
          /*
          Positioned.fill(
            child: Image.asset(
              'assets/background/background6.png',
              fit: BoxFit.cover,
            ),
          ),

           */
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  bottom: 100, top: 15, left: 15, right: 20),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      key: formKey,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                              child: SizedBox(
                                child: Text(
                                  'Current Password *',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
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
                                    controller: currentPasswordController,
                                    obscureText: !_isPasswordVisible,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock),
                                      hintText: 'Current Password',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(15.0),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                        child: Icon(
                                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        isButtonPressed
                            ? (currentPasswordController == null || currentPasswordController!.text.isEmpty
                            ? Container(
                          padding: EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // Display an error message if the field is empty
                            'Please enter your current password!',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        )
                            : Container())
                            : Container(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                              child: SizedBox(
                                child: Text(
                                  'New Password *',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
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
                                    controller: passwordController,
                                    obscureText: !_isPasswordVisible,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.lock),
                                      hintText: 'New Password',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(15.0),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                        },
                                        child: Icon(
                                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        isButtonPressed
                            ? (passwordController == null || passwordController!.text.isEmpty || !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[.!@#$%^&*_-])[A-Za-z\d.!@#$%^&*_-]{10,}$').hasMatch(passwordController.text)
                            ? Container(
                          padding: EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // Display an error message if the field is empty
                            'Password must include atleast one uppercase and lowercase letter, one digit, one special character, must be at least 10 characters long',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        )
                            : Container())
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                              child: SizedBox(
                                child: Text(
                                  'Repeat Password *',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
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
                                    controller: repeatPasswordController,
                                    obscureText: true, // Make this field obscure for password input
                                    decoration: InputDecoration(
                                      hintText: 'Repeat Password',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(15.0),
                                      prefixIcon: Icon(Icons.lock),
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        isButtonPressed
                            ? (repeatPasswordController.text.isEmpty
                            ? Container(
                          padding: EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // Display an error message if the field is empty
                            'This field is required!',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        )
                            : !passwordsMatch
                            ? Container(
                          padding: EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // Display an error message if passwords do not match
                            'Passwords do not match!',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        )
                            : Container())
                            : Container(),

                        SizedBox(height: 10),

                        Visibility(
                          visible: !_isLoading,
                          replacement: Center(
                            child: CircularProgressIndicator(), // Show a loading indicator if loading
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, top: 30, bottom: 5),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Future.delayed(Duration.zero, () {
                                          updateUserInformation();
                                        });
                                      },

                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        primary: Color(0xff28376d),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Save',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        Visibility(
                          visible: !_isLoading,
                          replacement: Center(
                            child: SizedBox(), // Show a loading indicator if loading
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, top: 20, bottom: 30),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        primary: Colors.redAccent,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.0, horizontal: 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Back',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
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
                              ReportList(token: widget.token, notificationCount: widget.notificationCount,),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/user.png'),
                    onPressed: () {
                      //already in user profile
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