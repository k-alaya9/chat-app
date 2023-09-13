import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/widget/picker/user_image_picker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email, String password,String username,bool isLogin,File image,BuildContext ctx) submtFunc;
   bool isloading;
   AuthForm(this.submtFunc, this.isloading);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey=GlobalKey<FormState>();
  bool _isLogin=true;
  String _email='';
  String _password='';
  String _userName='';
  File? _userImageFile;

  void _submit()async{
    final isValid=_formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if(!_isLogin &&_userImageFile==null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please pick an Image"),
        padding: EdgeInsets.all(18),
        margin: EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ));
      return;
    }
    if(isValid){
      _formKey.currentState!.save();
      if(_isLogin&&_userImageFile==null){
        try {
          setState(() {
            widget.isloading=true;
          });
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _email, password: _password);
          final user = FirebaseAuth.instance.currentUser;
          final userImage = await FirebaseFirestore.instance
              .collection('User')
              .doc(user!.uid)
              .get();
          _userImageFile = File(userImage['image_url']);
        } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("'No user found for that email.'"),
        padding: EdgeInsets.all(18),
        margin: EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ));
    } else if (e.code == 'wrong-password') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Wrong password provided for that user.'),
        padding: EdgeInsets.all(18),
        margin: EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ));
    }
    setState(() {
      widget.isloading=false;
    });
    }
      }
      widget.submtFunc(_email.trim(),_password.trim(),_userName.trim(),_isLogin,_userImageFile!,context);

    }
  }
  void _pickedImage(File pickedImage){
    _userImageFile=pickedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(26),
          child: Form(
            key: _formKey,
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Welcome to Chat App",style: TextStyle(color: Get.isDarkMode?Colors.white:Colors.black87,fontSize: 25,),textAlign: TextAlign.center,),
                  const SizedBox(height: 10,),
                 // const Divider(color: Colors.black),
                  if(!_isLogin)
                    UserImagePicker(_pickedImage),
                    const SizedBox(height: 10,),
                  TextFormField(
                    key: ValueKey('email'),
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    validator: (val){
                      if(val!.isEmpty || !val.contains('@')){
                        return "please enter  a valid email address";
                      }
                      return null;
                    },
                    onSaved: (val)=>_email=val!,
                      keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: "Email Address"),
                  ),
                  if(!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      autocorrect: true,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.words,
                      validator: (val){
                        if(val!.isEmpty || val.length<4){
                          return "please enter at least 4 characters";
                        }
                        return null;
                      },
                      onSaved: (val)=>_userName=val!,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(labelText: "User name"),
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (val){
                      if(val!.isEmpty || val.length<7){
                        return "Password Must be at least 6 characters";
                      }
                      return null;
                    },
                    onSaved: (val)=>_password=val!,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  SizedBox(height: 12,),
                  if(widget.isloading)
                    CircularProgressIndicator(),
                  if(!widget.isloading)
                  ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin? 'Login': 'Sign Up'),
                    style: ButtonStyle(minimumSize: MaterialStatePropertyAll(Size(500,40))),
                  ),
                  if(!widget.isloading)
                  TextButton(onPressed: (){
                    setState(() {
                      _isLogin=!_isLogin;
                    });
                  }, child: Text(_isLogin?'Create a new account':'Already have an account')),
                ],
              )),
        ),
      ),
    );
  }
}
