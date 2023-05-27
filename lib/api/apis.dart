import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:untitled1/models/Mossage.dart';
import 'package:untitled1/models/chat_user.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;
  static late ChatUser me;

  static Future<bool> userExists() async {
    return (
        await firestore.collection('users').doc(user.uid).get()
    ).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists){
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Sleeping...",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: ''
    );
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return  firestore.collection("users").where('id', isNotEqualTo: user.uid).snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about' : me.about
    });

  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'))
    .then((p0) {
      log("Data Transferred : ${p0.bytesTransferred / 1000 } kb");
    });

    me.image = await ref.getDownloadURL();
    await firestore.collection("users").doc(user.uid).update({'image': me.image});
  }


  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser chatUser) {
    return  firestore.collection("chats/${getConversationID(chatUser.id)}/messages/").orderBy('sent').snapshots();
  }

  static String getConversationID (String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';


  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message  message = Message(toId: chatUser.id, msg: msg, read: '', type: type, sent: time, fromId: user.uid);
    final ref =  firestore.collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref.doc().set(message.toJson());
  }


  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection("chats/${getConversationID(message.fromId)}/messages/")
        .doc(message.sent)
        .update({
          'read': DateTime.now().millisecondsSinceEpoch.toString()
        });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser chatUser) {
    return  firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/")
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log("Data Transferred : ${p0.bytesTransferred / 1000 } kb");
    });

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image );
  }
}