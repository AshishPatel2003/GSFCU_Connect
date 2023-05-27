import 'package:flutter/material.dart';
import 'package:untitled1/screens/HomeScreen.dart';
import 'package:untitled1/screens/SplashScreen.dart';
import 'package:untitled1/screens/auth/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
  .then((value) {
      _initilizeFirebase();
      runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Chat",
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          centerTitle: true,
          elevation: 1 ,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24
          ),
          backgroundColor: Colors.deepOrangeAccent,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}



_initilizeFirebase() async => await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
