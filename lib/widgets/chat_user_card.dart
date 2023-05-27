import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/helper/MyDateUtil.dart';
import '../api/apis.dart';
import '../models/Mossage.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {

    Message? _message;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0.5),
      elevation: 0.5,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              if (list.isNotEmpty) {
                  _message = list[0];
              }
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(value: downloadProgress.progress),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundColor: Colors.deepOrangeAccent,
                      child: Icon(CupertinoIcons.person_fill, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(_message != null ? _message!.msg :widget.user.about, maxLines: 1,),
                trailing: _message == null
                ? null
                : _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                    ? Container(
                      height: 10,
                      width: 10,
                      decoration:  BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const RadialGradient(
                          colors: [Colors.white, Colors.lightGreen, Colors.green],
                          radius: 0.45,
                          focal: Alignment(0.3, -0.2),
                          tileMode: TileMode.clamp,
                        ),
                      )
                    ) : Text(
                    MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                    style: const TextStyle(
                    color: Colors.black54,
                    )
                ),
              );
            }
        )
      ),
    );
  }
}
