import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:health/services/authentication.dart';
import 'package:health/pages/root_page.dart';

//Devloped by dhruv
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: new ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.black,
          backgroundColor: Colors.black,
          indicatorColor: Color(0xff0E1D36),
          buttonColor: Color(0xff3B3B3B),
          hintColor: Color(0xff280C0B),
          highlightColor: Color(0xff372901),
          hoverColor: Color(0xff3A3A3B),
          focusColor: Color(0xff0B2512),
          disabledColor: Colors.grey,
          textSelectionColor: Colors.white,
          cardColor: Colors.black,
          canvasColor: Colors.black,
          brightness: Brightness.dark,
        ),
        home: new RootPage(auth: new Auth()));
  }
}
