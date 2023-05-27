import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/api/apis.dart';
import 'package:untitled1/screens/HomeScreen.dart';
import 'package:untitled1/screens/auth/LoginScreen.dart';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {

    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, statusBarColor: Colors.white));
      log("Firebase user: ${APIs.auth.currentUser}");
      if (APIs.auth.currentUser != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text("Welcome to MyChat"),
      // ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * 0.35,
              right: mq.width * 0.25,
              width: mq.width * 0.5,
              child: Image.asset('images/GSFCU_Connect_icon.png')),
          Positioned(
              bottom: mq.height * 0.15,
              width: mq.width,
              child: const Text('Made by Ashish Kumar Patel with 😎',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87
                ),
              ),
          )
        ],
      ),
    );

  }
}
