import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voice_message_package/voice_message_package.dart';

class MessageBubble extends StatefulWidget {
  final Key? key;
  final String message;
  final String userName;
  final String userImage;
  final String urlImage;
  final bool isMe;
  final Timestamp TimeSent;
  final String urlVoice;

  MessageBubble(this.message, this.userName, this.userImage,this.urlImage, this.isMe,this.TimeSent,this.urlVoice,
      {this.key});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  final audioPlayer=AudioPlayer();
  bool isPlayed=false;
  Duration duration=Duration.zero;
  Duration position=Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlayed=event==PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration=event;
      });
    });
    audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position=event;
      });
    });
   }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    DateTime time=widget.TimeSent.toDate();
    return Stack(
      clipBehavior: Clip.none,
      children: [
      Row(
        mainAxisAlignment:
            !widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          SizedBox(width: 40,),
          Container(
            decoration: BoxDecoration(
              color: !widget.isMe ? Colors.grey[300] : Theme.of(context).accentColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: widget.isMe ? Radius.circular(0) : Radius.circular(14),
                bottomRight: !widget.isMe ? Radius.circular(0) : Radius.circular(14),
              ),
            ),
            width: widget.urlImage!='' || widget.urlVoice!=''?270:170,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              crossAxisAlignment:
                  !widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(color: !widget.isMe ? Colors.black : Colors.white),
                  textAlign: !widget.isMe ? TextAlign.end : TextAlign.start,
                ),
                SizedBox(
                  height: 5,
                ),
              if(widget.urlVoice!='')
              // VoiceMessage(
              //   audioSrc: widget.urlVoice,
              //   played: isPlayed, // To show played badge or not.
              //   me: widget.isMe, // Set message side.
              //   onPlay: () {
              //     setState(() {
              //       isPlayed=!isPlayed;
              //     });
              //   },
              //   showDuration: true,// Do something when voice played.
              // ),
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.pink,
                            child: IconButton(
                                onPressed: ()async{
                                  if(isPlayed){
                                    await audioPlayer.pause();
                                  }else{
                                    await audioPlayer.play(UrlSource(widget.urlVoice));
                                  }
                                }
                                , icon: Icon(isPlayed?Icons.pause:Icons.play_arrow)),
                          ),
                          Slider(
                            value: position.inSeconds.toDouble(),
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            onChanged: (val)async{
                              final position=Duration(seconds: val.toInt());
                              await audioPlayer.seek(position);
                              await audioPlayer.resume();
                            }),]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(position)),
                          Text(formatTime(duration-position)),
                        ],
                      )
                    ],
                  ),
                ),
                if(widget.urlImage!='')
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                      child: Image.network(widget.urlImage,fit: BoxFit.fill,)
                  ),
                if(widget.urlImage!='')
                  SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(
                    widget.message,
                    style: TextStyle(color: !widget.isMe ? Colors.black : Colors.white),
                    textAlign: !widget.isMe ? TextAlign.end : TextAlign.start,
                  ),
                  SizedBox(width: 10,),
                  Text(DateFormat.yMd().add_jm() .format(time),style: TextStyle(fontSize: 11,color:!widget.isMe ? Colors.black38 : Colors.white30,),textAlign: !widget.isMe ? TextAlign.end : TextAlign.start ),
                ],)
              ],
            ),
          ),
          if(!widget.isMe)
            SizedBox(width: 28,)
        ],
      ),
      Positioned(
        right: widget.isMe?MediaQuery.of(context).size.width-40:null,
          left: !widget.isMe?MediaQuery.of(context).size.width-40:null,
          bottom: 0,
          child: CircleAvatar(
            backgroundImage: NetworkImage(widget.userImage),
          )),
    ],
    );

  }

  String formatTime(Duration position) {
    String twoDigits(int n)=> n.toString().padLeft(2,'0');
    final hours=twoDigits(duration.inHours);
    final minutes=
    twoDigits(duration.inMinutes.remainder(60));
    final seconds=
    twoDigits(duration.inSeconds.remainder(60));
    return[
      if(duration.inHours>0)hours,
      minutes,
      seconds
    ].join(':');
  }
}
