import 'package:flutter/material.dart';

class IsInfo with ChangeNotifier {
  bool _info = false;
  bool get count => _info;
  void increment(bools) {
    _info=bools;
    // notifyListeners();
    notifyListeners();
  }
}
