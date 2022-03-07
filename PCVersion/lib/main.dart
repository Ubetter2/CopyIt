import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'Screens/MyHomePage.dart';
import 'package:firedart/firedart.dart';
import 'hive_store.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Firestore firestore = Firestore("copyit-a1056");

  List datas = [];
  await firestore.collection("users").get().then((value) => {
        value.forEach((element) {
          datas.add(element);
          print(element.toString());
        })
      });
  runApp(MyApp(datas));
}

class MyApp extends StatelessWidget {
  final List datas;
  MyApp(this.datas);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(datas),
    );
  }
}
