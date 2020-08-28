import 'dart:async';

import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class Loan extends StatefulWidget {
  Loan({Key key}) : super(key: key);

  @override
  _LoanState createState() => _LoanState();
}

class _LoanState extends State<Loan> {
  // StreamSubscription<WeChatShareResponse>   launchWeChat;
  @override
  void initState() {
    super.initState();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    
    //   launchWeChat = fluwx.weChatResponseEventHandler.listen((res) {
    //   if (res is WeChatLaunchMiniProgramResponse) {
    //     if (mounted) {}
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '分期2年0利息',
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
          child: Stack(
            children: <Widget>[
              Container(
                child: ListView(
                  children: <Widget>[
                    Image.asset(
                      'images/2.0x/loan.png',
                      width: Ui.width(750),
                    ),
                  ],
                ),
              ),
              Positioned(
                  right: Ui.width(20),
                  bottom: Ui.width(200),
                  child: InkWell(
                    onTap: () {
                      launchWeChatMiniProgram(
                        username: "gh_f4cb18f84e5f",
                        path: '/pages/index/index?inviteCode=',
                      );
                    },
                    child: Container(
                      width: Ui.width(200),
                      height: Ui.width(200),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Ui.width(200)),
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('images/2.0x/eqore.png'))),
                    ),
                  ))
            ],
          ),
        ));
  }
}
