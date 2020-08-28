import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/config.dart';
import './Storage.dart';
import './LoadingDialog.dart';
import '../provider/Lovecar.dart';
import '../provider/Integral.dart';
import 'package:provider/provider.dart';

class Tokenwebview extends StatefulWidget {
  final Map arguments;
  Tokenwebview({Key key, this.arguments}) : super(key: key);
  @override
  _TokenwebviewState createState() => _TokenwebviewState();
}

class _TokenwebviewState extends State<Tokenwebview> {
  WebViewController _controller;
  String token = '';
  bool isloading = false;
  var item;
  @override
  void initState() {
    super.initState();
    getToken();
    print('${Config.weblink}${widget.arguments['url']}');
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
    } catch (e) {
      setState(() {
        token = '';
      });
    }
  }
   
  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Lovecar>(context);
    final integral = Provider.of<Integral>(context);
    Ui.init(context);
    return Scaffold(
        appBar: PreferredSize(
          child: AppBar(
            elevation: 0,
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          preferredSize: Size.fromHeight(0),
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: WebView(
                      initialUrl:
                          '${Config.weblink}${widget.arguments['url']}', // 加载的 ${Config.weblink}${widget.arguments['url']}
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
                              counter.increment(true);
                              integral.increment(true);
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
        )

        //  Container(
        //   child: Column(
        //     children: <Widget>[
        //       Container(
        //         color: Color(0xFFFFFFFF),
        //         child: isloading
        //             ? null
        //             : Container(
        //                 margin: EdgeInsets.fromLTRB(0, 300, 0, 0),
        //                 child: LoadingDialog(
        //                   text: "加载中…",
        //                 ),
        //               ),
        //       ),
        //       Expanded(
        //           child: WebView(
        //         initialUrl: '${Config.weblink}applotterys', // 加载的url
        //         //JS执行模式 是否允许JS执行
        //         javascriptMode: JavascriptMode.unrestricted,

        //         onWebViewCreated: (controller) {
        //           _controller = controller;
        //         },
        //         onPageFinished: (url) {
        //           _controller
        //               .evaluateJavascript('callJS("${token}")')
        //               .then((result) {
        //             setState(() {
        //               isloading = true;
        //             });
        //             print(result);
        //           });
        //         },

        //         javascriptChannels: <JavascriptChannel>[
        //           //js 调用flutter
        //           JavascriptChannel(
        //               name: "back",
        //               onMessageReceived: (JavascriptMessage message) {
        //                 Navigator.pop(context);
        //               }),
        //         ].toSet(),
        //       )
        //       )
        //     ],
        //   ),
        // )

        );
  }
}
