import 'package:flutter/material.dart';

class Adopts with ChangeNotifier {
  bool _integral = false;
  bool get count => _integral;
  void increment(bools) {
    _integral=bools;
    notifyListeners();
  }
}