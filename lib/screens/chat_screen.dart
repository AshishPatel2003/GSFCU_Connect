import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled1/models/chat_user.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/Mossage.dart';
import '../widgets/message_card.dart';



class ChatScreen extends StatefulWidget {

  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Message> _list = [];

  final _textController = TextEditingController();

  bool _showEmoji = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));

  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          _showEmoji = false;
        });
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: Color.fromARGB(255, 255, 237, 219),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log("Data : ${jsonEncode(data![0].data())}");
                          _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                        // final _list = ["Hi", "Hello"];
                        //   _list.clear();
                        //   _list.add(Message(toId: 'xyz', msg: "Hii", read: "", type: Type.text, sent: '12:00 AM', fromId: APIs.user.uid));
                        //   _list.add(Message(toId: APIs.user.uid, msg: "Hello", read: '', type: Type.text, sent: '12:01 AM', fromId: 'xyz'));


                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _list.length,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                itemBuilder: (context, index) {
                                  // return ChatUserCard(user: _isSearching ? _searchList[index] : __list[index],);
                                  return MessageCard(message: _list[index]);
                                }
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "Say Hii 👋",
                                style: TextStyle(fontSize: 20, color: Colors.black54),
                              ),

                            );
                          }
                      }



                    }
                ),
              ),
              _chatInput(),

              if(_showEmoji)
              SizedBox(
                height: mq.height * 0.35,
                child: EmojiPicker(
                  textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                  config: Config(
                    bgColor: const Color.fromRGBO(255, 234, 248, 255),
                    columns: 7,
                    emojiSizeMax: 32 * (Platform.isIOS  ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894

                )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white70,),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.03),
            child: CachedNetworkImage(
              width: mq.height *  0.05,
              height: mq.height * 0.05,
              imageUrl: widget.user.image,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => const CircleAvatar(
                backgroundColor: Colors.deepOrangeAccent,
                child: Icon(CupertinoIcons.person_fill, color: Colors.white),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10,),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.name,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text("Last Seen not available",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

          ],
        )
      ],
    );
  }

  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: mq.height *  0.01),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });

                    },
                      icon: const Icon(Icons.emoji_emotions, color: Colors.black54,
                      size: 25,)
                  ),

                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                        }
                        } ,
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                        hintText: "Type Something..",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none
                        ),
                        ),
                        ),

                        IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                          if ( image != null ) {
                            APIs.sendChatImage(widget.user, File(image.path));
                          }
                        },
                        icon: const Icon(Icons.image,
                       color: Colors.black54,
                      size: 25,)
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                        if ( image != null ) {
                          APIs.sendChatImage(widget.user, File(image.path));
                        }

                      },
                      icon: const Icon(Icons.camera_alt_rounded, color: Colors.black54,
                      size: 25,)
                  ),

                ],
              ),
            ),
          ),
          MaterialButton(
              onPressed: (){
                if (_textController.text.isNotEmpty) {
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                  _textController.text = '';
                }
              },
            shape: const CircleBorder(),
            padding: EdgeInsets.all(mq.height * 0.01),
            color:Colors.green,
            child: Icon(Icons.send, color: Colors.white, size: 26,),
          )
        ],
      ),
    );
  }
}
