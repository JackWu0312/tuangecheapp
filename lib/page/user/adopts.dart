import 'package:flutter/material.dart';
import 'package:flutter_tuangeche/ui/ui.dart';

class Adopt extends StatefulWidget {
  final Map arguments;
  Adopt({Key key, this.arguments}) : super(key: key);
  @override
  _AdoptState createState() => _AdoptState();
}

class _AdoptState extends State<Adopt> {
  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '实名验证',
            style: TextStyle(
                color: Color(0xFF111F37),
                fontWeight: FontWeight.w500,
                fontFamily: 'PingFangSC-Medium,PingFang SC',
                fontSize: Ui.setFontSizeSetSp(36.0)),
          ),
          centerTitle: true,
          elevation: 0,
          brightness: Brightness.light,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.asset(
                'images/2.0x/back.png',
                width: Ui.width(21),
                height: Ui.width(37),
              ),
            ),
          ),
        ),
        body: Container(
          padding:
              EdgeInsets.fromLTRB(Ui.width(30), Ui.width(30), Ui.width(30), 0),
          color: Color(0xFFFBFCFF),
          child: Container(
            width: Ui.width(690),
            height: Ui.width(230),
            decoration: BoxDecoration(
              color: Color(0XFFFFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(Ui.width(20.0))),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: Ui.width(690),
                  height: Ui.width(110),
                    padding: EdgeInsets.fromLTRB(Ui.width(20), 0, Ui.width(20), 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '真实姓名',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(30.0)),
                      ),
                      Text(
                       '${widget.arguments['realname']}',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize:  Ui.setFontSizeSetSp(30.0)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Ui.width(690),
                  height: Ui.width(110),
                  padding: EdgeInsets.fromLTRB(Ui.width(20), 0, Ui.width(20), 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '证件号码',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(30.0)),
                      ),
                      Text(
                      '${widget.arguments['idcard']}',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(30.0)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
