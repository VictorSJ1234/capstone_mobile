import 'package:capstone_mobile/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

import 'screens/main_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background/main_background.png',
              fit: BoxFit.cover,
            ),
          ),

          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.09),
                    Image.asset(
                      'assets/logo/pasig_health_department_logo.png',
                      width: constraints.maxHeight * 0.35,
                      height: constraints.maxHeight * 0.35,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.02),
                    Text(
                      'Pasig Dengue Task Force:\n Mosquinator',
                      style: TextStyle(
                        fontFamily: "SquadaOne",
                        fontSize: constraints.maxHeight * 0.048,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xff3D3D3D),
                            blurRadius: 4,
                            offset: Offset(1, 3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.08),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                      child: SwipeableButtonView(
                        buttonText: "SLIDE TO EXPLORE",
                        buttonWidget: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                        buttonColor: Color(0xff3D5BF6),
                        buttontextstyle: TextStyle(color: Colors.black),
                        activeColor: Color(0xffF3F3F3),
                        isFinished: isFinished,
                        onWaitingProcess: () {
                          Future.delayed(Duration(seconds: 0), () {
                            setState(() {
                              isFinished = true;
                            });
                          });
                        },
                        onFinish: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Login(),
                            ),
                          );

                          setState(() {
                            isFinished = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
