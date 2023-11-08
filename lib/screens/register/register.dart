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

import 'package:capstone_mobile/sidenav.dart';
import 'register_page_two.dart';


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
  //additions
  var streetController = new TextEditingController();
  var houseNumberController = new TextEditingController();
  var floorController = new TextEditingController(); //optional
  var buildingNameController = new TextEditingController();
  var barangayController = new TextEditingController();


  //user registration function
  void NextPage() async{

    /**
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
        **/

    // Check if any of the required fields are empty
    if (streetController.text.isEmpty || nameController.text.isEmpty ||
        selectedGender == null || contactNumberController.text.isEmpty ||
        birthdayController.text.isEmpty || contactNumberController.text.isEmpty) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
      });
    } else {
      //for testing only
      print(nameController.text);
      print(birthdayController.text);
      print(selectedGender);
      print(contactNumberController.text);
      print(streetController.text);
      print(houseNumberController.text);
      print(floorController.text);
      print(buildingNameController.text);

      // Data to be passed to RegisterPage2
      String name = nameController.text;
      String birthday = birthdayController.text;
      String gender = selectedGender.toString();
      String contactNumber = contactNumberController.text;
      String street = streetController.text;
      String houseNumber = houseNumberController.text;
      String floor = floorController.text;
      String buildingName = buildingNameController.text;

      // Navigate to RegisterPage2 and pass data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage2(
            name: name,
            birthday: birthday,
            selectedGender: gender,
            contactNumber: contactNumber,
            street: street,
            houseNumber: houseNumber,
            floor: floor,
            buildingName: buildingName,
            clearPage1Fields: clearPage1Fields,
          ),
        ),
      );
    }
  }

  void clearPage1Fields() {
    nameController.text = "";
    birthdayController.text = "";
    selectedGender = null;
    contactNumberController.text = "";
    streetController.text = "";
    houseNumberController.text = "";
    floorController.text = "";
    buildingNameController.text = "";
    barangayController.text = "";
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
              'assets/background/background3_updated.png',
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
                            padding: EdgeInsets.fromLTRB(15, 25.0, 0.0, 0.0),
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
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Login(),
                                              ),
                                                  (route) => false,
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
                                  padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
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
                                        prefixIcon: Icon(Icons.person),
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
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                        child: SizedBox(
                                          child: Text(
                                            'Date of Birth',
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Container(
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
                                                    : 'MM/DD/YYYY',
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.all(15.0),
                                                prefixIcon: Icon(Icons.calendar_today),
                                              ),
                                              maxLines: null,
                                            ),
                                          ),
                                        ),
                                      ),
                                      isButtonPressed
                                          ? ((birthdayController == null || birthdayController.text.isEmpty || _selectedDate == null)
                                          ? Container(
                                        padding: EdgeInsets.only(left: 8.0),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          // Display an error message if either field is empty
                                          'This field is required!',
                                          style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                                        ),
                                      )
                                          : Container())
                                          : Container(),

                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 0.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [


                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                                        child: SizedBox(
                                          child: Text(
                                            'Gender',
                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376D), fontFamily: 'Outfit'),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: Border.all(color: Colors.black),
                                        ),
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            hintText: '--Gender--',
                                            contentPadding: EdgeInsets.all(15.0),
                                            border: InputBorder.none,
                                            prefixIcon: Icon(selectedGender == 'Male'
                                                ? Icons.male_rounded
                                                : selectedGender == 'Female'
                                                ? Icons.female_rounded
                                                : Icons.transgender_sharp,
                                            ),
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
                                      isButtonPressed
                                          ? ((selectedGender == null || selectedGender!.isEmpty)
                                          ? Container(
                                        padding: EdgeInsets.only(left: 8.0),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          // Display an error message if either field is empty
                                          'This field is required!',
                                          style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                                        ),
                                      )
                                          : Container())
                                          : Container(),
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
                                        prefixIcon: Icon(Icons.phone),
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
                              ? (contactNumberController == null || contactNumberController.text.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(contactNumberController.text)
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
                                    'Street Name',
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
                                      controller: streetController,
                                      decoration: InputDecoration(
                                        hintText: 'Street Name',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15.0),
                                        prefixIcon: Icon(Icons.location_on_rounded),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isButtonPressed
                              ? (streetController == null || streetController!.text.isEmpty
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
                                    'House / Unit / Apartment No. (Opt)',
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
                                      controller: houseNumberController,
                                      decoration: InputDecoration(
                                        hintText: 'House / Unit / Apartment No.',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15.0),
                                        prefixIcon: Icon(Icons.home),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /**
                          isButtonPressed
                              ? (houseNumberController == null || houseNumberController!.text.isEmpty
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
                              **/

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                                child: SizedBox(
                                  child: Text(
                                    'Floor (Opt)',
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
                                      controller: floorController,
                                      decoration: InputDecoration(
                                        hintText: 'Floor',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15.0),
                                        prefixIcon: Icon(Icons.home),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /**
                          isButtonPressed
                              ? (floorController == null || floorController!.text.isEmpty
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
                              **/

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                                child: SizedBox(
                                  child: Text(
                                    'Building Name (Opt)',
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
                                      controller: buildingNameController,
                                      decoration: InputDecoration(
                                        hintText: 'Building Name',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(15.0),
                                        prefixIcon: Icon(Icons.apartment_sharp),
                                      ),
                                      maxLines: null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          /**
                          isButtonPressed
                              ? (buildingNameController == null || buildingNameController!.text.isEmpty
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
                              **/

                          Row(
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
                                        if (formKey.currentState!.validate()) {
                                          NextPage();
                                        }
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
                                        'Next',
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