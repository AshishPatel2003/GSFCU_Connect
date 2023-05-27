import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/api/apis.dart';
import 'package:untitled1/helper/MyDateUtil.dart';

import '../main.dart';
import '../models/Mossage.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
      ? _greenMessage()
      : _orangeMessage();
  }

  Widget _orangeMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      log("message read updated one time \nMessage is '${widget.message.msg}'");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.height * 0.01),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * 0.04,
              vertical: mq.height * 0.01
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 231, 184),
              border: Border.all(color:Colors.orangeAccent.shade100),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15)
              ),
            ),
            child:
            widget.message.type == Type.text
            ? Text(
              widget.message.msg,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54
              ),
            ) : ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.03),
              child: CachedNetworkImage(
                width: mq.height *  0.05,
                height: mq.height * 0.05,
                imageUrl: widget.message.msg,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(Icons.image),
                ),
              ),
            ),
          ),
        ),
        
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54
            ),
          ),
        )
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
                Row(
                  children: [
                    SizedBox(width: mq.width * 0.04,),
                    if (widget.message.read.isNotEmpty)
                      Icon(Icons.done_all_rounded, color: Colors.blue , size: 20,),


                    SizedBox(width: mq.width * 0.01 ,),
                    Text(
                    MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54
                      ),
                    ),
                  ],
                ),

        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? mq.height * 0.01 : mq.height * 0.01),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04,
                vertical: mq.height * 0.01
            ),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 255, 176),
                border: Border.all(color:Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15)
                )
            ),
            child: widget.message.type == Type.text
                ? Text(
              widget.message.msg,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54
              ),
            ) : ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.01),
              child: CachedNetworkImage(
                // width: mq.height *  0.3,
                // height: mq.height * 0.3,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 1,),

                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(Icons.image),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
