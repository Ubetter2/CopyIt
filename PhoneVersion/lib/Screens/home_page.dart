import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:copy_it_phone/Screens/login_page.dart';
import 'package:copy_it_phone/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:image_picker/image_picker.dart';


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () {
          print(FirebaseAuth.instance.currentUser);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        icon: Icon(Icons.verified_user),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xffA690A4),
        title: Text(
          "Home",
          style: myTextStyle(20, FontWeight.bold),
        ),
      ),
      body: MyHomePageBody(),
    );
  }
}

class MyHomePageBody extends StatefulWidget {
  const MyHomePageBody({Key? key}) : super(key: key);

  @override
  _MyHomePageBodyState createState() => _MyHomePageBodyState();
}

class _MyHomePageBodyState extends State<MyHomePageBody> {
  TextEditingController textEdi = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File _image = File("");
  bool picked = false;

  void _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      final inputImage = InputImage.fromFile(_image);
      final textDetector = GoogleMlKit.vision.textDetector();
      final RecognisedText recognisedText = await textDetector.processImage(inputImage);
      String text = recognisedText.text;
      picked = true;
      updateText(text);
      print(text);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }
  void updateText(String text){
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      String? userUid = FirebaseAuth.instance.currentUser?.uid;
      var collection =
      FirebaseFirestore.instance.collection("users");
      collection.doc(userUid).set({"text": text});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textEdi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 8, top: 20),
          child: Container(
            width: 300,
            child: TextField(
              textAlign: TextAlign.start,
              controller: textEdi,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                  hintText: "Insert Text",
                  hintStyle: myTextStyle(15, FontWeight.normal)),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 30, left: 50),
            child: ElevatedButton(
              onPressed: () {
                updateText(textEdi.text);
              },
              child: Text(
                "Done",
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xff5E4B56))),
            )),
        Padding(
          padding: EdgeInsets.only(top: 30),
          child: ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Pick a photo"),
            onTap: () {
              _takePicture();

            },
          ),
        ),
        _image != null && picked ? Expanded(child: Image.file(_image)) : Container(color: Colors.transparent,)
      ],
    );
  }
}
