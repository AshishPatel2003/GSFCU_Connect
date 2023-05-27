

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled1/helper/dialogs.dart';
import 'package:untitled1/models/chat_user.dart';
import 'package:untitled1/main.dart';

import '../api/apis.dart';
import 'auth/LoginScreen.dart';


class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  // ignore: prefer_final_fields
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];
  @override
  void initState() {
    // ignore: avoid_function_literals_in_foreach_calls
    _focusNodes.forEach((node){
      node.addListener(() {
        setState(() {});
      });
    });
    super.initState();
  }

  void _showBottomSheet(BuildContext context){
    showBottomSheet(
        context: context,
        backgroundColor: Colors.black87,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            topLeft: Radius.circular(0),
          )
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: false,
            padding: EdgeInsets.only(
              top: mq.height * 0.03,
              bottom: mq.height * 0.05,
              left: mq.height * 0.02,
              right: mq.height * 0.02
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Text("Pick Profile Picture",
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * 0.3, mq.height * 0.14)
                    ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if ( image != null ) {
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("images/gallery.png")
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.14)
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if ( image != null ) {
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset("images/camera.png")
                  )
                ],
              )


            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: FloatingActionButton.extended(
            onPressed:() async {
              Dialogs.showProgressbar(context);
              await APIs.auth.signOut().then((value) =>
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => LoginScreen()
                      )
                  )
              );
              await GoogleSignIn()
                  .signOut().then((value) {
                Navigator.pop(context);
                Navigator.pop(context);

                Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()
                      )
                  );
              }
              );;
            },
            backgroundColor: Colors.deepOrangeAccent,
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Logout"),
          ),
        ),
        body: Builder(
          builder: (context) {
            return Form(
              key: _formkey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(width: mq.width, height: mq.height * 0.05),
                      Stack(
                        children: [
                          _image != null
                          ?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * 0.1),
                            child: Image.file(
                              File(_image!),
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.cover,

                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(mq.height * 0.1),
                              child: CachedNetworkImage(
                                width: mq.height * 0.2,
                                height: mq.height * 0.2,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.image,
                                progressIndicatorBuilder: (context, url, downloadProgress) =>
                                    CircularProgressIndicator(value: downloadProgress.progress),
                                errorWidget: (context, url, error) => const CircleAvatar(
                                  backgroundColor: Colors.deepOrangeAccent,
                                  child: Icon(CupertinoIcons.person_fill, color: Colors.white),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: MaterialButton(
                                onPressed: (){
                                  _showBottomSheet(context);
                                },
                              color: Colors.white,
                              shape: CircleBorder(),
                                child: const Icon(Icons.edit),
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: mq.width, height: mq.height * 0.03),
                      Text(
                        widget.user.email,
                        style: const TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      SizedBox(width: mq.width, height: mq.height * 0.03),
                      TextFormField(
                        focusNode: _focusNodes[0],
                        initialValue: widget.user.name,
                        onSaved: (val) => APIs.me.name = val ?? '',
                        validator: (val) => (val != null && val.isNotEmpty) ? null : "Required Field",
                        style: const TextStyle(
                          fontSize: 16
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: _focusNodes[0].hasFocus ? Colors.deepOrangeAccent : Colors.black54,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.deepOrangeAccent,
                              width: 2.0
                            )
                          ),
                          hintText: "E.g. Ashish Kumar Patel",
                          label: Text(
                              " Name ",
                              style: TextStyle(
                                color: _focusNodes[0].hasFocus? Colors.deepOrangeAccent : Colors.black54,
                                fontSize: _focusNodes[0].hasFocus? 20 : 16,
                                fontWeight: _focusNodes[0].hasFocus? FontWeight.w600 : FontWeight.normal,
                              ),
                          )
                        ),
                      ),
                      SizedBox(width: mq.width, height: mq.height * 0.03),
                      TextFormField(
                        focusNode: _focusNodes[1],
                        initialValue: widget.user.about,
                        onSaved: (val) => APIs.me.about = val ?? '',
                        validator: (val) => (val != null && val.isNotEmpty) ? null : "Required Field",
                        style: const TextStyle(
                            fontSize: 16
                        ),
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: _focusNodes[1].hasFocus ? Colors.deepOrangeAccent : Colors.black54,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2.0
                                )
                            ),
                            hintText: "E.g. example@gmail.com",
                            label: Text(
                              " About ",
                              style: TextStyle(
                                color: _focusNodes[1].hasFocus? Colors.deepOrangeAccent : Colors.black54,
                                fontSize: _focusNodes[1].hasFocus? 20 : 16,
                                fontWeight: _focusNodes[1].hasFocus? FontWeight.w600 : FontWeight.normal,
                              ),
                            )
                        ),
                      ),
                      SizedBox(width: mq.width, height: mq.height * 0.03),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent
                        ),
                          onPressed: () {
                          log("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nGesture erro by ashish");
                            if(_formkey.currentState!.validate()) {
                              _formkey.currentState!.save();
                              APIs.updateUserInfo().then((value) => {
                                Dialogs.showSnackbar(context, "Profile Updated Successfully")
                              });
                            } else {
                              log("Error by form");

                            }
                          },
                        icon: const  Icon(Icons.update),
                        label: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 18
                          ),),

                      )

                    ],
                  ),
                ),
              ),
            );
          }
        )
       ),
    );
  }

}
