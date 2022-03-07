import 'package:firedart/auth/user_gateway.dart';
import 'package:flutter/material.dart';
import 'package:firedart/firedart.dart';
import 'package:copy_it_pc/app_classes/user_text_class.dart';
import 'package:clipboard/clipboard.dart';

String scrText = "";

class userScreen extends StatefulWidget {
  User user;

  userScreen(this.user);

  @override
  _userScreenState createState() => _userScreenState();
}

class _userScreenState extends State<userScreen> {
  void loadUserData(User thUser, BuildContext context) async {
    Firestore firestore = Firestore("copyit-a1056");
    List datas = [];
    var userMap = await firestore.collection("users").document(thUser.id).get();
    Map<String, dynamic> userData = userMap.map;
    UserText userText = UserText.fromMap(userData);
    scrText = userText.text;
    FlutterClipboard.copy(userText.text);
    setState(() {});
  }

  @override
  void initState() {
    loadUserData(widget.user, context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back)),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 2.5),
                    child: Text("You are logged in!"),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2.5),
                child: StreamBuilder(
                  stream: Firestore("copyit-a1056").collection("users").document(widget.user.id).stream,
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return Text("No data");
                    }else{
                      String snapData = snapshot.data.toString().replaceRange(0, 43, "").replaceAll("}", "");
                      FlutterClipboard.copy(snapData);
                      return Text(snapData);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
