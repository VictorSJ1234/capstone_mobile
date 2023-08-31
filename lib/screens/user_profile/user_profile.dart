import 'dart:convert';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../about_app/about_app.dart';
import '../notification/notification.dart';
import 'package:http/http.dart' as http;


class UserProfile extends StatefulWidget  {
  final token;
  UserProfile({@required this.token,Key? key}) : super(key: key);
  @override
  _DatePickerFormState createState() => _DatePickerFormState();
}

class _DatePickerFormState extends State<UserProfile> {

  late String _id;
  String _name = '';
  String _birthday = '';
  String _gender = '';
  String _contactNumber = '';
  String _barangay = '';
  String _email = '';
  String _profilePicture = '';
  List? items;

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
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
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
            _birthday = items![0]['birthday'].toString();
            _gender = items![0]['gender'].toString();
            _contactNumber = items![0]['contact_number'].toString();
            _barangay = items![0]['barangay'].toString();
            _email = items![0]['email'].toString();
            _profilePicture = items![0]['profilePicture'].toString();
          }
        });
      }
    }  catch (error) {
      print(error);
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_name.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
        ), // Display a loading indicator while fetching data
      );
    } else {
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
            'User Profile',
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
                image: AssetImage(
                    'assets/sidenav_images/sidenav_background.png'),
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
                    backgroundImage: AssetImage(
                        'assets/sidenav_images/lebron1.png'),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                Column(
                  children: [
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
                                    .token), // go to the next screen
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
                                          SystemNavigator.pop();
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30.0),
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
                padding: const EdgeInsets.only(
                    bottom: 100, top: 15, left: 15, right: 20),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            // this must open the phone's gallery
                          },
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueGrey,
                                width: 5,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/sidenav_images/defaultProfile.jpg'),
                                  radius: 85,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[800],
                                    ),
                                    child: Icon(
                                      Icons.photo_camera,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Name',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff28376D),
                                    fontFamily: 'Outfit'),
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
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 8.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: TextFormField(
                                  initialValue: _name,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Date of Birth',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff28376D),
                                    fontFamily: 'Outfit'),
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
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 8.0, 0.0),
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
                                      initialValue: _birthday,
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Gender',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff28376D),
                                    fontFamily: 'Outfit'),
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
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 8.0, 0.0),
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
                                  value: _gender,
                                  items: ['Male', 'Female']
                                      .map<DropdownMenuItem<String>>((
                                      String value) {
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
                            padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Contact No.',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff28376D),
                                    fontFamily: 'Outfit'),
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
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 8.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: TextFormField(
                                  initialValue: _contactNumber,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                    // Apply input formatter to allow only digits
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

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Barangay',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff28376D),
                                    fontFamily: 'Outfit'),
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
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 8.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Select Barangay',
                                    contentPadding: EdgeInsets.all(15.0),
                                    border: InputBorder.none,
                                  ),
                                  value: _barangay,
                                  items: [
                                    'Barangay 1',
                                    'Barangay 2',
                                    'Barangay 3'
                                  ]
                                      .map<DropdownMenuItem<String>>((
                                      String value) {
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
                            padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Email',
                                style: TextStyle(fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff28376D),
                                    fontFamily: 'Outfit'),
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
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 8.0, 8.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: TextFormField(
                                  initialValue: _email,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 30, bottom: 5),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    primary: Color(0xff1BCBF9),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Edit Information',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 20, bottom: 30),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    elevation: 5,
                                    primary: Colors.redAccent,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: Text(
                                    '          Back         ',
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
                            builder: (context) =>
                                ReportList(token: widget.token),
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
}