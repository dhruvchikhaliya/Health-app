import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:health/charts/LineChart.dart';
import 'package:firebase_database/firebase_database.dart';
//Devloped by dhruv

class patient_info extends StatefulWidget {
  patient_info({this.userId, this.email, this.name, this.address, this.phone});
  String userId;
  String email;
  String name;
  String address;
  String phone;
  @override
  State<StatefulWidget> createState() => new _patient_info();
}

class _patient_info extends State<patient_info> {
  @override
  Widget build(BuildContext context) {
    List info = [widget.name, widget.email, widget.address, widget.phone];
    List title = ["Full Name", "Email", "Address", "Mobile Number"];
    List icon = [Icons.person, Icons.email, Icons.home, Icons.phone_android];
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text("Health"),
        ),
        body: Container(
            child: Stack(children: <Widget>[
          Container(
            child: LineChart(widget.userId),
          ),
          Container(
              child: DraggableScrollableSheet(
                  initialChildSize: 0.06,
                  minChildSize: 0.05,
                  maxChildSize: 0.72,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15.0),
                            topLeft: Radius.circular(15.0)),
                      ),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return Container(
                                child: Column(children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Container(
                                    height: 5.0,
                                    width: 20.0,
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.all(
                                            const Radius.circular(8.0))),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 8.0,
                              ),
                              Text(
                                "Patient info",
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              Divider(color: Colors.grey),
                            ]));
                          }
                          index--;
                          return Container(
                              padding: EdgeInsets.all(5),
                              child: Card(
                                  child: ListTile(
                                title: Text(
                                  info[index],
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: new Text(title[index]),
                                trailing: new Icon(icon[index]),
                                onTap: () {
                                  if (index == 3) {
                                    launch("tel:${widget.phone}");
                                  }
                                },
                              )));
                        },
                      ),
                    );
                  }))
        ])),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.delete),
          backgroundColor: Color(0xff009688),
          onPressed: () => showAlertDialog(context),
        ));
  }

  showAlertDialog(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      title: Text('Delete the data?'),
      content: Text('All emergency user data will be delete.'),
      actions: <Widget>[
        new FlatButton(
            child: Text("No"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        FlatButton(
            child: Text("Yes"),
            splashColor: Colors.deepOrange,
            onPressed: () {
              FirebaseDatabase()
                  .reference()
                  .child('Userbodydata')
                  .child(widget.userId)
                  .update({'Emergency': false});
              FirebaseDatabase()
                  .reference()
                  .child('Userbodydata')
                  .child(widget.userId)
                  .child('Freefall')
                  .remove();
              FirebaseDatabase()
                  .reference()
                  .child('Userbodydata')
                  .child(widget.userId)
                  .child('tinyMLans1')
                  .remove();
              FirebaseDatabase()
                  .reference()
                  .child('Userbodydata')
                  .child(widget.userId)
                  .child('tinyMLans2')
                  .remove();
              FirebaseDatabase()
                  .reference()
                  .child('Userbodydata')
                  .child(widget.userId)
                  .child('tinyMLans3')
                  .remove();
              FirebaseDatabase()
                  .reference()
                  .child('Userbodydata')
                  .child(widget.userId)
                  .child('tinyMLans4')
                  .remove();
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
