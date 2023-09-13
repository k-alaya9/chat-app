import 'dart:io';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:permission_handler/permission_handler.dart';
class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  late bool showEmojiKeyboard;
  final recorder=FlutterSoundRecorder();
  bool isRecorderReady=false;
  bool isPicked=false;
  bool isRecorder=false;
  bool isSending=false;
  final _controller = TextEditingController();
  String _enterdMessage = '';
  String url='';
  String vUrl='';
  File? _pickedimage;
  File? _recordMessage;
  final ImagePicker picker = ImagePicker();
@override
  void initState() {
    // TODO: implement initState
  showEmojiKeyboard = false;
  BackButtonInterceptor.add(myInterceptor);
  initRecorder();
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    BackButtonInterceptor.remove(myInterceptor);
    recorder.closeRecorder();
    super.dispose();
  }

  stop() async{
    if(!isRecorderReady){
      return;
    }
    final path =await recorder.stopRecorder();
    setState(() {
      isRecorder=false;
      _recordMessage=File(path!);
    });

  }

  record() async{
    if(!isRecorderReady){
      return;
    }
    setState(() {
      isRecorder=true;
    });
    await recorder.startRecorder(toFile: 'audio');
  }

  void initRecorder() async{
    final status=await Permission.microphone.request();
    if(status !=PermissionStatus.granted){
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
      isRecorderReady=true;
    recorder.setSubscriptionDuration(Duration(milliseconds:  500));
  }
  void _pickedImage(ImageSource src) async {
    final XFile? image = await await picker.pickImage(
        source: src);
    if (image != null) {
      setState(() {
        _pickedimage = File(image.path);
         isPicked=true;
      });
    } else {
      print("no image selected");
    }
  }

  _sendMessage() async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final userdata = await FirebaseFirestore.instance
        .collection('User')
        .doc(user!.uid)
        .get();
    if(_recordMessage!=null){
      final ref=FirebaseStorage.instance.ref().child('voice_messages').child(_recordMessage!.path+'mp3');
      await ref.putFile(_recordMessage!);
      vUrl=await ref.getDownloadURL();
    }
    else{
      vUrl='';
    }
    if(_pickedimage!=null){
      final ref = FirebaseStorage.instance
          .ref()
          .child('image_sent')
          .child( _pickedimage!.path+ '.jpg');
      await ref.putFile(_pickedimage!);
      url = await ref.getDownloadURL();
    }
    else{
      url='';
    }
    FirebaseFirestore.instance.collection('chat').add(
      {
        'text': _enterdMessage,
        'CreatedAt': Timestamp.now(),
        'username': userdata['username'],
        'userId': user.uid,
        'userImage': userdata['image_url'],
        'imageSend': url,
        'voiceSend':vUrl,
      },
    );
    setState(() {
      isPicked=false;
      _pickedimage=null;
      _recordMessage=null;
      url='';
      vUrl='';
      isSending=false;
    });
    _controller.clear();
    _enterdMessage = '';
  }
  void onTapEmojiField() {
  FocusScope.of(context).unfocus();
      setState(() {
        showEmojiKeyboard = !showEmojiKeyboard;
      });
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (showEmojiKeyboard) {
      setState(() {
        showEmojiKeyboard = false;
      });
      return true;
    } else {
      return false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(showEmojiKeyboard?0:8),
      child: SingleChildScrollView(
        child: Column(children: [
          if(isPicked)
          Row(children: [
            Image.file(_pickedimage!,width: 150),
           IconButton(onPressed: (){
             setState(() {
               isPicked=false;
               _pickedimage=null;
               url='';
             });
           }, icon: Icon(Icons.delete,color: Colors.pink,))
          ],),
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              IconButton(
                  color: Colors.pink,
                  onPressed: () {
                    _pickedImage(ImageSource.camera);
                  },
                  icon: Icon(Icons.camera_alt_outlined)),
              SizedBox(
                width: 2,
              ),
              IconButton(
                  color: Colors.pink,
                  onPressed: () {
                    _pickedImage(ImageSource.gallery);
                  },
                  icon: Icon(Icons.image_outlined)),
              SizedBox(width: 2,),
              Column(children: [
                StreamBuilder<RecordingDisposition>(
                    stream: recorder.onProgress,
                    builder: (context,snapshot){
                  final duration=snapshot.hasData?snapshot.data!.duration:Duration.zero;
                  String twoDigits(int n)=> n.toString().padLeft(2,'0');
                  final twoDigitsMinutes=
                      twoDigits(duration.inMinutes.remainder(60));
                  final twoDigitsSeconds=
                  twoDigits(duration.inSeconds.remainder(60));
                  if(isRecorder)
                   // return Text(duration.inSeconds.toString()+'s');
                 return Text('$twoDigitsMinutes : $twoDigitsSeconds',style: TextStyle(fontSize: 15),);
                  else
                    return Container();
                }),
                IconButton(
                    onPressed: ()async{
                  if(isRecorder){
                    await stop();
                  }else{
                    await record();
                  }
                }, icon: Icon(isRecorder?Icons.stop_circle_outlined:Icons.keyboard_voice_outlined,color: isRecorder?Colors.pink:Colors.grey,size:25,)),
              ],),

              Expanded(
                child: TextField(
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.words,
                  controller: _controller,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(onPressed: onTapEmojiField, icon: Icon(showEmojiKeyboard?Icons.emoji_emotions_sharp:Icons.emoji_emotions_outlined),color:Colors.pink),
                      hintText: "Send a message...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15),),
                  ),
                  onTap: (){
                    setState(() {
                      showEmojiKeyboard=false;
                    });
                  },
                  onChanged: (val) {
                    setState(() {
                      _enterdMessage = val;
                    });
                  },
                ),
              ),
              IconButton(
                  color: Colors.pink,
                  onPressed:
                      _enterdMessage.trim().isNotEmpty || _pickedimage != null ||_recordMessage!=null || isSending
                          ? (){
                    setState(() {
                      isSending=true;
                    });
                    _sendMessage();
                      }
                          : null,
                  icon: isSending?CircularProgressIndicator():Icon(Icons.send)),
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: EmojiKeyboard(
                emotionController: _controller,
                emojiKeyboardHeight: MediaQuery.of(context).size.height*0.4,
                showEmojiKeyboard: showEmojiKeyboard,
                darkMode: false
            ),
          ),
        ]),
      ),
    );
  }

}
