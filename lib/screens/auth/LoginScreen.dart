import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled1/helper/dialogs.dart';
import 'package:untitled1/screens/HomeScreen.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/apis.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isAnimate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }


  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    try{
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\nSignIn with Google: $e');
      Dialogs.showSnackbar(context, "Please check your Internet Connection and Try Again...");
      return null;
    }
    // return true;
  }

  _handleGoogleBtnClick(){
    Dialogs.showProgressbar(context);
    _signInWithGoogle().then((user)  async {
      Navigator.pop(context);
      if (user != null){
        log("Email: ${user.user?.email}");
        log("User: ${user.user}");
        log("UserAdditionalInfo: ${user.additionalUserInfo}");

        var email = user.user?.email;
        if ((APIs.auth.currentUser != null)) {
          // ignore: use_build_context_synchronously
          if (email?.contains("gsfcuniversity.ac.in")!= false) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          }
          else {
            Dialogs.showProgressbar(context);
            await APIs.auth.signOut();
            await GoogleSignIn()
                .signOut();
            log("Belong to some other organization...");
            // ignore: use_build_context_synchronously
            Dialogs.showSnackbar(context, "Account doesn't belongs to GSFC University");
          }

        } else {
          await APIs.createUser()
              .then((value) =>
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HomeScreen()
                  )
              )
          );
        }
      }

    });
  }


  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * 0.25,
              right: _isAnimate ? mq.width * 0.125 : -mq.width * 0.5,
              width: mq.width * 0.75,
              duration: const Duration(milliseconds: 800),
              child: Image.asset('images/gsfcu_connect.png')),
          Positioned(
              bottom: mq.height * 0.20,
              left: mq.width * 0.15,
              width: mq.width * 0.7,
              height: mq.height * 0.06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      shape: const StadiumBorder(),
                      elevation: 2),
                  onPressed: _handleGoogleBtnClick,
                  icon: Image.asset("images/google.png", height: mq.height * 0.04,),
                  label: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "Continue with "
                        ),
                        TextSpan(
                          text: "Google",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        )
                      ]
                    ),
                  )
              )
          )
        ],
      ),
    );
  }
}
