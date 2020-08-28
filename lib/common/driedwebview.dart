import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/config.dart';
import './LoadingDialog.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../http/index.dart';
import 'package:toast/toast.dart';

class Driedwebview extends StatefulWidget {
  final Map arguments;
  Driedwebview({Key key, this.arguments}) : super(key: key);
  @override
  _DriedwebviewState createState() => _DriedwebviewState();
}

class _DriedwebviewState extends State<Driedwebview> {
  WebViewController _controller;
  bool isloading = false;
  StreamSubscription<WeChatShareResponse> _wxlogin;
  void initState() {
    super.initState();
    print('${Config.weblink}appdried/${widget.arguments['id']}');

    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxlogin = fluwx.responseFromShare.listen((data) {
      print(data.toString());
    });
  }

  void dispose() {
    _wxlogin.cancel();
    super.dispose();
  }

  getShare() {
    HttpUtlis.post("wx/share/callback", params: {'dataId':widget.arguments['id'],'type': 4, 'platform': 1},
        success: (value) async {
      if (value['errno'] == 0) {
        print('分享成功～');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '干货详情',
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
        actions: <Widget>[
          InkWell(
              onTap: () async {
                var model = fluwx.WeChatShareWebPageModel(
                    webPage:
                        '${Config.weblink}appdried/${widget.arguments['id']}/2',
                    title: '汽车资讯',
                    thumbnail: "assets://images/loginnew.png",
                    scene: fluwx.WeChatScene.SESSION,
                    transaction: "hh");
                fluwx.shareToWeChat(model);
                getShare();
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 0, Ui.width(40), 0),
                child: Image.asset('images/2.0x/share.png',
                    width: Ui.width(42), height: Ui.width(42)),
              ))
        ],
      ),
      body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(
                bottom:
                    BorderSide(color: Color(0XFFFFFFFF), width: Ui.width(0))),
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Expanded(
                      flex: 1,
                      child: WebView(
                        initialUrl:
                            '${Config.weblink}appdried/${widget.arguments['id']}/1', // 加载的url
                        //JS执行模式 是否允许JS执行
                        javascriptMode: JavascriptMode.unrestricted,

                        onWebViewCreated: (controller) {
                          _controller = controller;
                        },
                        onPageFinished: (url) {
                          _controller.evaluateJavascript('').then((result) {
                            setState(() {
                              isloading = true;
                            });
                          });
                        },
                        javascriptChannels: <JavascriptChannel>[
                          //js 调用flutter
                          JavascriptChannel(
                              name: "back",
                              onMessageReceived: (JavascriptMessage message) {
                                // print("参数： ${message.message}");
                                Navigator.pop(context);
                              }),
                        ].toSet(),
                      ))
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  child: isloading
                      ? null
                      : Container(
                          height: MediaQuery.of(context).size.height,
                          width: Ui.width(750),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Color(0XFFFFFFFF), width: 0.0),
                                bottom: BorderSide(
                                    color: Color(0XFFFFFFFF), width: 0.0)),
                          ),
                          child: LoadingDialog(
                            text: "加载中…",
                          ),
                        ),
                ),
              ),
            ],
          )),
    );
  }
}
