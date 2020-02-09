import 'package:flutter/material.dart';
import 'package:minimal_blog/LoginRegisterPage.dart';
import 'package:minimal_blog/HomePage.dart';
import 'authentication.dart';

class MappingPage extends StatefulWidget{
  final AuthImplementation auth;
  MappingPage({this.auth});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MappingPageState();
  }
}

enum AuthStatus{
  notSignedIn,
  signedIn
}

class _MappingPageState extends State<MappingPage> {

  AuthStatus _authStatus=AuthStatus.notSignedIn;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.auth.getCurrentUser().then((firebaseUserID){
      _authStatus=firebaseUserID==null?AuthStatus.notSignedIn:AuthStatus.signedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    switch(_authStatus){
      case AuthStatus.notSignedIn:
        return LoginRegisterPage(auth: widget.auth, onSignedIn: _signedIn,);
        break;
      case AuthStatus.signedIn:
        return HomePage(auth: widget.auth, onSignedOut: _signOut);
        break;
    }
  }

  void _signedIn() {
    setState(() {
      _authStatus=AuthStatus.signedIn;
    });
  }

  void _signOut() {
    setState(() {
      _authStatus=AuthStatus.notSignedIn;
    });
  }

}