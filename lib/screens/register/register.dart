import 'dart:convert';

import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/login/login.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';

import '../about_app/about_app.dart';


class Register extends StatefulWidget  {
  Register({Key? key}) : super(key: key);
  @override
  _DatePickerFormState createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<Register> {
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        birthdayController.text = _dateFormat.format(_selectedDate!);
      });
    }
  }
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
  }

  final formKey = GlobalKey<FormState>();
  bool isButtonPressed = false; //initial button status

  //user input data containers
  var nameController = new TextEditingController();
  var birthdayController = new TextEditingController();
  String? selectedGender;
  var contactNumberController = new TextEditingController();
  String? selectedBarangay;
  var emailController = new TextEditingController();
  var passwordController = new TextEditingController();

  //user registration function
  void registerUser() async{

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

    // Check if any of the required fields are empty
    if (selectedBarangay == null || nameController.text.isEmpty ||
        selectedGender == null || contactNumberController.text.isEmpty ||
        birthdayController.text.isEmpty || contactNumberController.text.isEmpty ||
        emailController.text==null || passwordController.text.isEmpty || !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(passwordController.text)||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text)) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
      });
      /*
      // Show a snackbar or any other feedback to inform the user about the missing fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );

       */
      return;
    }
    else {

      // Prepare the registration request body that will be passed to the api and db
      var regBody = {
        "name":nameController.text.toString(),
        "birthday":birthdayController.text.toString(),
        "gender":selectedGender.toString(),
        "contact_number":contactNumberController.text.toString(),
        "barangay":selectedBarangay.toString(),
        "email":emailController.text.toString(),
        "password":passwordController.text.toString(),
        "profilePicture": "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"
            "D/2gAIAQMBAT8ArGPomoYx186Iz//Z".toString(),
      };

      // Send a POST request to the registration endpoint
      var response = await http.post(Uri.parse(registration),
        headers: {"Content-Type":"application/json"},
        body: jsonEncode(regBody)
      );

      print(response);

      //for testing only
      print(nameController.text);
      print(birthdayController.text);
      print(selectedGender);
      print(contactNumberController.text);
      print(selectedBarangay);
      print(emailController.text);
      print(passwordController.text);

      if (response.statusCode == 200) {
        _clearFields();//clear all fields
        // Registration successful
        // Show success dialog
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
                      'assets/send_report_images/submit_successfully.png',
                      width: 100,
                      height: 100,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Congratulations!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'You account has been successfully created.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                      );
                    },
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
      } else if (response.statusCode == 400) {
        // Registration failed due to duplicate email
        // Show error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Registration Failed"),
              content: Text("Email address already exist."),
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
      } else {
        // Registration failed due to other reasons
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
  }

  //funtion to clear all fields after submitting
  void _clearFields(){
    nameController.text="";
    selectedBarangay.toString()!=null;
    selectedGender.toString()!=null;
    birthdayController.text="";
    contactNumberController.text="";
    emailController.text="";
    passwordController.text="";
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
                                          onPressed: () {  },
                                          child: Text(
                                            'Register',
                                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
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
                                                builder: (context) => Login(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '   Login   ',
                                            style: TextStyle(fontSize: 16.0, color: Colors.grey),
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

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                                child: SizedBox(
                                  child: Text(
                                    'Name',
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
                                      controller: nameController,
                                      decoration: InputDecoration(
                                        hintText: 'Name',
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
                              ? (nameController == null || nameController!.text.isEmpty
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'This field is required!',
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
                                    // Display an error message if the field is empty
                                    'Date of Birth',
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
                                    child: InkWell(
                                      onTap: () => _selectDate(context),
                                      child: IgnorePointer(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            hintText: _selectedDate != null
                                                ? _dateFormat.format(_selectedDate!)
                                                : 'Select Date of Birth',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(15.0),
                                            prefixIcon: Icon(Icons.calendar_today),
                                          ),
                                          maxLines: null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isButtonPressed
                              ? (birthdayController == null || birthdayController.text.isEmpty || _selectedDate == null
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'This field is required!',
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
                                    'Gender',
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
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        hintText: '--Select Gender--',
                                        contentPadding: EdgeInsets.all(15.0),
                                        border: InputBorder.none,
                                      ),
                                      items: ['Male', 'Female']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedGender = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isButtonPressed
                              ? (selectedGender == null || selectedGender!.isEmpty
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'This field is required!',
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
                                    'Contact No.',
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
                                      controller: contactNumberController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'Contact No.',
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
                              ? (contactNumberController == null || contactNumberController!.text.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(contactNumberController.text)
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'Invalid Contact Number!',
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
                                    'Barangay',
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
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        hintText: '--Select Barangay--',
                                        contentPadding: EdgeInsets.all(15.0),
                                        border: InputBorder.none,
                                      ),
                                      items: ['Barangay 1', 'Barangay 2', 'Barangay 3']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedBarangay = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isButtonPressed
                              ? (selectedBarangay == null || selectedBarangay!.isEmpty
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'This field is required!',
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
                                      controller: emailController,
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
                          isButtonPressed
                              ? (emailController == null || emailController!.text.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text)
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
                                      controller: passwordController,
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
                          isButtonPressed
                              ? (passwordController == null || passwordController!.text.isEmpty || !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(passwordController.text)
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'Password must include atleast one uppercase and lowercase letter, one digit, and one special character.',
                              style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                            ),
                          )
                              : Container())
                              : Container(),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 50),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                         registerUser();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 5,
                                        primary: Color(0xff0292EB),
                                        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                      ),
                                      child: Text(
                                        'Register',
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