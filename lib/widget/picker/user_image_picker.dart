import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) imagePickFn;
   UserImagePicker( this.imagePickFn);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedimage;
  final ImagePicker picker = ImagePicker();
  void _pickedImage(ImageSource src)async{
    final XFile? image= await  await picker.pickImage(source:src,imageQuality: 50,maxWidth: 150);
    if(image!=null){
      setState(() {
        _pickedimage=File(image.path);
      });
      widget.imagePickFn(_pickedimage!);
    }
    else{
      print("no image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: _pickedimage!=null?FileImage(_pickedimage!):null,
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(onPressed: ()=>_pickedImage(ImageSource.camera), icon: Icon(Icons.camera), label: Text("add image \n from Camera",textAlign: TextAlign.center,)),
            TextButton.icon(onPressed: ()=>_pickedImage(ImageSource.gallery), icon: Icon(Icons.image_outlined), label: Text("add image \n from Gallery",textAlign: TextAlign.center,))
          ],
        ),
      ],
    );
  }
}
