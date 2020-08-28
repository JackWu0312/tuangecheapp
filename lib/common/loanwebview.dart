import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/config.dart';
import './LoadingDialog.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'dart:async';
import './CommonBottomSheet.dart';
class Loanwebview extends StatefulWidget {
  final Map arguments;
  Loanwebview({Key key, this.arguments}) : super(key: key);

  @override
  _LoanwebviewState createState() => _LoanwebviewState();
}

class _LoanwebviewState extends State<Loanwebview> {
  WebViewController _controller;
  bool isloading = false;
  StreamSubscription<WeChatShareResponse> _wxlogin;
  void initState() {
    super.initState();
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
        actions: <Widget>[
           
          InkWell(
              onTap: () async {
                  showDialog(
                    barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
                    context: context,
                    builder: (BuildContext context) {
                      var list = List();
                      list.add('发送给微信好友');
                      list.add('分享到微信朋友圈');
                      return CommonBottomSheet(
                        list: list,
                        onItemClickListener: (index) async {
                          var model = fluwx.WeChatShareWebPageModel(
                              webPage:'${Config.weblink}apploan',
                              title: '你买车我贴息',
                              description: '分期2年0利息',
                              thumbnail: "assets://images/loginnew.png",
                              scene: index == 0
                                  ? fluwx.WeChatScene.SESSION
                                  : fluwx.WeChatScene.TIMELINE,
                              transaction: "hh");
                          fluwx.shareToWeChat(model);
                        },
                      );
                    });

                // var model = fluwx.WeChatShareWebPageModel(
                //     webPage: '${Config.weblink}apploan',
                //     title: '分期2年0利息',
                //     thumbnail: "assets://images/loginnew.png",
                //     scene: fluwx.WeChatScene.SESSION,
                //     transaction: "hh");
                // fluwx.shareToWeChat(model);
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
                        initialUrl: '${Config.weblink}apploan', // 加载的url
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
                        javascriptChannels: <JavascriptChannel>[].toSet(),
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
