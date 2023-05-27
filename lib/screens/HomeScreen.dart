import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled1/models/chat_user.dart';
import 'package:untitled1/screens/ProfileScreen.dart';
import 'package:untitled1/widgets/chat_user_card.dart';
import 'package:untitled1/main.dart';

import '../api/apis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ChatUser> list = [];

  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);

          }

        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField (
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search..."
                      ),
                      autofocus: true,
                      style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.5
                      ),
                      onChanged: (val) {
                        _searchList.clear();
                        for(var i in list) {
                          if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                              i.email.toLowerCase().contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                  )
                :
            const Text("GSFCU Connect"),
            actions: [
              IconButton(
                  onPressed: (){
                      setState(() {
                        if (_isSearching) {
                          _isSearching = false;
                        } else {
                          _isSearching = true;
                        }
                      });
                  },
                  icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid: Icons.search)
              ),
              IconButton(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me))
                );
              }, icon: const Icon(Icons.more_vert_outlined))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: FloatingActionButton(
              onPressed:() async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
              },
              backgroundColor: Colors.deepOrangeAccent,
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch(snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                        itemCount: _isSearching ? _searchList.length: list.length,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: mq.height * 0.01),
                        itemBuilder: (context, index) {
                          return ChatUserCard(user: _isSearching ? _searchList[index] : list[index],);
                        }
                    );
                  } else {
                    return const Center(
                        child: Text(
                          "Add New Connection",
                          style: TextStyle(fontSize: 20, color: Colors.black54),
                        ),

                    );
                  }
              }



            }
          )
        ),
      ),
    );
  }
}
