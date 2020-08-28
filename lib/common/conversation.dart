import 'package:flutter/material.dart';
import './LoadingDialog.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';


class Conversation extends StatefulWidget {
  Conversation({Key key}) : super(key: key);

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
   bool isloading = false;
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '客服',
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
                            'https://kefu.easemob.com/webim/im.html?configId=cb0a2174-4ae9-44dd-8b57-7d9501553cca', // 加载的url
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