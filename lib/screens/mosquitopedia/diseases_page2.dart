import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:capstone_mobile/sidenav.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';


class DiseasesPage2 extends StatefulWidget {
  final token; final int notificationCount;
  final String PassCaption;
  final String PassScientificName;
  final String PassImage;
  final String PassDetails;

  DiseasesPage2({
    @required this.token,
    required this.PassCaption,
    required this.PassScientificName,
    required this.PassImage,
    required this.PassDetails,
    Key? key, required this.notificationCount,
  }) : super(key: key);

  @override
  _DiseasesPage2 createState() => _DiseasesPage2();
}

class _DiseasesPage2 extends State<DiseasesPage2> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  final Map<String, List<String>> diseaseData = {
    'Dengue': [
      'High fever (40°C/104°F)',
      'Severe headachet',
      'Pain behind the eyes',
      'muscle and joint pains',
      'Nausea',
      'Vomiting',
    ],
    'Malaria': [
      'Exhaustion',
      'Trouble breathing',
      'Fever',
      'Chills',
      'Dark or bloody urine jaundice',
      'Yellowing of the eyes and skin',
    ],
    'Filariasis': [
      "Symptoms can be confused with other illnesses like Zika, leading to misdiagnosis.",
      "In some cases, symptoms are mild, and people may not realize they're infected",
      'Recurrent episodes of acute inflammation, including fever and pain',
      'Skin rashes and itching',
      'Asymptomatic infection (no immediate symptoms)',
      'Lymphedema (swelling), often in the legs',

    ],
    'Chikungunya': [
      'Joint swelling',
      'Muscular discomfort',
      'Headache',
      'Nauseaa',
      'Exhaustion',
      'Rash ',
    ],
    'Zika Virus': [
      'Joint swelling',
      'Muscular discomfort',
      'Headache',
      'Nauseaa',
      'Exhaustion',
      'Rash ',
    ],
  };

  final Map<String, List<String>> preventionData = {
    'Dengue': [
      'clothing that covers the most of your body',
      'If sleeping during the day, use mosquito nets that have been sprayed with insect repellent.',
      'Mosquito repellents (DEET, Picaridin, or IR3535) ',
      'Coils, as well as vaporizers.',
    ],
    'Malaria': [
      'Vector control is a vital component of malaria control and elimination strategies as it is highly effective in preventing infection and reducing disease transmission.',
      'Use mosquito nets when sleeping in places where malaria is present Use mosquito repellents (containing DEET, IR3535, or Icaridin) after dusk Use coils and vaporizers.',
      'Talk to a doctor about taking medicines such as chemoprophylaxis before traveling to areas where malaria is common. ',
      'Lower the risk of getting malaria by avoiding mosquito bites.',
    ],
    'Filariasis': [
      'Elimination of lymphatic filariasis is possible by preventing infection spread with preventive chemotherapy.',
      'Mass drug administration (MDA) entails giving an annual dose of medications to the entire at-risk population.',
      'The MDA regimen recommended is determined by the co-occurrence of lymphatic filariasis and other filarial diseases. ',
      'Take preventive measures when traveling to areas where filariasis is common, such as using insect repellent, wearing protective clothing, and sleeping under bed nets.',
    ],
    'Chikungunya': [
      'The main method to reduce transmission of CHIKV is through control of the mosquito vectors.',
      'Insecticide-treated mosquito nets should be used against day-biting mosquitoes by persons who sleep during the daytime, for example young children, sick patients or older people.',
      'For protection during outbreaks of chikungunya, clothing which minimizes skin exposure to the day-biting vectors is advised.',
      'Repellents can be applied to exposed skin or to clothing in strict accordance with product label instructions.',
    ],
    'Zika Virus': [
      'Wearing clothing (preferably light-colored) that covers as much of the body as possible.',
      'Use physical barriers such as window screens and closed doors and windows',
      'Applying insect repellent to skin or clothing that contains DEET, IR3535, or icaridin according to product label instructions are all examples of personal protection measures.',
      'Preventing mosquito bites during the day and early evening is a critical step in preventing Zika virus infection, particularly in pregnant women, women of reproductive age, and young children.',
    ],
  };

  /**
  static const List<String> symptoms = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget nisi ac velit dictum facilisis vel at arcu.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget nisi ac velit dictum facilisis vel at arcu.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget nisi ac velit dictum facilisis vel at arcu.',
  ];

  static const List<String> preventions = [
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget nisi ac velit dictum facilisis vel at arcu.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget nisi ac velit dictum facilisis vel at arcu.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eget nisi ac velit dictum facilisis vel at arcu.',
  ];
      **/

  late String _id;
List? readItems;
List? unreadItems;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchUnreadNotifications(_id);
  }
  Widget build(BuildContext context) {
    final List<String> symptoms = diseaseData[widget.PassCaption] ?? [];
    final List<String> preventions = preventionData[widget.PassCaption] ?? [];

    return Scaffold(
      appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Diseases'),

      //sidenav
      drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

      //content
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/background6.png',
              fit: BoxFit.cover,
            ),
          ),

          // Top Row
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60, top: 15, left: 10, right: 10),
              child: Container(
                padding: EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 20.0, 8.0),
                                    child: Container(
                                      height: 70,
                                      child: Center(
                                        child: Text(
                                          'Mosquito Borne-Diseases\n Vectors',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 23,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35.0),
                            border: Border.all(
                              color: Colors.white,
                              width: 5.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: Image.asset(
                              widget.PassImage,
                              width: 260,
                            ),
                          ),
                        ),
                      ),
                    ),

                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12, // Shadow color
                                                blurRadius: 2.0, // Spread of the shadow
                                                offset: Offset(0, 5), // Offset of the shadow
                                              ),
                                            ],
                                          ),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            color: Color(0xffF5F5F5),
                                            elevation: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              child: SizedBox(
                                                child: Text(
                                                  widget.PassCaption,
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff28376d), fontFamily: 'Outfit'),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      color: Color(0xffF5F5F5),
                      elevation: 25,
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                                                  child: SizedBox(
                                                    child: Text(
                                                      'Scientific Name of Vector',
                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376d), fontFamily: 'Outfit'),
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 15.0),
                                                  child: Text(
                                                    widget.PassScientificName,
                                                    style: TextStyle(fontSize: 15, color: Color(0xff8B8B8B), fontFamily: 'Outfit'),
                                                    textAlign: TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.fromLTRB(15.0, 1.0, 15.0, 15.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                                                  child: SizedBox(
                                                    child: Text(
                                                      'Details',
                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376d), fontFamily: 'Outfit'),
                                                      textAlign: TextAlign.justify,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 15.0),
                                                  child: Text(
                                                    widget.PassDetails,
                                                    style: TextStyle(fontSize: 15, color: Color(0xff8B8B8B), fontFamily: 'Outfit'),
                                                    textAlign: TextAlign.justify,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 35),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                child: Text(
                                  'Symptoms of '+widget.PassCaption,
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376d), fontFamily: 'Outfit'),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: symptoms.length,
                            itemBuilder: (context, index) {
                              return IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/diseases_page2_images/symptoms.png',
                                                  width: 60,
                                                ),
                                                SizedBox(width: 8), //  spacng between the image and text
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      SizedBox(height: 4), // spacing between the two texts
                                                      Padding(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                          symptoms[index],
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                          ),
                                                          textAlign: TextAlign.justify,
                                                        ),
                                                      ),
                                                    ],
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
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 35, top: 25, bottom: 1),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                child: Text(
                                  'Preventions',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff28376d), fontFamily: 'Outfit'),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: preventions.length,
                            itemBuilder: (context, index) {
                              return IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/diseases_page2_images/preventions.png',
                                                  width: 60,
                                                ),
                                                SizedBox(width: 8), //  spacng between the image and text
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      SizedBox(height: 4), // spacing between the two texts
                                                      Padding(
                                                        padding: EdgeInsets.only(right: 10),
                                                        child: Text(
                                                          preventions[index],
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                          ),
                                                          textAlign: TextAlign.justify,
                                                        ),
                                                      ),
                                                    ],
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
                              );
                            },
                          ),
                          SizedBox(height: 30), //bottom padding
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
