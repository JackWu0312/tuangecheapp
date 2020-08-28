import 'package:flutter/material.dart';
import './test.dart';
class IndexDart extends StatefulWidget {
  IndexDart({Key key}) : super(key: key);

  @override
  _IndexDartState createState() => _IndexDartState();
}

class _IndexDartState extends State<IndexDart> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text('data'),
    );
  }
}