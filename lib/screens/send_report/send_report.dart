import 'dart:convert';
import 'dart:io';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/community_projects/community_projects.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/mosquitopedia_menu.dart';
import 'package:capstone_mobile/screens/reports_list/reports_list.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import '../user_profile/user_profile.dart';


class SendReport extends StatefulWidget {
  final token; final int notificationCount;
  SendReport({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _SendReportState createState() => _SendReportState();
}

class _SendReportState extends State<SendReport> with SingleTickerProviderStateMixin {
  late AnimationController loadingController;
  late String userId;
  List? readItems;
  List? unreadItems;

  void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }
 
Future<void> fetchUnreadNotificationsList() async {
    try {
      var response = await http.post(
        Uri.parse(getNotificationStatus),
        headers: {
        "Content-Type": "application/json",
        "x-api-key": 'pasigdtf',
      },
        body: jsonEncode({"userId": userId, "notificationStatus": "Unread".toString()}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          unreadItems = jsonResponse['notifications'];
          unreadItems?.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

          // Fetch and set the read notifications
          fetchReadNotifications();
          fetchUnreadNotifications(userId);
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
        headers: {
        "Content-Type": "application/json",
        "x-api-key": 'pasigdtf',
      },
        body: jsonEncode({"userId": userId, "notificationStatus": "Read".toString()}),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          readItems = jsonResponse['notifications'];
          readItems?.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

          // Fetch and set the read notifications
          fetchUnreadNotificationsList();
          fetchUnreadNotifications(userId);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    } finally {
    }
  }


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
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    fetchUnreadNotifications(userId);
    fetchUnreadNotificationsList();
    fetchReadNotifications();
    fetchUnreadNotifications(userId);
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

  final formKey = GlobalKey<FormState>();
  bool isButtonPressed = false; //initial button status

  //user input data containers
  String? selectedBarangay;
  String? selectedType;
  var subjectController = new TextEditingController();
  var descriptionController = new TextEditingController();
  var customTypeController = TextEditingController();

  //send report function
  void sendReport() async{
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

    if (selectedType == 'Others') {
      selectedType = customTypeController.text;
    }

    // Check if any of the required fields are empty
    if (selectedBarangay == null || selectedType == null || subjectController.text.isEmpty || descriptionController.text.isEmpty) {
      setState(() {
        // Set the isButtonPressed to true to display error messages
        isButtonPressed = true;
        _isLoading = false;
      });
      // Show a snackbar or any other feedback to inform the user about the missing fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }
    else {

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

      //for testing only
      print(selectedBarangay);
      print(subjectController.text);
      print(fileDataList);
      print(descriptionController.text);

      var regBody = {
        "userId":userId,
        "barangay":selectedBarangay.toString(),
        "report_type":selectedType.toString(),
        "report_subject":subjectController.text.toString(),
        "uploaded_file": fileDataList,
        "report_description":descriptionController.text.toString(),
        "report_status":'New Report'.toString(),

      };

      var response = await http.post(Uri.parse(createUserReport),
          headers: {"Content-Type":"application/json",
            "x-api-key": 'pasigdtf', },
          body: jsonEncode(regBody)
      );

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      print(response);

      //for testing only
      print(selectedBarangay);
      print(subjectController.text);
      print(descriptionController.text);


      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        _clearFields();//clear all fields
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
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Pasig Dengue Task Force',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Hi, we have received your report and we are currently taking action to solve your concern. Once complete, we will update the status of your concern. For other concern, you may submit another report. Thank you!',
                        style: TextStyle(fontSize: 16, color: Color(0xFF338B93)),
                        textAlign: TextAlign.justify,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainMenu(token: widget.token, notificationCount: widget.notificationCount),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          'Go back\n to main menu',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReportList(token: widget.token, notificationCount: widget.notificationCount),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Go to \n your report list',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
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

  //clear all fields after submitting
  //clear all fields after submitting
  void _clearFields(){
    subjectController.text="";
    selectedBarangay=null;
    selectedType=null;
    descriptionController.text="";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Send a Report'),

      //sidenav
      drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

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
              padding: const EdgeInsets.only(bottom: 100, top: 15, left: 10, right: 10),
              child: Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 0.0),
                                      child: Container(
                                        height: 80,
                                        child: Center(
                                          child: Text(
                                            'Community Reporting:\nA helping aid for Pasig Dengue\nTask Force',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 5.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Barangay *',
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
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Select Barangay',
                                    contentPadding: EdgeInsets.all(15.0),
                                    prefixIcon: Icon(Icons.apartment_sharp),
                                    border: OutlineInputBorder(),
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
                          ? (selectedBarangay == null || selectedBarangay!.isEmpty || !RegExp(r'^[a-z A-Z]+$').hasMatch(selectedBarangay!)
                          ? Container(
                        padding: EdgeInsets.only(left: 8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'This field is required!',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                        ),
                      )
                          : Container())
                          : Container(), // Empty container if there is no error or the button was not pressed

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Report Type *',
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
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Select Report Type',
                                    contentPadding: EdgeInsets.all(15.0),
                                    prefixIcon: Icon(Icons.apartment_sharp),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: ['Suspected Dengue Case', 'Diagnosed Dengue Fever', 'Clean-up Drive', 'Community Health Teaching'
                                    , 'Mosquito OL Trap', 'Larvical Application',  'Others']
                                      .map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedType = newValue;
                                    });

                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (selectedType == 'Others')
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
                                    controller: customTypeController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter Custom Type',
                                      contentPadding: EdgeInsets.all(15.0),
                                      prefixIcon: Icon(Icons.description),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      isButtonPressed
                          ? (selectedType == null || selectedType!.isEmpty || !RegExp(r'^[a-z A-Z]+$').hasMatch(selectedType!)
                          ? Container(
                        padding: EdgeInsets.only(left: 8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'This field is required!',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                        ),
                      )
                          : Container())
                          : Container(), // Empty container if there is no error or the button was not pressed


                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Subject of Report *',
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
                                  controller: subjectController,
                                  decoration: InputDecoration(
                                    hintText: 'Subject of Report',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.subject),
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
                          ? (subjectController == null || subjectController!.text.isEmpty
                          ? Container(
                        padding: EdgeInsets.only(left: 8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
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
                            padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Attachment',
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
                                        'Upload Picture/Video',
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
                                    style: TextStyle(color: Colors.white, fontSize: 15),
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




                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 20.0, 0.0, 0.0),
                            child: SizedBox(
                              child: Text(
                                'Description of Report *',
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
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    hintText: 'Description of Report',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                                  ),
                                  maxLines: 5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      isButtonPressed
                          ? (descriptionController == null || descriptionController!.text.isEmpty
                          ? Container(
                        padding: EdgeInsets.only(left: 8.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'This field is required!',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                        ),
                      )
                          : Container())
                          : Container(),

                      SizedBox(height: 5,),

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
                                  padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 50),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        sendReport();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 5,
                                      primary: Color(0xff28376d),
                                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(
                                      'Send Report',
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
              margin: EdgeInsets.only(bottom: 15.0, right: 15, left: 15), //margin of the botnav
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
                       builder: (context) => ReportList(token: widget.token, notificationCount: widget.notificationCount),
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
                          builder: (context) => UserProfile(token: widget.token, notificationCount: widget.notificationCount),
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
}