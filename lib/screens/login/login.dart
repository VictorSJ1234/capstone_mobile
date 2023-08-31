import 'dart:convert';

import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/register/register.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';

import '../about_app/about_app.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool rememberMe = false; //default tickbox value


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String credentialInvalid = '';
  bool _isPasswordVisible = false;
  late SharedPreferences prefs;

  bool _errorMesage = false;
  String _errorMessage = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async{
    prefs = await SharedPreferences.getInstance();
  }


  Future<void> _login() async {
    // Check for network/internet connectivity
    try {
      await http.get(Uri.parse('https://www.google.com'));
    } catch (networkError) {
      // Handle network/internet connection error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Network Error"),
            content: Text("Please check your network/internet connection."),
            actions: [
              TextButton(
                onPressed: () {
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

    // Prepare the request body with inputted user's email and password
    var reqBody = {
      "email": _emailController.text,
      "password": _passwordController.text
    };

    var response = await http.post(
      Uri.parse(login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reqBody),
    );

    //200 is code for ok
    if (response.statusCode == 200) {
      // Successful login
      var jsonResponse = jsonDecode(response.body);
      print("JSON response: $jsonResponse");
      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenu(token: myToken),
          ),
        );
      }
    }

    //404 is code for user does not found
    else if (response.statusCode == 404) {
        setState(() {
          _errorMesage = true;
          _errorMessage = 'Invalid login credentials. Please try again.';
        });
    }

    //401 is for Unauthorized account
    else if (response.statusCode == 401) {
        setState(() {
          _errorMesage = true;
          _errorMessage = 'Invalid login credentials. Please try again.';
        });
    }

    //401 is for Unauthorized account
    else if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMesage = true;
        _errorMessage = 'Please fill in both email and password fields.';
      });
    }

    else {
      // login failed due to other reasons
      // Show generic error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registration Failed"),
            content: Text("An error occurred during registration."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              'assets/background/background4.png',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xffF3F4F7),
                                  borderRadius: BorderRadius.circular(30.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Register(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Register',
                                            style: TextStyle(fontSize: 16.0, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30.0,
                                      width: 1.0,
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(30.0)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            //already in login
                                          },
                                          child: Text(
                                            '   Login   ',
                                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                                          ),
                                        ),
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
                          padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                          child: SizedBox(
                            child: Text(
                              'Email',
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
                                controller: _emailController,
                                decoration: InputDecoration(
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                          child: SizedBox(
                            child: Text(
                              'Password',
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
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  hintText: 'Password',
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

                    SizedBox(height: 10,),

                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                rememberMe = !rememberMe;
                              });
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  "Remember me",
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              // Handle forgot password logic
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(fontSize: 14, color: Colors.blueAccent),
                            ),
                          ),
                        ],
                      ),
                    ),



                    if (_errorMesage==true)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),



                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  primary: Color(0xff0292EB),
                                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),



                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Don't have an account yet? ",
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            InkWell(
                              onTap: () {
                              },
                              child: Text(
                                "Register here",
                                style: TextStyle(fontSize: 14, color: Colors.blueAccent, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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