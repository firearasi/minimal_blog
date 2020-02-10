import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'authentication.dart';
import 'PhotoUpload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HomePage extends StatefulWidget {
  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  HomePage({this.auth, this.onSignedOut});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  String _email = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initEmail();
  }

  void _initEmail() async {
    widget.auth.getCurrentUserEmail().then((user) {
      setState(() {
        _email = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Home of $_email'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.local_bar),
              iconSize: 30,
              color: Colors.white,
              onPressed: _logoutUser,
            ),
          ],
        ),
        body: Center(
          child: PostList(_email, _refresh),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_a_photo),
          onPressed: () {
            _addNewEntry(context);
          },
          elevation: 10,
        ),
        drawer: buildDrawer());
  }

  Widget buildDrawer() {
    return Drawer(
  // Add a ListView to the drawer. This ensures the user can scroll
  // through the options in the drawer if there isn't enough vertical
  // space to fit everything.
  child: ListView(
    // Important: Remove any padding from the ListView.
    padding: EdgeInsets.zero,
    children: <Widget>[
      SizedBox(
        height: 130,
        child:DrawerHeader(
        child: Row(
          children: <Widget>[
            Image.asset('images/blog.png',fit: BoxFit.cover,),
            SizedBox(width: 30,),
            Text('Minimalist Blog', style: TextStyle(color: Colors.white,fontSize: 20)),
          ],
        ),
        decoration: BoxDecoration(
          color: Colors.pink,
        ),
        
      )
      ),
      ListTile(
        leading: Icon(Icons.view_list),
        title: Text('关注', style: TextStyle(fontSize: 15),),
        onTap: () {
          Navigator.of(context).pop();
        },
      ),
      ListTile(
        leading: Icon(Icons.folder),
        title: Text('收藏', style: TextStyle(fontSize: 15),),
        onTap: () {
          Navigator.of(context).pop();        },
      ),
      
    ],
  ),
);
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
      Fluttertoast.showToast(msg: '已登出');
    } catch (e) {
      Fluttertoast.showToast(msg: '错误: $e.toString()');
    }
  }

  void _addNewEntry(BuildContext context) {
    Fluttertoast.showToast(msg: 'TODO: 添加新日志');
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => PhotoUploadPage(_email)));
  }

  void _refresh() async {
    setState(() {});
  }
}

class PostList extends StatelessWidget {
  final userEmail;
  final VoidCallback refresh;

  PostList(this.userEmail, this.refresh);

  @override
  Widget build(BuildContext context) {
    var sb = StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(this.userEmail)
          .orderBy('ticks', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children: snapshot.data.documents
                  .map((document) => CardForPost(document, context))
                  .toList(),
            );
        }
      },
    );

    return RefreshIndicator(
      child: sb,
      onRefresh: () async {
        return await Future.delayed(Duration(milliseconds: 200), () {
          refresh();
        });
      },
    );
  }

  Card CardForPost(DocumentSnapshot document, BuildContext context) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.only(bottom: 10),
      child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                document['userEmail'],
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    document['date'],
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    document['time'],
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                height: 3,
              ),
              Image.network(
                document['image'],
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    document['description'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                    maxLines: 3,
                  )),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      Alert(
                        context: context,
                        type: AlertType.warning,
                        title: "删除",
                        desc: "您确实要删除此blog吗?",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "确认",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              document.reference.delete();
                              refresh();
                              Navigator.pop(context);
                            },
                            width: 120,
                          ),
                          DialogButton(
                            child: Text(
                              "取消",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          ),
                        ],
                      ).show();
                    },
                  )
                ],
              )
            ],
          )),
    );
  }
}
