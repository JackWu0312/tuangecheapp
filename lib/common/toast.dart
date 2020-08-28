import 'package:toast/toast.dart';
import 'package:flutter/material.dart';
import '../ui/ui.dart';
class Toasts extends StatelessWidget {
  final String text;

  const Toasts({Key key, @required this.text,}) : super(key: key);
      //  return  Toast.show("数量不能低于1哦～", context,backgroundColor:Color(0xff5b5956), backgroundRadius:Ui.width(8),duration: Toast.LENGTH_SHORT, gravity:  Toast.CENTER);

   Widget build(BuildContext context) {
    Ui.init(context);
    return null;
  }

}