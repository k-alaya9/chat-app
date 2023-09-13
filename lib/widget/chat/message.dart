import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/widget/chat/message_bubble.dart';

class Message extends StatelessWidget {
  const Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('CreatedAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final docs = snapshot.data!.docs;
        final user=FirebaseAuth.instance.currentUser;
        return ListView.builder(
          reverse: true,
          itemCount: docs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            docs[index]['text'],
            docs[index]['username'],
            docs[index]['userImage'],
            docs[index]['imageSend'],
            docs[index]['userId']==user!.uid,
            docs[index]['CreatedAt'],
            docs[index]['voiceSend'],
            key: ValueKey(docs[index].id),
          ),
        );
      },
    );
  }
}
