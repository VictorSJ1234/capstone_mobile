import 'package:capstone_mobile/screens/main_menu.dart';
import 'package:capstone_mobile/screens/mosquitopedia/repellents.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'diseases.dart';

class MosquitopediaMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff00C3FF),
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
        title: Text('Mosquitopedia', style: TextStyle(fontFamily: 'SquadaOne'),),
      ),

      //sidenav
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background/background3.png'),
              colorFilter: ColorFilter.mode(Colors.blue.withOpacity(0.6), BlendMode.srcATop),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  'Lebron James',
                  style: TextStyle(color: Colors.black),
                ),
                accountEmail: Text(
                  'kingjames@gmail.com',
                  style: TextStyle(color: Colors.black),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage('assets/avatar_images/batman.png'),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background_images/sidenav_back.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: Colors.white,),
                    title: Text('Language'),
                    onTap: () {
                      //Navigator.pop(context);
                      //Navigator.push(
                       // context,
                       // MaterialPageRoute(
                        //  builder: (context) => LanguageSettings(),
                      //  ),
                    //  );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.white,),
                    title: Text('About'),
                    onTap: () {
                     // Navigator.pop(context);
                     // Navigator.push(
                      //  context,
                      //  MaterialPageRoute(
                        //  builder: (context) => About(),
                      //  ),
                   //   );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people, color: Colors.white,),
                    title: Text('Developers'),
                    onTap: () {
                     // Navigator.pop(context);
                     // Navigator.push(
                       // context,
                       // MaterialPageRoute(
                         // builder: (context) => Developers(),
                    //    ),
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
                      leading: Icon(Icons.exit_to_app, color: Colors.white,),
                      title: Text('Exit'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              content: Container(
                                height: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/avatar_images/Logo.png',
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

          // Top Row
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Diseases(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      elevation: MaterialStateProperty.all<double>(10.0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/mosquitopedia_menu_images/mosquito.png',
                            width: 60,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mosquito Borne-Disease Vectors',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Text(
                                    'A substance put on skin, clothing, or other surfaces which discourages mosquitoes from landing or crawling on that surface.',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
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
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Repelents(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      elevation: MaterialStateProperty.all<double>(10.0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/mosquitopedia_menu_images/repellent.png',
                            width: 60,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tools against Aedes Disease Vectors',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 4),
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    'A substance put on skin, clothing, or other surfaces which discourages mosquitoes from landing or crawling on that surface.',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
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
                ],
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
                          builder: (context) => MainMenu(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/list.png'),

                    onPressed: () {
                      //Navigator.push(
                      //context,
                      //MaterialPageRoute(
                      // builder: (context) => LeaderBoard(),
                      //),
                      //);
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/bottom_nav_images/user.png'),
                    onPressed: () {
                      //Navigator.push(
                      //context,
                      //MaterialPageRoute(
                      //builder: (context) => UserProfile(),
                      //),
                      //);
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
