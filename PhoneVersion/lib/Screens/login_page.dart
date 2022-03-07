import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:copy_it_phone/Screens/home_page.dart';
import 'package:copy_it_phone/auth.dart';
import 'package:copy_it_phone/google_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:copy_it_phone/globals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

String topText = "Login";

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xffA690A4),
        leading: IconButton(onPressed: (){print(FirebaseAuth.instance.currentUser);},icon: Icon(Icons.verified_user),),
        title: Text(
          "LoginPage",
          style: myTextStyle(20, FontWeight.bold),
        ),
      ),
      body: LoginPageBody(),
    );
  }
}

TextEditingController emailEdi = TextEditingController();
TextEditingController passwordEdi = TextEditingController();

class LoginPageBody extends StatefulWidget {
  @override
  _LoginPageBodyState createState() => _LoginPageBodyState();
}

class _LoginPageBodyState extends State<LoginPageBody> {
  bool showpassWord = true;
  bool creatingAcc = true;
  TextEditingController passwordCheckEdi = TextEditingController();
  String _sharedText = "";

  late StreamSubscription _intentDataStreamSubscription;


  @override
  void initState() {

    super.initState();
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String? value) {
          print(_sharedText.toString() + "THIS");
          _sharedText = value!;
          setState(() {
          });
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        print(_sharedText.toString() + "THIS");
        _sharedText = value.toString();
      });
    });
    // TODO: implement initState
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: TextField(
              decoration:
                  InputDecoration(icon: Icon(Icons.email), hintText: "Email"),
              controller: emailEdi,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child: TextField(
              keyboardType: TextInputType.visiblePassword,
              enableSuggestions: false,
              obscureText: showpassWord,
              autocorrect: false,
              decoration: InputDecoration(
                  suffix: IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    color: showpassWord ? Colors.grey : Colors.blue,
                    onPressed: () {
                      showpassWord = !showpassWord;
                      setState(() {});
                    },
                  ),
                  icon: Icon(Icons.vpn_key),
                  hintText: "Password"),
              controller: passwordEdi,
            ),
          ),
          creatingAcc == false
              ? Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: TextField(
                    keyboardType: TextInputType.visiblePassword,
                    enableSuggestions: false,
                    obscureText: showpassWord,
                    autocorrect: false,
                    decoration: InputDecoration(
                        suffix: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          color: showpassWord ? Colors.grey : Colors.blue,
                          onPressed: () {
                            showpassWord = !showpassWord;
                            setState(() {});
                          },
                        ),
                        icon: Icon(Icons.vpn_key),
                        hintText: "retype password"),
                    controller: passwordCheckEdi,
                  ),
                )
              : Container(
                  width: 1,
                  height: 1,
                  color: Colors.transparent,
                ),
          Padding(
              padding: EdgeInsets.only(top: 50),
              child: ElevatedButton(
                  child: Text(creatingAcc ? "Login" : "Create Account"),
                  onPressed: () async {
                    if (creatingAcc == false &&
                        passwordCheckEdi.text != passwordEdi.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("passwords are different")));
                      throw Exception("passwords are wrong");
                    }
                    String? doneN = creatingAcc
                        ? await AuthenticationService(FirebaseAuth.instance)
                            .signIn(
                                email: emailEdi.text,
                                password: passwordEdi.text)
                        : await AuthenticationService(FirebaseAuth.instance)
                            .signUp(
                                email: emailEdi.text,
                                password: passwordEdi.text);
                    print(doneN);
                    if (doneN == "Signed In" || doneN == "Signed Up") {
                      if (FirebaseAuth.instance.currentUser?.uid != null) {
                        String? userUid =
                            FirebaseAuth.instance.currentUser?.uid;
                        var collectionUser = FirebaseFirestore.instance
                            .collection("users")
                            .doc(userUid);

                        collectionUser.get().then((value) => {
                              if (value.exists)
                                {print("userExists!")}
                              else
                                {
                                  collectionUser.set({
                                    "text":
                                        "Welcome to my program this is just first time message so do not worry!"
                                  })
                                }
                            });
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                   MyHomePage()));
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(doneN!)));
                    }
                  })),
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: TextButton(
                child: Text(
                  creatingAcc ? "create account" : "Login",
                  style: myTextStyle(15, FontWeight.w400),
                ),
                onPressed: () {
                  creatingAcc = !creatingAcc;
                  topText = creatingAcc ? "Login" : "Create Account";

                  setState(() {});
                }),
          ),
          Text(_sharedText),
          Padding(
            padding: EdgeInsets.only(top: 150),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Color(0xffB1B695),
                  onPrimary: Colors.black,
                  minimumSize: Size(200, 50)),
              label: Text(
                "Google",
                style: myTextStyle(20, FontWeight.normal),
              ),
              icon: Icon(FontAwesomeIcons.google),
              onPressed: () async {
                UserCredential cre = await signInWithGoogle();
                if (cre.user?.email != null) {
                  if (FirebaseAuth.instance.currentUser?.uid != null) {
                    String? userUid = FirebaseAuth.instance.currentUser?.uid;
                    var collectionUser = FirebaseFirestore.instance
                        .collection("users")
                        .doc(userUid);

                    collectionUser.get().then((value) => {
                          if (value.exists)
                            {print("userExists!")}
                          else
                            {
                              collectionUser.set({
                                "text":
                                    "Welcome to my program this is just first time message so do not worry!"
                              })
                            }
                        });
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                               MyHomePage()));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
