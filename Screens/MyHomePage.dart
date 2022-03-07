import 'package:copy_it_pc/Screens/real_homepage.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../google_login.dart';
import 'package:hive/hive.dart';
import 'package:copy_it_pc/hive_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:copy_it_pc/app_classes/user_text_class.dart';

late FirebaseAuth auth;

TextEditingController usernameEdi = TextEditingController();
TextEditingController passwordEdi = TextEditingController();

void LoginAction(BuildContext context)async{
  try {
    User thUser = await FirebaseAuth.instance
        .signIn(usernameEdi.text, passwordEdi.text);
    print(thUser.toString());
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                userScreen(thUser)));
  } on Exception catch (exception) {
    print("SignIn Exception" + exception.toString());
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }catch(error){
    print("Error");
  }
}

void initFireAuth() async {
  auth = FirebaseAuth.initialize("AIzaSyAWd2-mCIW4uqRV1duP0zt9p2p3jpSAezU",
      await PreferencesStore.create());
}

class MyHomePage extends StatefulWidget {
  final List datas;

  MyHomePage(this.datas);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePageBody(),
    );
  }
}

class HomePageBody extends StatefulWidget {
  const HomePageBody({Key? key}) : super(key: key);

  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  bool showpassWord = true;

  @override
  void initState() {
    initFireAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Column(
        children: [
          TextField(
            controller: usernameEdi,
            textAlign: TextAlign.left,
            decoration:
                InputDecoration(hintText: "Email", icon: Icon(Icons.email)),
          ),
          TextField(
            keyboardType: TextInputType.visiblePassword,
            enableSuggestions: false,
            obscureText: showpassWord,
            autocorrect: false,
            onSubmitted: (val){LoginAction(context);},
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
          Padding(padding: EdgeInsets.only(top: 30)),
          ElevatedButton(
              onPressed: () async {
                LoginAction(context);
              },
              child: Text("Done"))
        ],
      ),
    ));
  }
}
