import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class forgot extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _forgot();
}

class _forgot extends State<forgot> {
  final _formKey = new GlobalKey<FormState>();
  String _errorMessage;
  bool _isLoading = false;
  String email_ = "";

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
    });
    try {
      if (validateAndSave()) {
        _isLoading = true;
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email_);
      }
      setState(() {
        _isLoading = false;
        Navigator.pop(context);
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _formKey.currentState.reset();
      });
    }
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {}
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
        ),
        body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
          Container(
              height: double.maxFinite,
              width: double.maxFinite,
              alignment: Alignment.center,child:ScrollConfiguration(
            behavior: MyBehavior(),
              child: new Form(
                  key: _formKey,
                  child: new ListView(shrinkWrap: true, children: <Widget>[
                    titl(),
                    emailInput(),
                    submit(),
                    showErrorMessage(),
                  ])))),
    _showCircularProgress(),
        ]));
  }

  Widget titl(){
    return new Container(
        alignment: Alignment.center,
        child: Text(
          "Forgot password",
          style: TextStyle(
              fontSize: 30,
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ));
  }
  Widget emailInput() {
    return new Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 16, left: 16),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white),
            icon: new Icon(
              Icons.mail,
              color: Colors.white,
            )),
        validator: (value) =>
            value.isEmpty ? 'Email can\'t be empty' : validateEmail(value),
        onSaved: (value) => email_ = value.trim(),
      ),
    );
  }

  Widget submit() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(50.0, 30.0, 50.0, 10.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            color: Color(0xff009688),
            splashColor: Colors.black,
            child: new Text('Send Email',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
}
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}