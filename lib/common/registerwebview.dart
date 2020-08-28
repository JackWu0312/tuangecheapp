import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/config.dart';
import './Storage.dart';
import './LoadingDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; //提供Platform接口
import '../provider/Lovecar.dart';
import 'package:provider/provider.dart';

class Registerwebview extends StatefulWidget {
  final Map arguments;
  Registerwebview({Key key, this.arguments}) : super(key: key);
  @override
  _RegisterwebviewState createState() => _RegisterwebviewState();
}

class _RegisterwebviewState extends State<Registerwebview> {
  WebViewController _controller;
  String token = '';
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    getToken();
  }

  getToken() async {
    try {
      String tokens = await Storage.getString('token');
      if (tokens == null) {
        setState(() {
          token = '';
        });
      } else {
        setState(() {
          token = tokens;
        });
      }
      // return token;
    } catch (e) {
      setState(() {
        token = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Lovecar>(context);
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '注册经纪人',
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
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: WebView(
                      initialUrl:
                          ' ${Config.weblink}${widget.arguments['url']}', // 加载的 ${Config.weblink}${widget.arguments['url']}
                      //JS执行模式 是否允许JS执行
                      javascriptMode: JavascriptMode.unrestricted,

                      onWebViewCreated: (controller) {
                        _controller = controller;
                      },
                      onPageFinished: (url) {
                        _controller
                            .evaluateJavascript('callJS("${token}")')
                            .then((result) {
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
                              Navigator.pop(context);
                            }),
                        JavascriptChannel(
                            name: "app",
                            onMessageReceived:
                                (JavascriptMessage message) async {
                              counter.increment(true);
                              var url = '';
                              if (Platform.isAndroid) {
                                url = 'http://fir.tuangeche.com.cn/l1s5';
                              }
                              if (Platform.isIOS) {
                                url =
                                    'https://itunes.apple.com/cn/app/1482599438';
                              }
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
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
        ));
  }
}
