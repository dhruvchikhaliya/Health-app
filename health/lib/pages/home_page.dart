import 'package:flutter/material.dart';
import 'package:health/services/authentication.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/pages/personal_info.dart';
import 'package:health/charts/LineChart.dart';

//Devloped by dhruv
class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final databaseReference = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  String userUID;
  String name = 'Loading...';
  String email = 'Loading...';
  String address = 'Loading...';
  String phone = 'Loading...';
  String ecg = 'Loading...';
  List<Map<dynamic, dynamic>> lists = [];
  List data;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = _auth.currentUser;
    userUID = user.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('data')
        .doc("$userUID")
        .get();
    name = snapshot['Name'];
    email = snapshot['Email'];
    address = snapshot['Address'];
    phone = snapshot['Phone'];
    setState(() {});
  }

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: (new CircularProgressIndicator()),
        );
      },
    );
    new Future.delayed(new Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('Health'),
      ),
      body: LineChart(userUID),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountEmail: new Text("$email"),
              accountName: new Text("$name"),
              currentAccountPicture: new CircleAvatar(
                child: new Text(
                  "${name[0]}",
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
            ),
            new ListTile(
              title: new Text("Personal Info"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PerInfo(
                          'Personal Info', email, name, address, phone)),
                );
              },
            ),
            new Divider(),
            new ListTile(
                title: new Text("Sign Out"),
                trailing: new Icon(Icons.exit_to_app),
                onTap: signOut),
          ],
        ),
      ),
    );
  }
}
