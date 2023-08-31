import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/diseases_page2.dart';
import 'package:capstone_mobile/screens/mosquitopedia/repellents_page2.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../about_app/about_app.dart';
import '../notification/notification.dart';
import '../reports_list/reports_list.dart';
import '../user_profile/user_profile.dart';

class Repelents extends StatefulWidget {
  final token;
  Repelents({@required this.token,Key? key}) : super(key: key);
  @override
  _RepelentsState createState() => _RepelentsState();
}

class _RepelentsState extends State<Repelents> {

  int _currentPageIndex = 0;

  List<String> captions = [
    'Mosquito Repellent',
    'Mosquito Coil',
    'Mosquito Net',
    'Anti Mosquito Racket',
  ];

  List<String> images = [
    'assets/repellents_images/repellent.jpg',
    'assets/repellents_images/coil.jpg',
    'assets/repellents_images/nets.jpg',
    'assets/repellents_images/racket.jpg',
  ];

  late PageController _topPageController;
  late PageController _bottomPageController;

  @override
  void initState() {
    super.initState();
    _topPageController = PageController(initialPage: captions.length * 1000, viewportFraction: 0.65);
    _bottomPageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Repellents',
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
              image: AssetImage('assets/sidenav_images/sidenav_background.png'),
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
                  backgroundImage: AssetImage('assets/sidenav_images/lebron1.png'),
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.white,),
                    title: Text('Language', style: TextStyle(color: Colors.white),),
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
                    title: Text('About App', style: TextStyle(color: Colors.white),),
                    onTap: () {
                      Navigator.pop(context); // Hide the navigation before going to the nexxt screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutApp(token: widget.token), // go to the next screen
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.white,),
                    title: Text('Developers', style: TextStyle(color: Colors.white),),
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
                      leading: Icon(Icons.exit_to_app_sharp, color: Colors.black,),
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
                                          borderRadius: BorderRadius.circular(30.0),
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
                                          borderRadius: BorderRadius.circular(30.0),
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
                                          'Tools against Aedes DIsease\n Vectors',
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
                                            fontSize: 17.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff338B93),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 65.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => RepellentsPage2(
                                                  token: widget.token,
                                                  PassCaption: captions[cardIndex],
                                                  PassImage: images[cardIndex],
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            elevation: 8,
                                            primary: Color(0xff6969DF),
                                            padding: EdgeInsets.symmetric(vertical: 20.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30.0),
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
                          builder: (context) => ReportList(token: widget.token),
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
                        builder: (context) => UserProfile(token: widget.token),
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