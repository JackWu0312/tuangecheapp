import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tuangeche/common/Storage.dart';
import '../../ui/ui.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../common/CommonBottomSheet.dart';
import '../../config/config.dart';
import 'package:toast/toast.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';

class Recommend extends StatefulWidget {
  Recommend({Key key}) : super(key: key);

  @override
  _RecommendState createState() => _RecommendState();
}

class _RecommendState extends State<Recommend> {
  StreamSubscription<WeChatShareResponse> _wxshare;
  var url = '';
  bool isloading = false;
  void initState() {
    super.initState();
    getimage();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxshare = fluwx.responseFromShare.listen((data) {});
  }

  void dispose() {
    _wxshare.cancel();
    super.dispose();
  }

  getUserInfo() async {
    try {
      String userInfo = await Storage.getString('userInfo');
      return userInfo;
    } catch (e) {
      return '';
    }
  }

  getimage() async {
    await HttpUtlis.get('/wx/banner/listByPosition/7', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          url = value['data']['url'];
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

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '好友推荐',
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
              // Navigator.popAndPushNamed(context, '/');
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
        body: isloading
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: Ui.width(750),
                      height: double.infinity,
                      padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(90)),
                      child: this.url != ''
                          ? CachedNetworkImage(
                              width: Ui.width(750),
                              height: double.infinity,
                              imageUrl: '${this.url}')

                          // Image.network(
                          //   '${this.url}?x-oss-process=image/resize,p_70',
                          //   fit: BoxFit.fill,
                          // )
                          : Text(''),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: Ui.width(750),
                        height: Ui.width(90),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/myrecom');
                              },
                              child: Container(
                                width: Ui.width(375),
                                height: Ui.width(90),
                                alignment: Alignment.center,
                                color: Color(0xFFFFC92B),
                                child: Text(
                                  '我的推荐',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () async {
                                  showDialog(
                                      barrierDismissible:
                                          true, //是否点击空白区域关闭对话框,默认为true，可以关闭
                                      context: context,
                                      builder: (BuildContext context) {
                                        var list = List();
                                        list.add('发送给微信好友');
                                        list.add('分享到微信朋友圈');
                                        return CommonBottomSheet(
                                          list: list,
                                          onItemClickListener: (index) async {
                                            var inviteCode = json
                                                .decode(await getUserInfo());
                                            print(inviteCode['inviteCode']);
                                            var model = fluwx.WeChatShareWebPageModel(
                                                webPage:
                                                    '${Config.weblink}login/${inviteCode['inviteCode']}',
                                                title: '邀请好友注册',
                                                thumbnail:
                                                    "assets://images/loginnew.png",
                                                scene: index == 0
                                                    ? fluwx.WeChatScene.SESSION
                                                    : fluwx
                                                        .WeChatScene.TIMELINE,
                                                transaction: "团个车");
                                            fluwx.shareToWeChat(model);
                                            Navigator.pop(context);
                                          },
                                        );
                                      });
                                },
                                child: Container(
                                  width: Ui.width(375),
                                  height: Ui.width(90),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFC92B),
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
                                    '马上推荐',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(32.0)),
                                  ),
                                )),
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
              ));
  }
}
