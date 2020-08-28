import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/Storage.dart';
import '../../common/LoadingDialog.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../config/config.dart';
import '../../common/CommonBottomSheet.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Special extends StatefulWidget {
  final Map arguments;
  Special({Key key, this.arguments}) : super(key: key);
  @override
  _SpecialState createState() => _SpecialState();
}

class _SpecialState extends State<Special> {
  ScrollController _scrollController = new ScrollController();
  var bacolor;
  List list = [];
  int page = 1;
  int limit = 10;
  bool nolist = true;
  bool isMore = true;
  var data;
  var str = '';
  var phone;
  bool isloading = false;
  StreamSubscription<WeChatShareResponse> _wxlogin;
  @override
  void initState() {
    // query ids=1177046072513425410,1177045584921391106,1177045229051473921,1176858146013868033,1176857653866819586,1176802128173101057,1176859793049939969,1176859407358521346
    // bgcolor  #222C45
    // phone 400 9655 778
    //  background https://tuangeche.oss-cn-qingdao.aliyuncs.com/b1008442fr7gahf69o9k.png,
    //label 国产车专场 value国产车专场

    super.initState();
    // print(widget.arguments['id']);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 100) {
        if (nolist) {
          getData();
        }
        setState(() {
          isMore = false;
        });
      }
    });
    getitem(widget.arguments['id']);
    getphone();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxlogin = fluwx.responseFromShare.listen((data) {
      if (data.errCode == 0) {
        print('分享成功！');
        // getShare();
      }
    });
  }

  void dispose() {
    _wxlogin.cancel();
    super.dispose();
  }

  // getShare() {
  //   HttpUtlis.post("wx/share/callback",
  //       params: {'dataId': widget.arguments['id'], 'type': 4, 'platform': 1},
  //       success: (value) async {
  //     if (value['errno'] == 0) {
  //       print('分享成功～');
  //     }
  //   }, failure: (error) {
  //     Toast.show('${error}', context,
  //         backgroundColor: Color(0xff5b5956),
  //         backgroundRadius: Ui.width(16),
  //         duration: Toast.LENGTH_SHORT,
  //         gravity: Toast.CENTER);
  //   });
  // }

  getphone() async {
    var phones = await Storage.getString('phone');
    setState(() {
      phone = phones.replaceAll(' ', '');
    });
  }

  getitem(id) async {
    await HttpUtlis.get('wx/dic/${id}', success: (value) {
      if (value['errno'] == 0) {
        var strs = '';
        var obj = value['data']['extra']['query'];
        obj.forEach((key, value) {
          strs = strs + '${key}=${value}&';
        });
        setState(() {
          data = value['data'];
          str = strs.substring(0, strs.length - 1);
          bacolor = value['data']['extra']['bgcolor']
              .substring(1, value['data']['extra']['bgcolor'].length);
        });
        getData();
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    setState(() {
      isloading = true;
    });
  }

  getData() async {
    if (isMore) {
      await HttpUtlis.get(
          'wx/goods/list?page=${this.page}&limit=${this.limit}&${this.str}',
          success: (value) {
        // print(value['data']['list']);
        if (value['errno'] == 0) {
          if (value['data']['list'].length < limit) {
            setState(() {
              nolist = false;
              this.isMore = true;
              list.addAll(value['data']['list']);
            });
          } else {
            setState(() {
              page++;
              nolist = true;
              this.isMore = true;
              list.addAll(value['data']['list']);
            });
          }
        }
      }, failure: (error) {
        Toast.show('${error}', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      });
    }
  }

  adColor(String colorString, {double alpha = 1.0}) {
    String colorStr = colorString;
    // colorString未带0xff前缀并且长度为6
    if (!colorStr.startsWith('0xff') && colorStr.length == 6) {
      // print('object');
      colorStr = '0xff' + colorStr;
    }
    // colorString为8位，如0x000000
    if (colorStr.startsWith('0x') && colorStr.length == 8) {
      colorStr = colorStr.replaceRange(0, 2, '0xff');
    }
    // colorString为7位，如#000000
    if (colorStr.startsWith('#') && colorStr.length == 7) {
      colorStr = colorStr.replaceRange(0, 1, '0xff');
    }
    // 先分别获取色值的RGB通道
    // print(.substring(1, widget.arguments['item']['extra']['bgcolor'].length))
    // print(int.parse(colorStr));
    Color color = Color(int.parse(colorStr));
    int red = color.red;
    int green = color.green;
    int blue = color.blue;
    // 通过fromRGBO返回带透明度和RGB值的颜色
    return Color.fromRGBO(red, green, blue, alpha);
  }

  getDom() {
    List<Widget> listall = [];
    Widget content;
    for (var item in list) {
      listall.add(InkWell(
          onTap: () {
            TalkingDataAppAnalytics.onEvent(
                eventID: 'cardetail',
                eventLabel: '汽车详情',
                params: {"goodsSn": item['goodsSn']});
            Navigator.pushNamed(context, '/cardetail', arguments: {
              "id": item['id'],
            });
          },
          child: Container(
            width: Ui.width(702),
            height: Ui.width(230),
            padding: EdgeInsets.fromLTRB(Ui.width(28), 0, Ui.width(16), 0),
            margin: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(10)),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/2.0x/specialbg.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: Ui.width(225),
                  margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CachedNetworkImage(
                        width: Ui.width(225),
                        height: Ui.width(170),
                        fit: BoxFit.cover,
                        imageUrl: '${item['picUrl']}',
                      ),
                      // Image.network(
                      //   '${item['picUrl']}',
                      //   width: Ui.width(225),
                      //   height: Ui.width(170),
                      //   fit: BoxFit.cover,
                      // ),
                      InkWell(
                        onTap: () async {
                          var tel = await Storage.getString('phone');
                          var url = 'tel:${tel.replaceAll(' ', '')}';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw '拨打失败';
                          }
                        },
                        child: Container(
                            width: Ui.width(157),
                            height: Ui.width(38),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Ui.width(38)),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF253858),
                                  Color(0xFF41608C),
                                ],
                              ),
                            ),
                            child: Text('咨询客服',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(24.0),
                                ))),
                      )
                    ],
                  ),
                ),
                Container(
                  width: Ui.width(382),
                  margin: EdgeInsets.fromLTRB(0, Ui.width(24), 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${item['name']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0),
                          )),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                  text: '惊爆价:',
                                  style: TextStyle(
                                    color: Color(0xFFD10123),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(22.0),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text:
                                            ' ${item['retailPrice']}${item['unit']}',
                                        style: TextStyle(
                                          color: Color(0xFFD10123),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(34.0),
                                        ))
                                  ]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, Ui.width(5), 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              text: TextSpan(
                                  text:
                                      '官方指导价:${item['counterPrice']}${item['unit']}',
                                  style: TextStyle(
                                    color: Color(0xFF9398A5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(22.0),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '  优惠 ',
                                        style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(22.0),
                                        )),
                                    TextSpan(
                                        text:
                                            '${(item['counterPrice'] - item['retailPrice']).toStringAsFixed(2)}${item['unit']}',
                                        style: TextStyle(
                                          color: Color(0xFFD10123),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(22.0),
                                        ))
                                  ]),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )));
    }
    content = new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: listall,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isloading ? '${data['label']}' : '',
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
                                  '${Config.weblink}appspecial/${widget.arguments['id']}/${this.phone}',
                              title: '${data['label']}',
                              description: '${data['value']}',
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
              color: adColor(bacolor),
              child: ListView(
                controller: _scrollController,
                children: <Widget>[
                  Container(
                    width: Ui.width(750),
                    height: Ui.width(320),
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image: NetworkImage(
                    //         '${data['extra']['background']}?x-oss-process=image/resize,p_70'),
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: ClipRRect(
                            child: CachedNetworkImage(
                                width: Ui.width(750),
                                height: Ui.width(320),
                                fit: BoxFit.fill,
                                imageUrl: '${data['extra']['background']}'),
                          ),
                        ),
                        Positioned(
                          left: Ui.width(63),
                          top: Ui.width(100),
                          child: Text(
                            '${data['label']}',
                            style: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: Ui.setFontSizeSetSp(46),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                        Positioned(
                          left: Ui.width(63),
                          top: Ui.width(170),
                          child: Text(
                            '${data['value']}',
                            style: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: Ui.setFontSizeSetSp(26),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: adColor(bacolor),
                    padding: EdgeInsets.fromLTRB(
                      Ui.width(24),
                      0,
                      Ui.width(24),
                      Ui.width(15),
                    ),
                    child: list.length > 0 ? getDom() : Text(''),
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
