import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Themes/Theme_Service.dart';
import 'package:flutterapp/widget/chat/message.dart';
import 'package:flutterapp/widget/chat/new_message.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    fbm.subscribeToTopic('chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        leading: IconButton(onPressed: (){
          ThemeService().switchTheme();
        }, icon:Icon(Get.isDarkMode? Icons.light_mode:Icons.dark_mode,color: Colors.white,)),
        title: const Text("Chat"),
        centerTitle: true,
        actions: [
          DropdownButton(
              underline: Container(),
              icon: const Icon(Icons.more_vert, color: Colors.white),
              items: [
                DropdownMenuItem(
                  value: 'clear chat',
                  child: Row(
                    children:  [
                      Icon(
                        Icons.delete,
                        color: Get.isDarkMode?Colors.white:Colors.black,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text('Clear chat')
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children:  [
                      Icon(
                        Icons.exit_to_app,
                        color: Get.isDarkMode?Colors.white:Colors.black,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text('LogOut')
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == 'clear chat') {
                  FirebaseFirestore.instance.collection('chat').get().then(
                      (snapshot){
                        for(DocumentSnapshot doc in snapshot.docs){
                          doc.reference.delete();
                        }
                      }
                  );
                }
                if (value == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              })
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: Message()),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}
