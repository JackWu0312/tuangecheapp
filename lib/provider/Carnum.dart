import 'package:flutter/material.dart';

class Carnum with ChangeNotifier {
  int _num = 0;
  int get count => _num;
  void increment(index) {
    _num=index;
    notifyListeners();
  }
}