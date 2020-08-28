import 'dart:async';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';

class Modifyname extends StatefulWidget {
  Modifyname({Key key}) : super(key: key);

  @override
  _ModifynameState createState() => _ModifynameState();
}

class _ModifynameState extends State<Modifyname> {
   var _initKeywordsController = new TextEditingController();
  Timer timer;
  String username = '';
  submit() {
    HttpUtlis.post("wx/user/update", params: {'username': username},
        success: (value) async {
      if (value['errno'] == 0) {
        Toast.show('修改成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        timer = new Timer(new Duration(seconds: 1), () {
          Navigator.pop(context);
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
                '修改昵称',
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
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(32)),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '请输入昵称',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Helvetica;',
                                      fontSize: Ui.setFontSizeSetSp(28.0))),
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  username = '';
                                });
                                this._initKeywordsController.text='';
                              },
                              child: Container(
                                width: Ui.width(28),
                                height: Ui.width(28),
                                child: Image.asset('images/2.0x/close.png'),
                              ))
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
                          '保存',
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
