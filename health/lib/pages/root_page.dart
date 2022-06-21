import 'package:flutter/material.dart';
import 'package:health/pages/login_signup_page.dart';
import 'package:health/services/authentication.dart';
import 'package:health/pages/home_page.dart';
import 'package:health/pages/doctor_use.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';

//Devloped by dhruv
enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN, LOGGED_IN_DOCTOR }

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  String id = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : doctorId();
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    doctorId();
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  doctorId() {
    FirebaseDatabase.instance
        .reference()
        .child("Doctor")
        .once()
        .then((DataSnapshot snapshot) {
      id = snapshot.value;
      if (_userId == id) {
        setState(() {
          authStatus = AuthStatus.LOGGED_IN_DOCTOR;
        });
      } else {
        setState(() {
          authStatus = AuthStatus.LOGGED_IN;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return new HomePage(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      case AuthStatus.LOGGED_IN_DOCTOR:
        if (_userId.length > 0 && _userId != null) {
          return new doctor_use(
            userId: _userId,
            auth: widget.auth,
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
