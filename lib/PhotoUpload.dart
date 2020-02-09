import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomePage.dart';

class PhotoUploadPage extends StatefulWidget {
  final String userEmail;
  final HomePageState homePageState;
  PhotoUploadPage(this.userEmail, this.homePageState);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PhotoUploadPageState();
  }
}

class _PhotoUploadPageState extends State<PhotoUploadPage> {
  final formKey=GlobalKey<FormState>();
  File _sampleImage;
  String _description;
  String url;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('上传图片'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: _sampleImage==null?buildPickSelectors():enableUpload(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: (){getImage(source: ImageSource.gallery);},
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget buildPickSelectors() {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          child: Text('选择图片...',style: TextStyle(color: Colors.white),),
          color: Colors.pinkAccent,
          onPressed: (){getImage(source: ImageSource.gallery);},
        ),
        FlatButton(
          child: Text('照相...',style: TextStyle(color: Colors.white),),
          color: Colors.pinkAccent,
          onPressed: (){getImage(source: ImageSource.camera);},
        ),

      ],
    );
  }

  Widget enableUpload() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.file(_sampleImage, height: 330, width: 660,),
          SizedBox(height: 10),
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(labelText: '描述:'),
            validator: (value){
              if(value.isEmpty) {
                return '请添加描述';
              }

              else {
                return null;
              }
            },
            onSaved: (value){
              return _description=value;
            },
          ),
          SizedBox(height: 10,),
          RaisedButton(
            elevation: 10,
            child: Text('发布'),
            textColor: Colors.white,
            color: Colors.pink,
            onPressed: (){validateAndSubmit(context);},
          ),
        ],
      ),
    );
  }

  Future getImage({ImageSource source}) async {
    try {
      var tempImage = await ImagePicker.pickImage(source: source);
      setState(() {
        _sampleImage = tempImage;
      });
    }
    catch(e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  bool validateAndSave(){
    final form=formKey.currentState;
    if(form.validate()){
      form.save();
      return true;
    }
    else {
      return false;
    }
  }

  Future validateAndSubmit(BuildContext context) async {
    if(validateAndSave()) {
      Fluttertoast.showToast(msg: 'Validated and trying to submit');
      Navigator.pop(context);
      try {
        final StorageReference postImageRef=FirebaseStorage.instance.ref().child('Post Images');
        var timeKey=new DateTime.now();
        final StorageUploadTask uploadTask=postImageRef.child(timeKey.toString()+'.jpg').putFile(_sampleImage);
        var imageUrl= await (await uploadTask.onComplete).ref.getDownloadURL();
        url=imageUrl.toString();

        saveToDatabase(url, timeKey);
        widget.homePageState.setState(() { });
      }
      catch(e) {
        Fluttertoast.showToast(msg: '错误: $e.toString()');
      }
    }
  }

  void saveToDatabase(String addr, DateTime dt) {
    try {
      var formatDate = DateFormat('yyyy, MMM d, EEEE');
      var formatTime = DateFormat('hh:mm aaa');
      String date = formatDate.format(dt);
      String time = formatTime.format(dt);

      var data = {
        "image": addr,
        "description": _description,
        "date": date,
        "time": time,
        "ticks": dt.millisecondsSinceEpoch,
        "userEmail": widget.userEmail,
      };



//       DatabaseReference dbRef = FirebaseDatabase.instance.reference();
//       dbRef.push().set(data);

        Firestore.instance.collection('posts').document().setData(data);
     }
    catch(e) {
      Fluttertoast.showToast(msg: 'DBError: $e.toString()');
    }
  }
}