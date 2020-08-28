import 'package:flutter/material.dart';
import '../ui/ui.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/config.dart';
import './Storage.dart';

class Goodswebview extends StatefulWidget {
  final Map arguments;
  Goodswebview({Key key, this.arguments}) : super(key: key);

  // Goodswebview({Key key}) : super(key: key);

  @override
  _GoodswebviewState createState() => _GoodswebviewState();
}

class _GoodswebviewState extends State<Goodswebview> {
  String link='{Config.weblink}goodsdetail';
  String token;
  @override
  void initState() {
    super.initState();
    // try {
    //   token = await Storage.getString('token');
    //   print('1');
    // } catch (e) {
    //   print('2');
    //   token = '';
    // }
    getToken();
    //print(token);
   
   
  }

  getToken() async {
    // print('object');
    try {
    String  tokens = await Storage.getString('token');
      if(tokens==null){
        setState(() {
          token='token';
        });
      }else{
         setState(() {
          token=tokens;
        });
      }
      // return token;
    } catch (e) {
     setState(() {
          token='token';
        });
    }
     setState(() {
      link = '${Config.weblink}goodsdetail/${widget.arguments['id']}/${token}';
    });
    //  print(link);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        body: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                  child: WebView(
                initialUrl: link, // 加载的url
                //JS执行模式 是否允许JS执行
                javascriptMode: JavascriptMode.unrestricted,
                // onWebViewCreated: (WebViewController web) {
                  // _controller = controller;
                  // webview 创建调用，
                  // print(link);
                  // web.loadUrl(widget.arguments['url']); //此时也可以初始化一个url
                  // web.canGoBack().then((res) {
                  //   print(res); // 是否能返回上一级
                  // });
                  // web.currentUrl().then((url) {
                  //   print(url); // 返回当前url
                  // });
                  // web.canGoForward().then((res) {
                  //   print(res); //是否能前进
                  // });
                // },
                // onPageFinished: (String value) {
                //   // webview 页面加载调用
                // },
              ))
            ],
          ),
        ));
  }
}
