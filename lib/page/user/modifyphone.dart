import 'dart:async';

import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
class Modifyphone extends StatefulWidget {
  Modifyphone({Key key}) : super(key: key);

  @override
  _ModifyphoneState createState() => _ModifyphoneState();
}

class _ModifyphoneState extends State<Modifyphone> {
  var _initKeywordsController = new TextEditingController();
  Timer timer;
  String _text = '获取验证码';
  Timer _countdownTimer;
  int _countdownNum = 180;
  String mobile = '';
  String code = '';
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    timer?.cancel();
    timer = null;
    super.dispose();
    // _result = null;
  }

  submit() {
    HttpUtlis.post("wx/auth/bindMobile",
        params: {'mobile': mobile, 'code': code}, success: (value) async {
      if (value['errno'] == 0) {
        Toast.show('验证成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        timer = new Timer(new Duration(seconds: 1), () {
          Navigator.pushNamed(context, '/',arguments: {
            'mobile':mobile
          });
        });
        // Navigator.pop(context);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getCode() async {
    Toast.show("发送成功～", context,
        backgroundColor: Color(0xff5b5956),
        backgroundRadius: Ui.width(16),
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.CENTER);
    HttpUtlis.post("wx/auth/captcha", params: {'mobile': mobile},
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          if (_countdownTimer != null) {
            return;
          }
          // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
          _text = '${_countdownNum--}S 重新获取';
          _countdownTimer =
              new Timer.periodic(new Duration(seconds: 1), (timer) {
            setState(() {
              if (_countdownNum > 0) {
                _text = '${_countdownNum--}S 重新获取';
              } else {
                _text = '获取验证码';
                _countdownNum = 180;
                _countdownTimer.cancel();
                _countdownTimer = null;
              }
            });
          });
        });
      } else {
        Navigator.pushNamed(context, '/');
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                '修改手机号',
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
            onTap: (){
               Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.asset('images/2.0x/back.png',width: Ui.width(21),height: Ui.width(37),),
            ),
          ),
            ),
            body: Container(
              color: Colors.white,
              child: Container(
                child: ListView(
                  children: <Widget>[
                    Container(
                      width: Ui.width(670),
                      height: Ui.width(120),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Color(0xffEAEAEA)))),
                      margin:
                          EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: TextField(
                              autofocus: false,
                              controller: _initKeywordsController,
                              // textInputAction: TextInputAction.none,
                              keyboardAppearance: Brightness.light,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(32)),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '请输入手机号码',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Helvetica;',
                                      fontSize: Ui.setFontSizeSetSp(28.0))),
                              onChanged: (value) {
                                setState(() {
                                  mobile = value;
                                });
                              },
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  mobile = '';
                                });
                                this._initKeywordsController.text = '';
                              },
                              child: Container(
                                width: Ui.width(28),
                                height: Ui.width(28),
                                child: Image.asset('images/2.0x/close.png'),
                              ))
                        ],
                      ),
                    ),
                    Container(
                      width: Ui.width(670),
                      height: Ui.width(120),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1, color: Color(0xffEAEAEA)))),
                      margin:
                          EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: TextField(
                              autofocus: false,
                              keyboardAppearance: Brightness.light,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(32)),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '请输入验证码',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Helvetica;',
                                      fontSize: Ui.setFontSizeSetSp(28.0))),
                              onChanged: (value) {
                                setState(() {
                                  code = value;
                                });
                              },
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (!RegExp(
                                      r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
                                  .hasMatch(mobile)) {
                                Toast.show("请输入正确的手机号码", context,
                                    backgroundColor: Color(0xff5b5956),
                                    backgroundRadius: Ui.width(16),
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.CENTER);
                                return;
                              }
                              getCode();
                            },
                            child: Container(
                              // padding: EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                              child: Text('${_text}',
                                  style: TextStyle(
                                      color: Color(0xFFD10123),
                                      fontSize: Ui.setFontSizeSetSp(32),
                                      fontFamily:
                                          'PingFangSC-Regular,PingFang SC')),
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        submit();
                      },
                      child: Container(
                        width: Ui.width(670),
                        height: Ui.width(80),
                        margin: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(70), Ui.width(40), 0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Color(0xFFD10123),
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(Ui.width(6.0))),
                        ),
                        child: Text(
                          '验证',
                          style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
