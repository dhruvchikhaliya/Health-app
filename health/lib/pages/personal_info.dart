import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//Devloped by dhruv
class PerInfo extends StatelessWidget {
  String title;
  String email;
  String name;
  String address;
  String phone;
  PerInfo(this.title, this.email, this.name, this.address, this.phone);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(title)),
        body: SafeArea(
            child: new ListView(children: <Widget>[
          new Divider(),
          new ListTile(
            title: new Text('Full Name'),
            subtitle: new Text(name),
            trailing: new Icon(Icons.person),
          ),
          new Divider(),
          new ListTile(
            title: new Text('Email'),
            subtitle: new Text(email),
            trailing: new Icon(Icons.email),
          ),
          new Divider(),
          new ListTile(
            title: new Text('Address'),
            subtitle: new Text(address),
            trailing: new Icon(Icons.home),
          ),
          new Divider(),
          new ListTile(
            title: new Text('Mobile Number'),
            subtitle: new Text(phone),
            trailing: new Icon(Icons.phone_android),
          ),
        ])));
  }
}
