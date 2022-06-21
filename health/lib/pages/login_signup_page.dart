import 'package:flutter/material.dart';
import 'package:health/services/authentication.dart';
import 'package:health/services/database.dart';
import 'package:health/pages/forgot.dart';

//Devloped by dhruv
class LoginSignupPage extends StatefulWidget {
  LoginSignupPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _errorMessage;
  String _name;
  String _address;
  String key;
  String _phone;
  int load;
  bool _isLoading = false;
  bool _isLoginForm;
  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
    });
    if (validateAndSave()) {
      _isLoading = true;
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);

          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          await DatabaseService(uid: userId)
              .updateUserData(_email, _name, _address, _phone);
          print('Signed Up: $userId');
          _isLoginForm = true;
        }
        setState(() {
          _isLoading = false;
        });
        if (userId.length > 0 && userId != null && _isLoginForm) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
            alignment: Alignment.center,
            child:ScrollConfiguration(
            behavior: MyBehavior(),
            child: new Form(
              key: _formKey,
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  showTitle(),
                  showName(),
                  showPhone(),
                  showAddress(),
                  showEmailInput(),
                  showPasswordInput(),
                  forgotPass(),
                  showPrimaryButton(),
                  showSecondaryButton(),
                  showErrorMessage(),
                ],
              ),
            ))),
        _showCircularProgress(),
      ],
    ));
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

  Widget showTitle() {
    return Container(
        alignment: Alignment.center,
        child: Text(
          _isLoginForm ? "Sign In" : "Sign Up",
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }

  Widget forgotPass() {
    if (_isLoginForm) {
      return new FlatButton(
        child: new Text("Forgot password?",
            style: new TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w300,
                color: Colors.red)),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => forgot()));
        },
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
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

  Widget showEmailInput() {
    return Padding(
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
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 16, left: 16),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Colors.white),
            icon: new Icon(
              Icons.lock,
              color: Colors.white,
            )),
        validator: (value) => value.isEmpty
            ? 'Password can\'t be empty'
            : validatePassword(value),
        onSaved: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showSecondaryButton() {
    return new FlatButton(
        child: new RichText(
          text: new TextSpan(
            children: <TextSpan>[
              new TextSpan(text: _isLoginForm ?'First time here? ':'Have an account? ', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300,color: Colors.white)),
              new TextSpan(text: _isLoginForm ? 'Sign Up':'Sign In', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300,color: Color(0xff009688))),
            ],
          ),
            ),
        onPressed: toggleFormMode);
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding:
            EdgeInsets.fromLTRB(70.0, _isLoginForm ? 0.0 : 25.0, 70.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            color: Color(0xff009688),
            splashColor: Colors.black,
            child: new Text(_isLoginForm ? 'Sign In' : 'Sign Up',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  Widget showName() {
    if (_isLoginForm) {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 16, left: 16),
        child: new TextFormField(
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
          autofocus: false,
          decoration: new InputDecoration(
              labelText: 'Enter Full Name',
              labelStyle: TextStyle(color: Colors.white),
              icon: new Icon(
                Icons.person,
                color: Colors.white,
              )),
          validator: (value) =>
              value.isEmpty ? 'Full name can\'t be empty' : validateName(value),
          onSaved: (value) => _name = value.trim(),
        ),
      );
    }
  }

  Widget showAddress() {
    if (_isLoginForm) {
      return Padding(
        padding: const EdgeInsets.only(top: 0.0),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 16, left: 16),
        child: new TextFormField(
          textCapitalization: TextCapitalization.sentences,
          maxLines: 1,
          autofocus: false,
          decoration: new InputDecoration(
              labelText: 'Enter Home Address',
              labelStyle: TextStyle(color: Colors.white),
              icon: new Icon(
                Icons.add_location,
                color: Colors.white,
              )),
          validator: (value) => value.isEmpty
              ? 'Home address can\'t be empty'
              : validateAddress(value),
          onSaved: (value) => _address = value.trim(),
        ),
      );
    }
  }

  Widget showPhone() {
    if (_isLoginForm) {
      return Padding(
        padding: const EdgeInsets.only(top: 0.0),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 16, left: 16),
        child: new TextFormField(
          keyboardType: TextInputType.phone,
          maxLines: 1,
          autofocus: false,
          decoration: new InputDecoration(
              labelText: 'Enter Mobile Number',
              labelStyle: TextStyle(color: Colors.white),
              icon: new Icon(
                Icons.phone,
                color: Colors.white,
              )),
          validator: (value) => value.isEmpty
              ? 'Mobile number can\'t be empty'
              : validateMobile(value),
          onSaved: (value) => _phone = value.trim(),
        ),
      );
    }
  }

  String validateMobile(String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return null;
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

  String validateName(String value) {
    if (value.contains(" "))
      return null;
    else
      return 'Enter a valid full name';
  }

  String validateAddress(String value) {
    if (value.length >= 14)
      return null;
    else
      return 'Enter valid home address';
  }

  String validatePassword(String value) {
    if (value.length >= 8)
      return null;
    else
      return 'Password must be greater than 8 digit';
  }
}
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}