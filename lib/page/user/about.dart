/*
 * @Descripttion: 
 * @version: 
 * @Author: sueRimn
 * @Date: 2020-08-25 15:07:23
 * @LastEditors: sueRimn
 * @LastEditTime: 2020-08-25 15:48:06
 */
import 'package:flutter/material.dart';
import 'package:flutter_tuangeche/ui/ui.dart';

class About extends StatefulWidget {
  About({Key key}) : super(key: key);
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '关于我们',
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
            width: double.infinity,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.fromLTRB(0, Ui.width(110), 0, Ui.width(90)),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'images/2.0x/loginAbout.png',
                        width: Ui.width(150),
                        height: Ui.width(115),
                      ),
                      SizedBox(
                        height: Ui.width(40),
                      ),
                      Text(
                        '版本V3.2.1',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(30.0)),
                      ),
                      SizedBox(
                        height: Ui.width(20),
                      ),
                      Text(
                        '团个车 版本所有',
                        style: TextStyle(
                            color: Color(0xFF9398A5),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: Ui.width(16),
                  color: Color(0xFFF8F9FB),
                ),
                Container(
                  padding:
                      EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: Ui.width(110),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffEAEAEA)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '功能介绍',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                            Image.asset(
                              'images/2.0x/rightmy.png',
                              width: Ui.width(12),
                              height: Ui.width(22),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: Ui.width(110),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffEAEAEA)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '法律声明',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                            Image.asset(
                              'images/2.0x/rightmy.png',
                              width: Ui.width(12),
                              height: Ui.width(22),
                            ),
                          ],
                        ),
                      ),
                       Container(
                        height: Ui.width(110),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffEAEAEA)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '隐私政策',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                            Image.asset(
                              'images/2.0x/rightmy.png',
                              width: Ui.width(12),
                              height: Ui.width(22),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: Ui.width(110),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffEAEAEA)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '营业执照',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                            Image.asset(
                              'images/2.0x/rightmy.png',
                              width: Ui.width(12),
                              height: Ui.width(22),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )));
  }
}
