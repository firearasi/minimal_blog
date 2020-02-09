import 'package:flutter/material.dart';

import 'mapping.dart';
import 'authentication.dart';
void main() => runApp(BlogApp());

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: '极简blog',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MappingPage(auth: Auth(),),
    );
  }
}