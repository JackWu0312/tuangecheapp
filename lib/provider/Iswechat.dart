import 'package:flutter/material.dart';

class Iswechat with ChangeNotifier {
  String _iswechat = 'login';
  String get count => _iswechat;
  void increment(iswechat) {
    _iswechat=iswechat;
    // notifyListeners();
    notifyListeners();
  }
}
