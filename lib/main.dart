import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Themes/Theme_Service.dart';
import 'package:flutterapp/screens/auth_screen.dart';
import 'package:flutterapp/screens/chat_screen.dart';
import 'package:get/get.dart';

import 'Themes/Themes.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeService().theme,
      home: StreamBuilder(stream:FirebaseAuth.instance.authStateChanges(),builder:(ctx,snapshots){
        if(snapshots.hasData){
          return const ChatScreen();
        }
        else{
          return const AuthScreen();
        }
      }),
    );
  }
}
