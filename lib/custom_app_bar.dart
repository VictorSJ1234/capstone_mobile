import 'package:capstone_mobile/screens/notification/notification.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as BadgesPackage;


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int notificationCount;
  final Object token;

  CustomAppBar({required this.token, required this.title, Key? key, required this.notificationCount}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);


  @override
  Widget build(BuildContext context) {
    return AppBar(
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
            colors: [Color(0xff28376d), Color(0xff28376d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        title, // Use the title parameter here
        style: TextStyle(fontFamily: 'SquadaOne'),
      ),
      actions: [
        Stack(
          children: [
            Positioned(
              left: 0, // Adjust the position as needed
              top: 0, // Adjust the position as needed
              child: BadgesPackage.Badge( // Use the Badge widget from the badges package
                badgeContent: Text(
                  notificationCount.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(token: token, notificationCount: notificationCount,),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
