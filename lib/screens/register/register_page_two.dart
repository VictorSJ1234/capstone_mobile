import 'dart:convert';
import 'dart:io';

import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/login/login.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';
import 'package:open_file/open_file.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:path_provider/path_provider.dart';


class RegisterPage2 extends StatefulWidget {
  final String name;
  final String birthday;
  final String selectedGender;
  final String contactNumber;
  final String street;
  final String houseNumber;
  final String floor;
  final String buildingName;
  final Function clearPage1Fields;

  RegisterPage2({
    Key? key,
    required this.name,
    required this.birthday,
    required this.selectedGender,
    required this.contactNumber,
    required this.street,
    required this.houseNumber,
    required this.floor,
    required this.buildingName,
    required this.clearPage1Fields,
  }) : super(key: key);

  @override
  _RegisterPage2State createState() => _RegisterPage2State();
}


class _RegisterPage2State extends State<RegisterPage2> with SingleTickerProviderStateMixin {

  Future<void> openPrivacyPolicyPDF() async {
    final String pdfAssetPath = 'assets/TERMS AND CONDITIONS_Mosquinator 2.pdf';

    try {
      final ByteData data = await rootBundle.load(pdfAssetPath);
      final List<int> bytes = data.buffer.asUint8List();
      final tempFile = File('${(await getTemporaryDirectory()).path}/TERMS AND CONDITIONS.pdf');
      await tempFile.writeAsBytes(bytes, flush: true);
      await OpenFile.open(tempFile.path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }


  late AnimationController loadingController;
  bool _isPasswordVisible = false;
  List<File> _selectedFiles = [];
  List<PlatformFile> _selectedPlatformFiles = [];
  bool _isLoading = false;

  selectFile() async {
    final files = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf'],
    );

    if (files != null && files.files.isNotEmpty) {
      // initialize the maximum number of files
      int remainingFiles = 2 - _selectedFiles.length;

      setState(() {
        // Add new selected files up to the remaining limit.
        for (var i = 0; i < files.files.length && i < remainingFiles; i++) {
          _selectedFiles.add(File(files.files[i].path!));
          _selectedPlatformFiles.add(files.files[i]);
        }
      });

      // if the the number of files is more thaan the remainingFiles
      if (files.files.length > remainingFiles) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You can only upload 2 files")));
      }
    }

    loadingController.forward();
  }

  //function to remove the selected file
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _selectedPlatformFiles.removeAt(index);
    });
  }

  int getTotalFileSize() {
    int totalSize = 0;
    for (var file in _selectedFiles) {
      totalSize += file.lengthSync();
    }
    return totalSize;
  }


  //check if the file is image or not
  bool _isImageFile(String? extension) {
    List<String> imageExtensions = ['jpg', 'jpeg', 'png'];
    return extension != null && imageExtensions.contains(extension.toLowerCase());
  }

  @override
  void initState() {
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() { setState(() {}); });
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  bool isButtonPressed = false; //initial button status

  //user input data containers
  String? selectedBarangay;
  String? selectedDistrict;
  var emailController = new TextEditingController();
  var passwordController = new TextEditingController();
  var repeatPasswordController = new TextEditingController();
  //additions
  var cityController = new TextEditingController();
  bool passwordsMatch = true;
  bool policyBox = false; //default tickbox value


  //user registration function
  void registerUser() async{
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

    // Check if any of the required fields are empty
    if (selectedBarangay == null || cityController.text.isEmpty ||_selectedFiles.isEmpty || selectedDistrict == null || _selectedFiles == null ||
        emailController.text==null || passwordController.text.isEmpty || !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(passwordController.text)||
        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text)) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
        _isLoading = false;
      });
      /*
      // Show a snackbar or any other feedback to inform the user about the missing fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );

       */
      return;
    }

    // Check if any of the required fields are empty
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
      //for testing only
      print(widget.buildingName);
      print(widget.birthday);
      print(widget.selectedGender);
      print(widget.street);
      print(widget.houseNumber);
      print(widget.floor);
      print(widget.buildingName);
      print(selectedBarangay);
      print(selectedDistrict);
      print(cityController.text);
      print(emailController.text);
      print(passwordController.text);

      // Convert selected files to base64 strings
      List<String> fileDataList = [];
      for (var file in _selectedFiles) {
        List<int> bytes = await file.readAsBytes();
        String base64FileData = base64Encode(bytes);
        fileDataList.add(base64FileData);
      }

      // Check if total file size exceeds 15 MB
      int totalFileSize = getTotalFileSize();
      int maxSizeInBytes = 15 * 1024 * 1024; // 15 MB in bytes
      if (totalFileSize > maxSizeInBytes) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Total file size should not exceed 15 MB."),
        ));

        //this is important!! // this will exit the function and not going directly at the data insertiion
        return;
      }

      // Prepare the registration request body that will be passed to the api and db
      var regBody = {
        "name":widget.name,
        "birthday":widget.birthday.toString(),
        "gender":widget.selectedGender.toString(),
        "contact_number":widget.contactNumber.toString(),
        "street_name":widget.street.toString(),
        "house_number":widget.houseNumber.toString(),
        "floor":widget.floor.toString(),
        "building_name":widget.buildingName.toString(),
        "barangay":selectedBarangay.toString(),
        "district":selectedDistrict.toString(),
        "city":cityController.text.toString(),
        "uploaded_file": fileDataList,
        "email":emailController.text.toString(),
        "password":passwordController.text.toString(),
        "profilePicture": "/9j/4AAQSkZJRgABAQACWAJYAAD/2wCEAAgGBgcGB"
            "QgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLD"
            "AxNDQ0Hyc5PTgyPC4zNDIBCQkJDAsMGA0NGDIhHCEyMjIyMjIyMjIyMjIyM"
            "jIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMv/CABEIAMgAyAM"
            "BIgACEQEDEQH/xAAvAAEAAgMBAQAAAAAAAAAAAAAABgcCBAUBAwEBAQEAAAAAAAA"
            "AAAAAAAAAAAEC/9oADAMBAAIQAxAAAAC3BvIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
            "AAAAAAAAAA8PfhD4kWfvVBkXIhE2PQAAAAAAAAIRLalMRcgJfEMpbkau0oAAAAAAAEbr2f"
            "wAC5ACWwpJGJOoAAAAAAAHErS46kNcXIA2ZbC7eGagAAAAAAAOD3hTvztuPJBUw2iE2J09tQ"
            "AAAAAAAADRiBPNKrvgWl96mJcvtQSJZ60d4AAAAAAARbCCmeAyFAAZzuApbmROWKAAAAA5XVr"
            "Q4vggWAAAAe2hV3blssKAAABpVNYFfoFgAAAAAS2zuxmTKAAABDYWIFgAAAAAE0mRNAAf/xAA9"
            "EAACAQICBAoIBAYDAAAAAAABAgMEEQUGACExURIiMEBBUmFxobETICMyM4GR0RAUFnIVNWJjssF"
            "CcHP/2gAIAQEAAT8A/wCoamspaNeFU1EUI/uOBp+pcG4Vv4jD428tKaspaxeFTVEUw/tuDzVmV"
            "FLMQFAuSTYAaY3nGR2anwtuAg1Gotrb9u4dukkjyyGSR2dztZjcn5/hHI8UgkjdkcbGU2I+emCZ"
            "ykRlp8UbhodQqLa1/dvHborK6hlIKkXBBuCOZ5xxwvKcLp2si/HYH3j1e4dPb62TsbKSjC6hrx"
            "t8Bj/xPV7j0dvfzLEqwYfhtRVm3skJAPSegfW2ju0kjO7FnYksT0k7fWR2jkV0Yq6kFSOgjZpht"
            "YMQw2nqxb2qAkDoPSPrfmOdpTHgSoD8SZQe4An/AEOQyTKZMCaMn4czAdgIB/3zHPK3weBt04/xP"
            "IZGW2DztvnP+I5jm2nM+XZyBcxFZfodfgTyGUqcwZdgJFjKWk+p1eAHMZokngkhkF0kUqw7CLaV"
            "9HJh9dNSSjjxta+8dB+Y9ago5MQroaSIceVrX3DpPyGkMSQQRwxiyRqFUdgFuZZky+MXhE0HBWsj"
            "FlvqDjqk+R0mhlp5mhmjaORTZlYWI9SGCWomWGGNpJGNlVRcnTLeXxhEJmn4LVkgs1tYQdUHzPN"
            "K/C6LE0C1dOkltjbGHcRr0qMiUjsTT1k0Q6rqHH11HT9BSX/mKW/8T99KfIlKjA1FZNKOqihB9d"
            "Z0oMLosMQrSU6R32ttY95OvmpIVeESAN51DSXGcMgNpcQplO70gPlp+pMGv/MYPH7aRYxhk5AixC"
            "mYno9IB56Ahl4QII3jWOZ4ji9FhUfDq5gpPuoNbN3DTEM7VkxK0Ma06dduM/2GlTW1VY/CqaiWY/1"
            "sT4abNn4bdulNW1VG3CpqiWE/0OR4aYfnashIWujWoTrrxX+x0w7F6LFY+HSTBiPeQ6mXvHMMwZrSi"
            "L0lAVkqBqeTasfYN58BpNNLUTNNNI0kjG7MxuTyEM0tPMs0MjRyKbqymxGmX81pWlKSvKx1B1JJsW"
            "TsO4+B5bNeYjShsOo3tMR7aRT7g3Dt8uUypmI1QXDqx7zAexkY++Nx7fPlMwYsMIwxpVI9O/EhB62/"
            "uGju0js7sWZjckm5J38ojNG6ujFWU3BBsQd+mX8WGL4YsrECdOJMo62/uPJ5pxI4hjMiq14ae8Udtm"
            "rafmfLlsrYkcPxmNWa0NRaJ77BfYfkfPksXrPyGEVVUDZkjPB/cdQ8Tpr6Tc8tr6DY6YRWfn8Jpakm"
            "7PGOF+4aj4jkc7z+jwWKEHXNML9wBP25hkif0mDSxE64pjbuIB+/I5+bi0Cdsh8uYZBbi16dsZ8/V//"
            "EABQRAQAAAAAAAAAAAAAAAAAAAHD/2gAIAQIBAT8AKf/EABoRAAICAwAAAAAAAAAAAAAAAAARAVAQME"
            "D/2gAIAQMBAT8ArGPomoYx186Iz//Z".toString(),
        "accountStatus": "not validated".toString(),
      };

      // Send a POST request to the registration endpoint
      var response = await http.post(Uri.parse(registration),
          headers: {"Content-Type":"application/json"},
          body: jsonEncode(regBody)
      );

      print(response);

      //for testing only
      print(widget.buildingName);
      print(widget.birthday);
      print(widget.selectedGender);
      print(widget.street);
      print(widget.houseNumber);
      print(widget.floor);
      print(widget.buildingName);
      print(selectedBarangay);
      print(selectedDistrict);
      print(cityController);
      print(emailController.text);
      print(passwordController.text);

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
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
      } else if (response.statusCode == 400) {
        setState(() {
          _isLoading = false;
        });
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
      } else {
        setState(() {
          _isLoading = false;
        });
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
                    setState(() {
                      _isLoading = false;
                    });
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
    widget.clearPage1Fields();
    selectedBarangay = null;
    selectedDistrict = null;
    cityController.text="";
    emailController.text="";
    passwordController.text="";
    repeatPasswordController.text="";
    setState(() {
      _selectedFiles.clear(); // Clear the selected files list
      _selectedPlatformFiles.clear(); // Clear the selected platform files list
    });
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
                                        prefixIcon: Icon(Icons.apartment_sharp),
                                        hintText: '--Select Barangay--',
                                        contentPadding: EdgeInsets.all(15.0),
                                        border: InputBorder.none,
                                      ),
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
                                    'District',
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
                                        hintText: '--Select District--',
                                        contentPadding: EdgeInsets.all(15.0),
                                        border: InputBorder.none,
                                        prefixIcon: Icon(Icons.apartment_sharp),
                                      ),
                                      items: ['District 1', 'District 2']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedDistrict = newValue;
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
                                      controller: cityController,
                                      decoration: InputDecoration(
                                        hintText: 'City',
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
                          isButtonPressed
                              ? (cityController == null || cityController!.text.isEmpty
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
                                    'Barangay Certificate of Residency',
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
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      border: Border.all(color: Colors.black),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        selectFile();
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
                                            'Barangay Certificate of Residency',
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


                          _selectedFiles.isNotEmpty
                              ? Column(
                            children: _selectedFiles.asMap().entries.map((entry) {
                              int index = entry.key;
                              File file = entry.value;
                              PlatformFile platformFile = _selectedPlatformFiles[index];
                              bool isImageFile = _isImageFile(platformFile.extension);

                              return Container(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Selected File',
                                        style: TextStyle(color: Color(0xff28376D), fontSize: 15),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0, 2),
                                            blurRadius: 3,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Display either the image or the file icon based on the file type
                                          isImageFile
                                              ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(file, width: 70),
                                          )
                                              : Image.asset('assets/send_report_images/file_icon.png', width: 70),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  platformFile.name,
                                                  style: TextStyle(fontSize: 13, color: Colors.black),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${(platformFile.size / 1024).ceil()} KB',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  height: 5,
                                                  clipBehavior: Clip.hardEdge,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: Colors.blue.shade50,
                                                  ),
                                                  child: LinearProgressIndicator(
                                                    value: loadingController.value,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              _removeFile(index);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                              : Container(),

                          isButtonPressed
                              ? (_selectedFiles.isEmpty || _selectedFiles==null
                              ? Container(
                            padding: EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // Display an error message if the field is empty
                              'File upload is required!',
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
                                        prefixIcon: Icon(Icons.lock),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 10.0, 0.0, 0.0),
                                child: SizedBox(
                                  child: Text(
                                    'Repeat Password',
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end, // Align content at the bottom
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        policyBox = !policyBox;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: policyBox,
                                          onChanged: (value) {
                                            setState(() {
                                              policyBox = value ?? false;
                                            });
                                          },
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "I agree to the ",
                                                style: TextStyle(fontSize: 12.5, color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: "Privacy Policy",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    openPrivacyPolicyPDF();
                                                  },
                                              ),
                                              TextSpan(
                                                text: " and ",
                                                style: TextStyle(fontSize: 12.5, color: Colors.black),
                                              ),
                                              TextSpan(
                                                text: "Terms of Service",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    openPrivacyPolicyPDF();
                                                  },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                              ),
                            ],
                          ),

                          SizedBox(height: 10,),
                          if (_isLoading)
                            Center(
                              child: CircularProgressIndicator(),
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
                                          if (!policyBox) {
                                            // Show a dialog if the checkbox is unchecked
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("Privacy Policy Agreement"),
                                                  content: Text("You must agree to the Privacy Policy and Terms of Service."),
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
                                            registerUser();
                                          }
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
                                        'Save',
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
        ],
      ),
    );
  }
}