import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../config/config.dart';
import '../../common/CommonBottomSheet.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Danshandtail extends StatefulWidget {
  final Map arguments;
  Danshandtail({Key key, this.arguments}) : super(key: key);
  @override
  @override
  _DanshandtailState createState() => _DanshandtailState();
}

class _DanshandtailState extends State<Danshandtail> {
  StreamSubscription<WeChatShareResponse> _wxlogin;
  bool isloading = false;
  var item = {};
  @override
  void initState() {
    super.initState();
    getdata();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxlogin = fluwx.responseFromShare.listen((data) {
      if (data.errCode == 0) {
        getShare();
      }
    });
  }

  void dispose() {
    _wxlogin.cancel();
    super.dispose();
  }

  getShare() {
    HttpUtlis.post("wx/share/callback",
        params: {'dataId': widget.arguments['id'], 'type': 6, 'platform': 1},
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

  getdata() async {
    print(widget.arguments['id']);
    await HttpUtlis.get('wx/promote/show/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          item = value['data'];
        });
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    setState(() {
      this.isloading = true;
    });
  }

  getitemlist() {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var val in item['content']) {
      tiles.add(Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.fromLTRB(0, Ui.width(40), 0, Ui.width(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: Ui.width(9),
                        height: Ui.width(36),
                        color: Color(0xffED3221)),
                    SizedBox(
                      width: Ui.width(21),
                    ),
                    Text(
                      '${val['title']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(32.0)),
                    ),
                  ],
                )),
            Container(
              padding: EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
              child: Html(
                data: '<div>${val['body'].replaceAll('height="', '')}</div>',
              ),
            ),
          ],
        ),
      ));
    }
    content = new Column(children: tiles);
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '晒单详情',
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
                              webPage:
                                  '${Config.weblink}appdrying/${widget.arguments['id']}',
                              title: '',
                              description: '${item['title']}',
                              thumbnail: "assets://images/loginnew.png",
                              scene: index == 0
                                  ? fluwx.WeChatScene.SESSION
                                  : fluwx.WeChatScene.TIMELINE,
                              transaction: "hh");
                          fluwx.shareToWeChat(model);

                          Navigator.pop(context);
                        },
                      );
                    });
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 0, Ui.width(40), 0),
                child: Image.asset('images/2.0x/share.png',
                    width: Ui.width(42), height: Ui.width(42)),
              ))
        ],
      ),
      body: isloading
          ? Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(100)),
                    child: ListView(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(Ui.width(30),
                              Ui.width(26), Ui.width(30), Ui.width(10)),
                          child: Text(
                            '${item['title']}',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(38.0)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(Ui.width(30),
                              Ui.width(0), Ui.width(30), Ui.width(0)),
                          child: Text(
                            '${item['subtitle']}',
                            style: TextStyle(
                                color: Color(0xFFC4C9D3),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(24.0)),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            TalkingDataAppAnalytics.onEvent(
                                eventID: 'cardetail',
                                eventLabel: '汽车详情',
                                params: {"goodsSn": item['goods']['goodsSn']});
                            Navigator.pushNamed(context, '/cardetail',
                                arguments: {
                                  "id": item['goods']['id'],
                                });
                          },
                          child: Container(
                            width: Ui.width(690),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: Ui.width(690),
                                  padding: EdgeInsets.fromLTRB(Ui.width(30),
                                      Ui.width(30), Ui.width(30), 0),
                                  margin: EdgeInsets.fromLTRB(Ui.width(30),
                                      Ui.width(30), Ui.width(30), 0),
                                  constraints: BoxConstraints(
                                    minHeight: Ui.width(270),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.rectangle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0XFFDFE3EC),
                                        offset: Offset(1, 1),
                                        blurRadius: Ui.width(20.0),
                                      ),
                                    ],
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(Ui.width(10.0))),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Stack(
                                          children: <Widget>[
                                            Positioned(
                                                left: 0,
                                                top: Ui.width(3),
                                                child: Container(
                                                  width: Ui.width(116),
                                                  height: Ui.width(36),
                                                  padding: EdgeInsets.fromLTRB(
                                                      Ui.width(5), 0, 0, 0),
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                    image: AssetImage(
                                                        'images/2.0x/paragraph.png'),
                                                    // fit: BoxFit.cover,
                                                  )),
                                                  child: Text(
                                                    '车主同款',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF7F3A1C),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                24.0)),
                                                  ),
                                                )),
                                            Container(
                                              child: Text(
                                                '              ${item['goods']['name']}',
                                                style: TextStyle(
                                                    color: Color(0xFF111F37),
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            32.0)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: Ui.width(188),
                                        // width: Ui.width(690),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0,
                                                              Ui.width(28),
                                                              0,
                                                              0),
                                                      child: RichText(
                                                        textAlign:
                                                            TextAlign.end,
                                                        text: TextSpan(
                                                          text: '惊爆价:',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFED3221),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      26.0)),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text:
                                                                  '${item['goods']['retailPrice']}${item['goods']['unit']}',
                                                              style: TextStyle(
                                                                  fontSize: Ui
                                                                      .setFontSizeSetSp(
                                                                          32.0)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0,
                                                              Ui.width(10),
                                                              0,
                                                              0),
                                                      child: RichText(
                                                        textAlign:
                                                            TextAlign.end,
                                                        text: TextSpan(
                                                          text: '官方指导价:',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF9398A5),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      24.0)),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                                text:
                                                                    '${item['goods']['counterPrice']}${item['goods']['unit']}'),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                                width: Ui.width(250),
                                                height: Ui.width(188),
                                                child: Stack(
                                                  children: <Widget>[
                                                    Container(
                                                      width: Ui.width(250),
                                                      height: Ui.width(188),
                                                      child: CachedNetworkImage(
                                                        width: Ui.width(250),
                                                        height: Ui.width(188),
                                                        fit: BoxFit.fill,
                                                        imageUrl:
                                                            '${item['goods']['picUrl']}',
                                                      ),

                                                      //  AspectRatio(
                                                      //   aspectRatio: 4 / 3,
                                                      //   child: Image.network(
                                                      //     '${item['goods']['picUrl']}',
                                                      //   ),
                                                      // ),
                                                    ),
                                                  ],
                                                ))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(child: getitemlist()),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: InkWell(
                      onTap: () {
                        TalkingDataAppAnalytics.onEvent(
                            eventID: 'cardetail',
                            eventLabel: '汽车详情',
                            params: {"goodsSn": item['goods']['goodsSn']});
                        Navigator.pushNamed(context, '/cardetail', arguments: {
                          "id": item['goods']['id'],
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: Ui.width(750),
                        height: Ui.width(90),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFEA4802),
                              Color(0xFFD10123),
                            ],
                          ),
                        ),
                        child: Text(
                          '查看车型',
                          style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(32.0)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : Container(
              child: LoadingDialog(
                text: "加载中…",
              ),
            ),
    );
  }
}
