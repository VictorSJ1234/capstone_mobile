import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/diseases_page2.dart';
import 'package:capstone_mobile/sidenav.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:capstone_mobile/sidenav.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';



class Diseases extends StatefulWidget {
  final token; final int notificationCount;
  Diseases({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _DiseasesState createState() => _DiseasesState();
}

class _DiseasesState extends State<Diseases> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  int _currentPageIndex = 0;

  List<String> captions = [
    'Dengue',
    'Malaria',
    'Filariasis',
    'Chikungunya',
    'Zika Virus',
  ];

  List<String> scientificName = [
    'Aedes species \n (Ae. aegypti or Ae. albopictus) mosquito',
    'Anopheles mosquitoes',
    'Culex, Anopheles, Aedes Mosquitos',
    'Aedes (Stegomyia) aegypti,\n Aedes (Stegomyia) albopictus',
    'Aedes (Ae. aegypti) mosquito',
  ];

  List<String> images = [
    'assets/mosquitopedia_images/dengue.jpeg',
    'assets/mosquitopedia_images/malaria.jpg',
    'assets/mosquitopedia_images/filariasis.jpg',
    'assets/mosquitopedia_images/chikungunya.jpg',
    'assets/mosquitopedia_images/zikavirus.jpg',
  ];

  List<String> details = [
    'Dengue is a viral infection caused by the dengue virus (DENV), transmitted to humans through the bite of infected mosquitoes. About half of the world\'s population is now at risk of dengue with an estimated 100–400 million infections occurring each year. ',
    'Malaria is a serious and sometimes fatal disease caused by a parasite that commonly infects a certain type of mosquito which feeds on humans. People who get malaria are typically very sick with high fevers, shaking chills, and flu-like illness.',
    'Lymphatic filariasis, considered globally as a neglected tropical disease (NTD), is a parasitic disease caused by microscopic, thread-like worms. The adult worms only live in the human lymph system. The lymph system maintains the body’s fluid balance and fights infections.',
    'Chikungunya is a viral disease transmitted to humans through the bites of mosquitoes infected with the chikungunya virus.',
    'Zika is spread mostly by the bite of an infected Aedes species mosquito (Ae. aegypti and Ae. albopictus). These mosquitoes bite during the day and night. Zika can be passed from a pregnant woman to her fetus. Infection during pregnancy can cause certain birth defects.',
  ];

  late PageController _topPageController;
  late PageController _bottomPageController;

  late String _id;
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

  @override
  void initState() {
    super.initState();
    _topPageController = PageController(initialPage: captions.length * 1000, viewportFraction: 0.65);
    _bottomPageController = PageController();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    _id = jwtDecodedToken['_id'];
fetchUnreadNotificationsList();
    fetchUnreadNotifications(_id);
  }


  @override
  void dispose() {
    _topPageController.dispose();
    _bottomPageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
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

          // Header
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 50, top: 5),
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                    child: Row(
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
                                        height: 60,
                                        child: Center(
                                          child: Text(
                                            'Mosquito Borne-Diseases\n Vectors',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 22,
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
                  ),

                  // Scrollable Cards - Top
                  SizedBox(
                    child: IntrinsicHeight(
                      child: Container(
                        height: 230.0,
                        child: PageView.builder(

                          scrollDirection: Axis.horizontal,
                          itemCount: 10000,
                          controller: _topPageController,
                          onPageChanged: (int index) {
                            _bottomPageController.jumpToPage(index);
                            setState(() {
                              _currentPageIndex = index % captions.length;
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final int cardIndex = index % captions.length;

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                width: 250.0,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 20, right: 20, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 7.0,
                                          ),
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(28.0),
                                            bottom: Radius.circular(28.0),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20.0),
                                            bottom: Radius.circular(20.0),
                                          ),
                                          child: Container(
                                            height: 200,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    images[cardIndex]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Indicators
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: DotsIndicator(
                        dotsCount: captions.length, // Number of cards==number of caption
                        position: _currentPageIndex,
                        decorator: DotsDecorator(
                          activeColor: Color(0xff28376d),
                          color: Colors.grey,
                          activeSize: const Size(18.0, 9.0),
                          size: const Size.square(9.0),
                          activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          spacing: EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ),
                    ),
                  ),

                  // Scrollable Cards - Bottom
                  SizedBox(
                    child: IntrinsicHeight(
                      child: Container(
                        height: 260,
                        padding: EdgeInsets.only(bottom: 0),
                        child: PageView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: 10000,
                          controller: _bottomPageController,
                          onPageChanged: (int index) {
                            _topPageController.jumpToPage(index);
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final int cardIndex = index % captions.length;
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: SizedBox(
                                width: 250.0,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 0, left: 10, right: 10, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(15.0, 0, 15.0, 0),
                                        child: Text(
                                          captions[cardIndex],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 18.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff28376d),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          scientificName[cardIndex],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 15,
                                              color: Color(0xff28376d),
                                              fontStyle: FontStyle.normal
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 80.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DiseasesPage2(
                                                  token: widget.token,
                                                  PassCaption: captions[cardIndex],
                                                  PassScientificName: scientificName[cardIndex],
                                                  PassImage: images[cardIndex],
                                                  PassDetails: details[cardIndex],
                                                  notificationCount: widget.notificationCount,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 8,
                                            primary: Color(0xff28376d),
                                            padding: EdgeInsets.symmetric(vertical: 20.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0),
                                            ),
                                          ),
                                          child: Text(
                                            'Read Information',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Scrollable Cards

          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 15.0, right: 15, left: 15),
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