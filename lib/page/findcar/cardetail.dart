import 'dart:async';

import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../common/Storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../config/config.dart';
import '../../common/CommonBottomSheet.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Cardetail extends StatefulWidget {
  final Map arguments;
  Cardetail({Key key, this.arguments}) : super(key: key);
  @override
  _CardetailState createState() => _CardetailState();
}

class _CardetailState extends State<Cardetail> {
  StreamSubscription<WeChatShareResponse> _wxlogin;

  bool isloading = false;
  var item = {};
  List list = [];
  Widget borderwidth(height) {
    return Container(
      width: double.infinity,
      height: Ui.height(height),
      color: Color(0XFFF8F9FB),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TalkingDataAppAnalytics.onPageStart('汽车详情'); //埋点使用
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

  getinfodata() async {
    await HttpUtlis.get('wx/user/detail', success: (value) {
      print(value['data']);
      if (value['errno'] == 0) {
        if (value['data']['mobile'] != null &&value['data']['realname'] != null && value['data']['idcard'] != null) {
            Navigator.pushNamed(context, '/carorder', arguments: {
                "id": widget.arguments['id'],
                "realname":value['data']['realname'],
                "mobile":value['data']['mobile']
              });
        } else {
          Toast.show('请先进行实名验证～', context,
              backgroundColor: Color(0xff5b5956),
              backgroundRadius: Ui.width(16),
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.CENTER);
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushNamed(context, '/info');
          });
        }

        // setState(() {
        //   item = value['data'];
        // });
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  void dispose() {
    _wxlogin.cancel();
    TalkingDataAppAnalytics.onPageEnd('汽车详情');
    super.dispose();
  }

  getShare() {
    HttpUtlis.post("wx/share/callback",
        params: {'dataId': widget.arguments['id'], 'type': 2, 'platform': 1},
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
    await HttpUtlis.get('wx/goods/detail?id=${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        if (value['data']['info']['gallery'].length == 0) {
          value['data']['info']['gallery'] = [value['data']['info']['picUrl']];
        }
        // print(value['data']['info']['brief']=='');
        setState(() {
          item = value['data'];
          list = item['info']['gallery'][0]['images'];
          // brandGroups = value['data'];
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
    for (var items in item['baseAttr']['children']) {
      tiles.add(Container(
        // height: Ui.width(90),
        constraints: BoxConstraints(
          minHeight: Ui.width(90),
        ),
        padding: EdgeInsets.fromLTRB(0, Ui.width(20), 0, Ui.width(20)),
        width: Ui.width(670),
        // alignment: Alignment.center,
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(width: 1, color: Color(0xffEAEAEA)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: Ui.width(400),
              child: Text(
                '${items['label']}',
                style: TextStyle(
                    color: Color(0xFF111F37),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                    fontSize: Ui.setFontSizeSetSp(30.0)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  items['value'] == null ? '' : '${items['value']}',
                  style: TextStyle(
                      color: Color(0xFF9398A5),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'PingFangSC-Medium,PingFang SC',
                      fontSize: Ui.setFontSizeSetSp(28.0)),
                ),
              ),
            )
          ],
        ),
      ));
    }
    content = new Column(children: tiles);
    return content;
  }

  getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    showtosh() {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                  width: Ui.width(600),
                  height: Ui.width(300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.all(Radius.circular(Ui.width(20.0))),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: Ui.width(600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: Ui.width(30),
                            ),
                            Text('温馨提示',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(36.0))),
                            SizedBox(
                              height: Ui.width(40),
                            ),
                            Text('当前还未登陆，请登录～',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0))),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: Ui.width(600),
                          height: Ui.width(92),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(
                                                  Ui.width(20)))),
                                      alignment: Alignment.center,
                                      child: Text('取消',
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Color(0xFF3895FF),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(36.0))),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: Ui.width(2),
                                            color: Color(0xffEAEAEA)),
                                        right: BorderSide(
                                            width: Ui.width(2),
                                            color: Color(0xffEAEAEA))),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.popAndPushNamed(
                                            context, '/login');
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    Ui.width(20)))),
                                        child: Text('去登陆',
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Color(0xFF3895FF),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(36.0))),
                                      )),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: Ui.width(2),
                                            color: Color(0xffEAEAEA))),
                                  ),
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(Ui.width(20))),
                          ),
                        ),
                      )
                    ],
                  )),
            );
          });
    }

    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '车辆详情',
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
                                  '${Config.weblink}appcardetail/${widget.arguments['id']}',
                              title: '',
                              description: '${item['info']['name']}',
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
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: ListView(
                      children: <Widget>[
                        Container(
                            width: Ui.width(750),
                            // height: Ui.width(400),
                            alignment: Alignment.center,
                            child: Stack(
                              children: <Widget>[
                                AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: Swiper(
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () {
                                            print(item['info']['id']);
                                            Navigator.pushNamed(
                                                context, '/easywebview',
                                                arguments: {
                                                  'url':
                                                      'appimage/${item['info']['id']}'
                                                });
                                          },
                                          child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: '${list[index]}'),
                                          // Image.network(
                                          //   '${list[index]}',
                                          //   fit: BoxFit.fill,
                                          // ),
                                        );
                                      },
                                      itemCount: list.length,
                                      autoplay: list.length > 1 ? true : false,
                                    )),
                                Positioned(
                                    bottom: item['info']['brief'] == ''
                                        ? Ui.width(20)
                                        : Ui.width(110),
                                    left: Ui.width(315),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/easywebview',
                                            arguments: {
                                              'url':
                                                  'appimage/${item['info']['id']}'
                                            });
                                      },
                                      child: Container(
                                        height: Ui.width(40),
                                        width: Ui.width(120),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: Color(0xFF6D6D6D)),
                                        child: Text(
                                          '查看更多',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(22.0)),
                                        ),
                                      ),
                                    )),
                                Positioned(
                                  left: 0,
                                  bottom: 0,
                                  child: item['info']['brief'] == ''
                                      ? SizedBox()
                                      : Container(
                                          width: Ui.width(750),
                                          height: Ui.width(95),
                                          padding: EdgeInsets.fromLTRB(
                                              Ui.width(40), 0, 0, 0),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'images/2.0x/assemble.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item['info']['brief'] == ''
                                                ? '暂无拼团活动'
                                                : '${item['info']['brief']}',
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(32.0)),
                                          )),
                                )
                              ],
                            )),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              0, Ui.width(20), 0, Ui.width(30)),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          // decoration: BoxDecoration(
                          //     border: Border(
                          //         bottom: BorderSide(
                          //             width: 1, color: Color(0xffEAEAEA)))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  child: Text(
                                '${item['info']['name']}',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(40.0)),
                              )),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(
                                        text: '${item['info']['retailPrice']}',
                                        style: TextStyle(
                                            color: Color(0xFFD10123),
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(40.0)),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: ' ${item['info']['unit']}',
                                            style: TextStyle(
                                                color: Color(0xFFD10123),
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(26.0)),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: Ui.width(10),
                                    ),
                                    Container(
                                      width: Ui.width(128),
                                      height: Ui.width(34),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: Ui.width(1),
                                            color: Color(0xffD10123)),
                                      ),
                                      child: Text(
                                        '小团集采价',
                                        style: TextStyle(
                                            color: Color(0xFFD10123),
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(22.0)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: Ui.width(22),
                                    ),
                                    RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(
                                        text: '官方指导价：',
                                        style: TextStyle(
                                            color: Color(0xFF9398A5),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(24.0)),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '${item['info']['counterPrice']}${item['info']['unit']}',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/secondhand');
                          },
                          child: Container(
                            //secondhand
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(40), 0, Ui.width(40), Ui.width(20)),
                            height: Ui.width(74),
                            width: Ui.width(680),
                            decoration: BoxDecoration(
                              color: Color(0XFFF5F5F5),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(Ui.width(5.0))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      Ui.width(20), 0, 0, 0),
                                  child: Text(
                                    '以旧换新   便捷购新车',
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0, 0, Ui.width(20), 0),
                                  child: Image.asset('images/2.0x/rightnew.png',
                                      width: Ui.width(30),
                                      height: Ui.width(30)),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/loanwebview');
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(40), 0, Ui.width(40), Ui.width(36)),
                            height: Ui.width(74),
                            width: Ui.width(680),
                            decoration: BoxDecoration(
                              color: Color(0XFFF5F5F5),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(Ui.width(5.0))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      Ui.width(20), 0, 0, 0),
                                  child: Text(
                                    '分期2年0利息',
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      0, 0, Ui.width(20), 0),
                                  child: Image.asset('images/2.0x/rightnew.png',
                                      width: Ui.width(30),
                                      height: Ui.width(30)),
                                )
                              ],
                            ),
                          ),
                        ),
                        // Container(
                        //   height: Ui.width(80),
                        //   alignment: Alignment.centerLeft,
                        //   padding: EdgeInsets.fromLTRB(Ui.width(40), 0, 0, 0),
                        //   child: Text(
                        //     '车源：${item['category']['name']}',
                        //     style: TextStyle(
                        //         color: Color(0xFF9398A5),
                        //         fontWeight: FontWeight.w500,
                        //         fontFamily: 'PingFangSC-Medium,PingFang SC',
                        //         fontSize: Ui.setFontSizeSetSp(24.0)),
                        //   ),
                        // ),
                        borderwidth(16.0),
                        Container(
                          padding: EdgeInsets.fromLTRB(Ui.width(40),
                              Ui.width(50), Ui.width(40), Ui.width(20)),
                          child: Text(
                            '车源配置',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(42.0)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: getitemlist(),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, '/easywebview', arguments: {
                              'url': 'appallocation/${widget.arguments['id']}'
                            });
                          },
                          child: Container(
                              width: Ui.width(670),
                              height: Ui.width(90),
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(40), Ui.width(20), Ui.width(40), 0),
                              decoration: BoxDecoration(
                                color: Color(0xFFEAEAEA),
                              ),
                              child: Text(
                                '查看更多',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(32.0)),
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(Ui.width(40),
                              Ui.width(50), Ui.width(40), Ui.width(20)),
                          child: Text(
                            '车源详情',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(42.0)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          // color: Colors.red,
                          child: Html(
                            data:
                                '<div>${item['info']['detail'].replaceAll('height="', '')}</div>',
                          ),
                        ),
                        SizedBox(
                          height: Ui.width(100),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      height: Ui.width(90),
                      // color: Colors.red,
                      width: Ui.width(750),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () async {
                              Navigator.pushNamed(context, '/conversation',);
                              // var tel = await Storage.getString('phone');
                              // var url = 'tel:${tel.replaceAll(' ', '')}';
                              // if (await canLaunch(url)) {
                              //   await launch(url);
                              // } else {
                              //   throw '拨打失败';
                              // }
                            },
                            child: Container(
                              width: Ui.width(220),
                              height: Ui.width(90),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('images/2.0x/call.png',
                                      width: Ui.width(45),
                                      height: Ui.width(45)),
                                  SizedBox(
                                    width: Ui.width(25),
                                  ),
                                  Text(
                                    '客服',
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: () async {
                                  if (await getToken() != null) {
                                   
                                      getinfodata();
                                  } else {
                                    showtosh();
                                  }
                                },
                                child: Container(
                                  height: Ui.width(90),
                                  alignment: Alignment.center,
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
                                    '确认下单',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(32.0)),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          : Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: LoadingDialog(
                text: "加载中…",
              ),
            ),
    );
  }
}
