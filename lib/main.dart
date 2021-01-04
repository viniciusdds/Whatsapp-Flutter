import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';

void main() async {

   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();

   runApp(MaterialApp(
      home: Login(),
      theme: ThemeData(
         primaryColor: Color(0xff075e54),
         accentColor: Color(0xff25D366)
      ),
      debugShowCheckedModeBanner: false,
   ));
}

