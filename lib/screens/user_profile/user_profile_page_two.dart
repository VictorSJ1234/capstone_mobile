import 'dart:convert';
import 'dart:io';

import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:capstone_mobile/screens/user_profile/change_password.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import 'package:http/http.dart' as http;


class UserProfilePage2 extends StatefulWidget  {
  final token; final int notificationCount;
  final String name;
  final String birthday;
  final String selectedGender;
  final String contactNumber;
  final String street;
  final String houseNumber;
  final String floor;
  final String buildingName;
  final String Base64Image;

  UserProfilePage2({
    @required this.token,
    Key? key,
    required this.name,
    required this.birthday,
    required this.selectedGender,
    required this.contactNumber,
    required this.street,
    required this.houseNumber,
    required this.floor,
    required this.buildingName,
    required this.Base64Image, required this.notificationCount
  }) : super(key: key);
  @override
  _UserProfilePage2 createState() => _UserProfilePage2();
}

class _UserProfilePage2 extends State<UserProfilePage2> {

  void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  Future<void> _confirmSave() async{
    setState(() {
      _isLoading = true;
    });

    print(profilePhotoBase64);
    try {
      // Prepare the updated user information
      var updatedData = {
        "name": widget.name.toString(),
        "birthday": widget.birthday.toString(),
        "gender": widget.selectedGender.toString(),
        "contact_number": widget.contactNumber.toString(),
        "street_name": widget.street.toString(),
        "house_number": widget.houseNumber.toString(),
        "floor": widget.floor.toString(),
        "building_name": widget.buildingName.toString(),
        "barangay": selectedBarangay.toString(),
        "district": selectedDistrict.toString(),
        "city":_cityController.text.toString(),
        "email": _emailController.text,
        "profilePicture": widget.Base64Image.toString(),
      };

      // Make an HTTP PUT request to update the user information
      var response = await http.put(
        Uri.parse(editUserData + '/$_id'),
        // api end point
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
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
                        'Your account has been edited successfully!',
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
      } else {
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
  bool _isLoading = false;

  final formKey = GlobalKey<FormState>();
  bool isButtonPressed = false; //initial button status
  List? readItems;
  List? unreadItems;

  String? selectedBarangay;
  String? selectedDistrict;
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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

  Future<void> updateUserInformation() async {
    // Check if any of the required fields are empty
    if (selectedBarangay == null || selectedDistrict == null ||
        _cityController.text.isEmpty || _emailController.text.isEmpty ||

        _emailController.text==null ||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
        _isLoading = false;
      });
    }
    /** //for testing only
        var updatedData = {
        "name": _nameController.text,
        "birthday": _birthdayController.text,
        "gender": selectedGender.toString(),
        "contact_number": _contactNumberController.text,
        "barangay": selectedBarangay.toString(),
        "email": _emailController.text,
        "profilePicture": profilePhotoBase64,
        };
        print(updatedData);
     */
    else {
      setState(() {
        _isLoading = true;
      });
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
                      'Are you sure you want to edit your account information?',
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
                        _confirmSave();
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
            selectedBarangay = items![0]['barangay'].toString();
            selectedDistrict = items![0]['district'].toString();
            _emailController.text = items![0]['email'].toString();
            _cityController.text = items![0]['city'].toString();
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
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchUnreadNotificationsList();
    fetchUserInformation(_id);
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

                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
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
                                        prefixIcon: Icon(Icons.apartment_sharp),
                                        hintText: 'Select Barangay',
                                        contentPadding: EdgeInsets.all(15.0),
                                        border: InputBorder.none,
                                      ),
                                      value: selectedBarangay,
                                      items: [
                                        'Bagong Ilog',
                                        'Bagong Katipunan',
                                        'Bambang',
                                        'Buting',
                                        'Caniogan',
                                        'Dela Paz',
                                        'Kalawaan',
                                        'Kapasigan',
                                        'Kapitolyo',
                                        'Malinao',
                                        'Manggahan (incl. Napico)',
                                        'Maybunga',
                                        'Oranbo',
                                        'Palatiw',
                                        'Pinagbuhatan',
                                        'Pineda',
                                        'Rosario',
                                        'Sagad',
                                        'San Antonio',
                                        'San Joaquin',
                                        'San Jose',
                                        'San Miguel',
                                        'San Nicolas',
                                        'Santa Cruz',
                                        'Santa Lucia',
                                        'Santa Rosa',
                                        'Santolan',
                                        'Santo Tomas',
                                        'Sumilang',
                                        'Ugong',
                                      ]
                                          .map<DropdownMenuItem<String>>((
                                          String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedBarangay = newValue; // Update the selected barangay
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
                                    'District',
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
                                        prefixIcon: Icon(Icons.apartment_sharp),
                                        hintText: 'Select District',
                                        contentPadding: EdgeInsets.all(15.0),
                                        border: InputBorder.none,
                                      ),
                                      value: selectedDistrict,
                                      items: ['District 1', 'District 2']
                                          .map<DropdownMenuItem<String>>((
                                          String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedDistrict = newValue; // Update the selected barangay
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          isButtonPressed
                              ? (selectedDistrict == null || selectedDistrict!.isEmpty
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
                                    'City',
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
                                      controller: _cityController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.apartment_sharp),
                                        hintText: 'City',
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
                              ? (_cityController == null || _cityController.text.isEmpty
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

                          Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 2.0,
                                    color: Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0), // Horizontal spacing
                                  child: Text(
                                    'Credentials',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff28376D),
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 2.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
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
                              ? (_emailController == null || _emailController.text.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)
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

                          SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                                child: SizedBox(
                                  child: Text(
                                    'Change Password',
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
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChangePassword(token: widget.token, notificationCount: widget.notificationCount,),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      primary: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14.0),
                                      child: Text(
                                        'Click here to change password',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

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
                                        onPressed: updateUserInformation,
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