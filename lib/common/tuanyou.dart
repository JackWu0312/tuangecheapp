import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './LoadingDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:toast/toast.dart';

class Tuanyou extends StatefulWidget {
  final Map arguments;
  Tuanyou({Key key, this.arguments}) : super(key: key);

  // Tuanyou({Key key}) : super(key: key);

  @override
  _TuanyouState createState() => _TuanyouState();
}

class _TuanyouState extends State<Tuanyou> {
  var urls = '';
  var maps = '';
  @override
  void initState() {
    super.initState();
    geturl();

    // print(widget.arguments['url'])
  }

  geturl() {
    setState(() {
      urls ='https://open.czb365.com/redirection/todo?platformType=98637607&platformCode=${widget.arguments['mobile']}&latitude=${widget.arguments['latitude']}&longitude=${widget.arguments['longitude']}';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  WebViewController _controller;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '一键加油',
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
                      initialUrl: urls, // 加载的url
                      //JS执行模式 是否允许JS执行
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (controller) {
                        _controller = controller;
                        
                      },
                      onPageFinished: (urlss) {
                        if (Platform.isAndroid) {
                          if (urlss.startsWith('https://wx.tenpay.com')) {
                            _controller.loadUrl("${urlss}", headers: {
                              "Referer": "https://msdev.czb365.com/pay",
                            });
                          }
                        }
                        _controller.evaluateJavascript("").then((result) {
                          setState(() {
                            isloading = true;
                          });
                        });
                      },
                      navigationDelegate: (NavigationRequest request) async {
                        if (Platform.isAndroid) {
                          if (urls != request.url) {
                            _controller.loadUrl("${request.url}", headers: {
                              "Referer": "https://msdev.czb365.com/pay",
                            });
                            setState(() {
                              urls = request.url;
                            });
                          }
                          //  if (request.url.startsWith('https://wx.tenpay.com')) {
                          //   _controller.loadUrl("${request.url}", headers: {
                          //     "Referer": "https://msdev.czb365.com/pay",
                          //   });
                          //   //  _controller.goBack();
                          // }
                          if (request.url.startsWith("https://m.amap.com")) {
                            setState(() {
                              maps = request.url;
                            });
                          }
                        }

                        if (request.url.startsWith("weixin://") ||
                            request.url.startsWith("iosamap://") ||
                            request.url.startsWith("androidamap://")) {
                          if (request.url.startsWith("weixin://")) {
                            _controller.goBack();
                          }
                          var url = request.url;
                          print(await canLaunch(url));
                          if (await canLaunch(url)) {
                            if (request.url.startsWith("androidamap://")) {
                               if (Platform.isAndroid) {
                                  _controller.goBack();
                               }
                            }
                            await launch(url);
                          } else {
                            if (request.url.startsWith("androidamap://")) {
                               if (Platform.isAndroid) {
                                  _controller.goBack();
                                  launch(maps);
                               }
                            } else {
                              if(request.url.startsWith("weixin://")){
                                Toast.show('请安装微信', context,
                                  backgroundColor: Color(0xff5b5956),
                                  backgroundRadius: Ui.width(16),
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.CENTER);
                              }
                            }
                          }
                          return NavigationDecision.prevent;
                        }
                        if (request.url.startsWith("alipay")) {
                          if (Platform.isAndroid) {
                            _controller.goBack();
                          }
                          var url = request.url;
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            if(request.url.startsWith("alipay")){
                               Toast.show('请安装支付宝', context,
                                  backgroundColor: Color(0xff5b5956),
                                  backgroundRadius: Ui.width(16),
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.CENTER);
                            }
                          }
                          return NavigationDecision.prevent;
                        }
                        return NavigationDecision.navigate;
                      },
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
