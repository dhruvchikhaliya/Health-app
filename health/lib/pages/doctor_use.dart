import 'package:flutter/material.dart';
import 'package:health/services/authentication.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/pages/patient_info.dart';
import 'package:firebase_database/firebase_database.dart';

//Devloped by dhruv
class doctor_use extends StatefulWidget {
  doctor_use({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  @override
  State<StatefulWidget> createState() => new _doctor_use();
}

class _doctor_use extends State<doctor_use> {
  final databaseReference = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  String userUID;
  String name = 'Loading...';
  String email = 'Loading...';
  bool emer = false;
  var case_user;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    user = _auth.currentUser;
    userUID = user.uid;
    setState(() {});
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
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text('Health'),
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountEmail: new Text("Doctor"),
              currentAccountPicture: new CircleAvatar(
                child: new Text(
                  "D",
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                ),
              ),
            ),
            new Divider(),
            new ListTile(
                title: new Text("Sign Out"),
                trailing: new Icon(Icons.exit_to_app),
                onTap: signOut),
          ],
        ),
      ),
      body: new StreamBuilder(
          stream: FirebaseFirestore.instance.collection("data").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return new ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.documents[index];
                    String ui = ds["uid"];
                    return StreamBuilder(
                        stream: FirebaseDatabase.instance
                            .reference()
                            .child("Userbodydata")
                            .child(ui)
                            .child("Emergency")
                            .onValue,
                        builder: (context, AsyncSnapshot<Event> snapshot1) {
                          if (snapshot1.hasData) {
                            DataSnapshot dataValues = snapshot1.data.snapshot;
                            if (dataValues.value != null) {
                              emer = dataValues.value;
                            } else {
                              emer = false;
                            }
                          } else {
                            emer = false;
                          }

                          return Card(
                              elevation: 5,
                              color: Colors.black,
                              child: ListTile(
                                title: Text(ds["Name"] ?? ""),
                                subtitle: Text(ds["Phone"] ?? ""),
                                trailing: Text(emer ? "Emergency" : ""),
                                onLongPress: () => showAlertDialog(context, ui),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => patient_info(
                                              userId: ds["uid"],
                                              email: ds["Email"],
                                              name: ds["Name"],
                                              address: ds["Address"],
                                              phone: ds["Phone"])));
                                },
                              ));
                        });
                  });
            } return LinearProgressIndicator();
          }),
    );
  }

  showAlertDialog(BuildContext context, String ui) {
    AlertDialog dialog = AlertDialog(
      title: Text('Delete the data?'),
      content: Text('All user data will be delete.'),
      actions: <Widget>[
        new FlatButton(
            child: Text("No"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
            child: Text("Yes"),
            splashColor: Colors.deepOrange,
            onPressed: () async {
              await Firestore.instance
                  .collection('data')
                  .document("$ui")
                  .delete();
              Navigator.pop(context);
            })
      ],
      elevation: 24.0,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }
}
