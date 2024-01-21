import 'dart:convert';

import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/login/login.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/register/register.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';

import 'package:capstone_mobile/sidenav.dart';


class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPassword createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {

  bool rememberMe = false; //default tickbox value
  bool isButtonPressed = false; //initial button status
  final formKey = GlobalKey<FormState>();


  TextEditingController _emailController = TextEditingController();
  var passwordController = new TextEditingController();
  var repeatPasswordController = new TextEditingController();

  String credentialInvalid = '';
  bool _isPasswordVisible = false;
  late SharedPreferences prefs;

  bool _errorMesage = false;
  String _errorMessage = '';
  bool _isLoading = false;
  bool passwordsMatch = true;

  Future<void> _confirmChange() async{
    setState(() {
      _isLoading = true;
    });
    // Check for network/internet connectivity
    try {
      await http.get(Uri.parse('https://www.google.com'));
    } catch (networkError) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Network Error"),
            content: Text("Please check your network/internet connection."),
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
      return;
    }
    try {
      // Prepare the updated user information
      var updatedData = {
        "email" : _emailController.text.toString(),
        "newPassword": passwordController.text.toString(),
      };

      // Make an HTTP PUT request to update the user information
      var response = await http.post(
        Uri.parse(resetPassword),
        // api end point
        headers: {
        "Content-Type": "application/json",
        "x-api-key": 'pasigdtf',
      },
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
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                            (route) => false,
                      );
                    }
                    ,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      'Go to Login Page',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        // User information updated successfully
        // done na
      }
      else if (response.statusCode == 404 || response.statusCode == 500) {
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
              content: Text("Email address does not exist!"),
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

  Future<void> updateUserInformation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await http.get(Uri.parse('https://www.google.com'));
    } catch (networkError) {
      // Handle network/internet connection error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          _isLoading = false;
          return AlertDialog(
            title: Text("Network Error"),
            content: Text("Please check your network/internet connection."),
            actions: [
              TextButton(
                onPressed: () {
                  _isLoading = false;
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check if any of the required fields are empty
    if (passwordController.text.isEmpty || _emailController.text.isEmpty  || repeatPasswordController.text.isEmpty || passwordController.text.isEmpty ||
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
                      'Are you sure you want to reset your password because you forgot it?',
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _clearFields(){
    passwordController.text="";
    repeatPasswordController.text="";
    repeatPasswordController.text="";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
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
              padding: const EdgeInsets.only(bottom: 100, top: 40, left: 15, right: 20),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    /**
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 10),
                          child: Image.asset(
                            'assets/logo/pasig_health_department_logo.png',
                            width: 130,
                            height: 130,
                          ),
                        ),
                      ],
                    ),
                        **/
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(15, 10.0, 0.0, 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 8.0, 20.0, 8.0),
                                    child: Container(
                                      height: 70,
                                      child: Text(
                                        'Pasig Dengue Task Force:\nMosquinator',
                                        style: TextStyle(
                                          fontFamily: 'Outfit',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
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
                                  'Email',
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
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email),
                                      hintText: 'Email',
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
                        isButtonPressed
                            ? (_emailController == null || _emailController!.text.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)
                            ? Container(
                          padding: EdgeInsets.only(left: 8.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            // Display an error message if the field is empty and did not follow the pattern
                            'Invalid Email Address!',
                            style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                          ),
                        )
                            : Container()) // If the field is not empty, display an empty Container
                            : Container(), // If the field is not empty, display an empty Container


                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                              child: SizedBox(
                                child: Text(
                                  'New Password',
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
                                  'Repeat Password',
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

                        SizedBox(height: 10,),

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

                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//test