import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'authentication.dart';

class LoginRegisterPage extends StatefulWidget {
  final AuthImplementation auth;
  final VoidCallback onSignedIn;
  LoginRegisterPage({this.auth, this.onSignedIn});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginRegisterState();
  }
}

enum FormType {
  login,
  register,
}

class _LoginRegisterState extends State<LoginRegisterPage> {
  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";
  // Methods
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      print('Validated and trying to authenticate');
      try {
        if (_formType == FormType.login) {
          String uid = await widget.auth.signIn(_email, _password);
          Fluttertoast.showToast(msg: '欢迎用户$_email');
        } else {
          String uid = await widget.auth.signUp(_email, _password);
          Fluttertoast.showToast(msg: '欢迎新用户$_email');
        }
        widget.onSignedIn();
      } catch (e) {
        Fluttertoast.showToast(msg: '错误: $e.toString()');
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  // Design
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '极简Blog',
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Container(
            child: Icon(Icons.web),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _createInputs() + _createButtons(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _createInputs() {
    return [
      SizedBox(
        height: 5,
      ),
      _logo(),
      SizedBox(
        height: 5,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: '邮箱'),
        validator: (value) {
          if (value.isEmpty) {
            return '需要邮箱';
          } else if (value.contains('@') == false) {
            return '非法邮箱地址';
          } else {
            return null;
          }
        },
        onSaved: (value) {
          return _email = value;
        },
      ),
      SizedBox(
        height: 5,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: '密码'),
        obscureText: true,
        validator: (value) {
          if (value.isEmpty) {
            return '需要密码';
          } else {
            return null;
          }
        },
        onSaved: (value) {
          return _password = value;
        },
      ),
      SizedBox(
        height: 10,
      ),
    ];
  }

  Widget _logo() {
    return Hero(
        tag: 'Avatar',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 100,
          child: Image.asset('images/blog.png'),
        ));
  }

  List<Widget> _createButtons() {
    if (_formType == FormType.login) {
      return [
        RaisedButton(
          child: Text(
            '登入',
            style: TextStyle(fontSize: 20.0),
          ),
          textColor: Colors.white,
          color: Colors.pink,
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text(
            '没有账号?创建新账号...',
            style: TextStyle(fontSize: 14.0),
          ),
          textColor: Colors.red,
          color: Colors.white,
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return [
        RaisedButton(
          child: Text(
            '注册',
            style: TextStyle(fontSize: 20.0),
          ),
          textColor: Colors.white,
          color: Colors.pink,
          onPressed: validateAndSubmit,
        ),
        FlatButton(
          child: Text(
            '已有账号?登录...',
            style: TextStyle(fontSize: 14.0),
          ),
          textColor: Colors.red,
          color: Colors.white,
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
