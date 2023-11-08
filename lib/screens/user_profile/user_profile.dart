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

import 'user_profile_page_two.dart';


class UserProfile extends StatefulWidget  {
  final token; final int notificationCount;
  UserProfile({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _UserProfile createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
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

  final formKey = GlobalKey<FormState>();
  bool isButtonPressed = false; //initial button status

  //userInput and current data container
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  String? selectedGender;
  final TextEditingController _contactNumberController =  TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _floor = TextEditingController();
  final TextEditingController _buildingName = TextEditingController();

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
        _birthdayController.text = _dateFormat.format(_selectedDate!);
      });
    }
  }

  Future<void> _showImagePickerDialog() async {
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    profilePhotoBase64 = base64Encode(File(pickedFile.path).readAsBytesSync());
                  });
                }
              },
              child: Text("Gallery"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    profilePhotoBase64 = base64Encode(File(pickedFile.path).readAsBytesSync());
                  });
                }
              },
              child: Text("Camera"),
            ),
          ],
        );
      },
    );
  }

  void NextPage() async {
    // Check if any of the required fields are empty
    if (_streetNameController.text.isEmpty || _nameController.text.isEmpty || _contactNumberController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
      });
    }
    else {

      //for testing only
      print(_nameController.text);
      print(_birthdayController.text);
      print(selectedGender);
      print(_contactNumberController.text);
      print(_streetNameController.text);
      print(_houseNumberController.text);
      print(_floor.text);
      print(_buildingName.text);


      // Data to be passed to RegisterPage2
      String name = _nameController.text;
      String birthday = _birthdayController.text;
      String gender = selectedGender.toString();
      String contactNumber = _contactNumberController.text;
      String street = _streetNameController.text;
      String houseNumber = _houseNumberController.text;
      String floor = _floor.text;
      String buildingName = _buildingName.text;
      String Base64Image = profilePhotoBase64.toString();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage2(
            token: widget.token,
            name: name,
            birthday: birthday,
            selectedGender: gender,
            contactNumber: contactNumber,
            street: street,
            houseNumber: houseNumber,
            floor: floor,
            buildingName: buildingName,
              Base64Image: Base64Image,
            notificationCount: widget.notificationCount,

          ),
        ),
      );
    }
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
            _nameController.text = items![0]['name'].toString();
            _birthdayController.text = items![0]['birthday'].toString();
            selectedGender = items![0]['gender'].toString();
            _contactNumberController.text = items![0]['contact_number'].toString();
            _streetNameController.text = items![0]['street_name'].toString();
            _houseNumberController.text = items![0]['house_number'].toString();
            _floor.text = items![0]['floor'].toString();
            _buildingName.text = items![0]['building_name'].toString();
            profilePhotoBase64 = items![0]['profilePicture'].toString();
          }
        });
      }
    }  catch (error) {
      print(error);
    }
  }


  @override
  void initState() {
    super.initState();
    _selectedDate = null;
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchUserInformation(_id);
    fetchUnreadNotificationsList();
    fetchReadNotifications();
    fetchUnreadNotifications(_id);
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return Scaffold(

        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'User Reports'),

        //sidenav
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

        body: Stack(
          children: [
            Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
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
                                ReportList(token: widget.token, notificationCount: widget.notificationCount),
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
                            builder: (context) =>
                                UserProfile(token: widget.token, notificationCount: widget.notificationCount),
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
      );
    }
    else {
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
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            _showImagePickerDialog();
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
                                  backgroundImage: profilePhotoBase64 != null
                                      ? MemoryImage(base64Decode(profilePhotoBase64!))  as ImageProvider
                                      : AssetImage('assets/sidenav_images/defaultProfile.jpg'),
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
                                        controller: _nameController,
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
                                ? (_nameController.text.isEmpty || _nameController!.toString().isEmpty
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
                                                initialValue: _birthdayController.text,
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
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
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
                                              hintText: '--Select Gender--',
                                              contentPadding: EdgeInsets.all(15.0),
                                              border: InputBorder.none,
                                              prefixIcon: Icon(selectedGender == 'Male'
                                                  ? Icons.male_rounded
                                                  : selectedGender == 'Female'
                                                  ? Icons.female_rounded
                                                  : Icons.transgender_sharp,
                                              ),
                                            ),
                                            value: selectedGender,
                                            items: ['Male', 'Female']
                                                .map<DropdownMenuItem<String>>((
                                                String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedGender = newValue; // Update the selected gender
                                              });
                                            },
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
                                        controller: _contactNumberController,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                          // Apply input formatter to allow only digits
                                        ],
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: 'Contact No.',
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(15.0),
                                          prefixIcon: Icon(Icons.phone),
                                        ),
                                        maxLines: null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            isButtonPressed
                                ? (_contactNumberController.text.isEmpty || _contactNumberController!.toString().isEmpty || !RegExp(r'^[0-9]+$').hasMatch(_contactNumberController.text)
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
                                      'Street',
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
                                        controller: _streetNameController,
                                        decoration: InputDecoration(
                                          hintText: 'Street',
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
                                ? (_streetNameController.text.isEmpty || _streetNameController!.toString().isEmpty
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
                                        controller: _houseNumberController,
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                                  child: SizedBox(
                                    child: Text(
                                      'Floor (Opt)',
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
                                        controller: _floor,
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                                  child: SizedBox(
                                    child: Text(
                                      'Building Name (Opt)',
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
                                        controller: _buildingName,
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
                          ],
                        ),
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
                                ReportList(token: widget.token, notificationCount: widget.notificationCount),
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