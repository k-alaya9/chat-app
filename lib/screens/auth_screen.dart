import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/widget/auth/authform.dart';
import 'dart:io';
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  late final UserCredential? credential;
  bool isLoading=false;
  void _submitAuthForm(String email, String password, String username,
      bool isLogin,File image, BuildContext ctx) async {
    try {
      setState(() {
        isLoading=true;
      });
      if (isLogin) {
        credential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final ref= FirebaseStorage.instance.ref().child('user_image').child(credential!.user!.uid+'.jpg');
        await ref.putFile(image);
        final url=await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('User')
            .doc(credential!.user!.uid)
            .set({
          'username': username,
          'password': password,
          'image_url': url,
        },);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erorr';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      }
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        padding: EdgeInsets.all(18),
        margin: EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ));
      setState(() {
        isLoading=false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(alignment: Alignment.center, children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Image.network(
              'https://previews.123rf.com/images/aldanna/aldanna1506/aldanna150600008/40902796-vector-seamless-mobile-apps-pattern-with-music-chat-gallery-speaking-bubble-email-magnifying-glass.jpg',
              opacity: const AlwaysStoppedAnimation(1),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(child: AuthForm(_submitAuthForm,isLoading)),
        ]),
      ),
    );
  }
}
