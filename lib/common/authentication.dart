import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './LoadingDialog.dart';
import 'package:provider/provider.dart';
import '../provider/Adopts.dart';
class Authentication extends StatefulWidget {
  final Map arguments;
  Authentication({Key key, this.arguments}) : super(key: key);

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  WebViewController _controller;
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    final counterAdopts = Provider.of<Adopts>(context);
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
               counterAdopts.increment(true);
              // Navigator.pushNamed(context, '/');
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
                      initialUrl: '${widget.arguments['url']}', // 加载的url
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
                                counterAdopts.increment(true);
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
        ));
  }
}
