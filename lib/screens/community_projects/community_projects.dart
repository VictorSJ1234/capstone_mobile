import 'dart:convert';

import 'package:capstone_mobile/custom_app_bar.dart';
import 'package:capstone_mobile/config.dart';
import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/diseases_page2.dart';
import 'package:capstone_mobile/screens/user_profile/user_profile.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../config.dart';
import 'package:capstone_mobile/sidenav.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import 'community_projects_page2.dart';
import 'package:http/http.dart' as http;

class CommunityProjects extends StatefulWidget {
  final token; final int notificationCount;
  CommunityProjects({@required this.token,Key? key, required this.notificationCount}) : super(key: key);
  @override
  _CommunityProjectsState createState() => _CommunityProjectsState();
}

class _CommunityProjectsState extends State<CommunityProjects> {
void updateUnreadCardCount(int count) {
    setState(() {
      unreadCardCount = count;
    });

  }

  late String userId;
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

  List? items;
  List<ImageProvider?> projectImage = [];
  String? projectImageBase64;
  final String defaultImage = 'assets/community_projects_images/community_project.png';

  int _currentPageIndex = 0;

  Future<void> fetchAllProjects() async {
    try {
      var response = await http.post(
        Uri.parse(getCommunityProjects),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          items = jsonResponse['communityProjectsData'];
          // Sort the items list by 'postedDate' in descending order
          items?.sort((a, b) => b['project_date'].compareTo(a['project_date']));
          projectImage = items!.map((item) {
            String imageBase64 = item['uploaded_file'].toString();
            // Check if uploaded_file is empty or null
            if (imageBase64.isEmpty) {
              // Use the default image if uploaded_file is empty
              return AssetImage(defaultImage);
            } else {
              return MemoryImage(base64Decode(imageBase64));
            }
          }).cast<ImageProvider<Object>?>().toList();
        });
      } else {
        // Error message
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print(error);
    }
  }


  late PageController _topPageController;
  late PageController _bottomPageController;

  @override
  void initState() {
    super.initState();
    fetchAllProjects();
    _topPageController = PageController(initialPage: items != null ? items!.length * 1000 : 1000, viewportFraction: 0.65);

    _bottomPageController = PageController();
    Map<String,dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
    userId = jwtDecodedToken['_id'];
    fetchUnreadNotifications(userId);
fetchUnreadNotificationsList();
fetchReadNotifications();
    fetchUnreadNotifications(userId);
  }


  @override
  void dispose() {
    _topPageController.dispose();
    _bottomPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return Scaffold(

        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Community Projects'),

        //sidenav
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background/background6.png',
                fit: BoxFit.cover,
              ),
            ),

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
    else if (items!.isEmpty) {
      // No community projects available
      return Scaffold(
        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Community Projects'),
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/background/background6.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
            child: Text(
              "No community projects available",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                          builder: (context) => UserProfile(token: widget.token, notificationCount: widget.notificationCount),
                          ),
                         );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]
        ),
      );
    }
    else {
      return Scaffold(
        appBar: CustomAppBar(token: widget.token, notificationCount: unreadCardCount, title: 'Community Projects'),

        //sidenav
        drawer: SideNavigation(token: widget.token, notificationCount: widget.notificationCount),

        //content
        body: Stack(
          children: [
            // Background ImageR
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
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 8.0, 20.0, 0.0),
                                      child: Container(
                                        height: 60,
                                        child: Center(
                                          child: Text(
                                            'Community Projects',
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
                    ),

                    // Scrollable Cards - Top
                    // Scrollable Cards - Top
                    SizedBox(
                      child: IntrinsicHeight(
                        child: Container(
                          height: 225.0,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 10000,
                            controller: _topPageController,
                            onPageChanged: (int index) {
                              _bottomPageController.jumpToPage(index);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final int cardIndex = index % items!.length;

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: SizedBox(
                                  width: 250.0,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 5,
                                        left: 20,
                                        right: 20,
                                        bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .stretch,
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
                                              height: 190,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: projectImage[cardIndex]!,
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
                          dotsCount: items?.length ?? 0,
                          // Number of cards==number of caption
                          position: _currentPageIndex,
                          decorator: DotsDecorator(
                            activeColor: Colors.blueAccent,
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
                              setState(() {
                                _currentPageIndex = index % items!.length;
                              });
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final int cardIndex = index % items!.length ?? 0;
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: SizedBox(
                                  width: 250.0,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 5,
                                        left: 10,
                                        right: 10,
                                        bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .stretch,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              15.0, 0, 15.0, 0),
                                          child: Text(
                                            '${items![cardIndex]['project_title']}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 17.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff338B93),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: Text(
                                            '${items![cardIndex]['project_date']}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 14,
                                                color: Color(0xff338B93),
                                                fontStyle: FontStyle.normal
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 65.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommunityProjects2(
                                                        token: widget.token,
                                                        PassProjectId:  items![cardIndex]['_id'],
                                                        notificationCount: widget.notificationCount,
                                                      ),
                                                ), 
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 8,
                                              primary: Color(0xff6969DF),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20.0),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius
                                                    .circular(30.0),
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
}