import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/ui.dart';
import '../../common/Storage.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';
import '../../provider/Successlogin.dart';
import '../../provider/Taskback.dart';
import '../../provider/Integral.dart';
// import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class Myinfo extends StatefulWidget {
  Myinfo({Key key}) : super(key: key);

  @override
  _MyinfoState createState() => _MyinfoState();
}

class _MyinfoState extends State<Myinfo> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  var userinfo;
  var point = 0;
  var status = 2;
  var continuousDays = 1;
  var signPoints = 0;
  var url = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlog();
    getUserdetail();
    getData();
    // getclear();
      fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
  }

  getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
  }

  getData() async {
    await HttpUtlis.get('wx/banner/listByPosition/11', success: (value) {
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
  }

  getlog() async {
    await HttpUtlis.get('wx/user/signIn/log', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          status = value['data']['status'];
          point = value['data']['freePoints'];
        });
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getclear() async {
    await Storage.clear();
  }

  signIn() async {
    await HttpUtlis.post('wx/user/signIn', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          continuousDays = value['data']['continuousDays'];
          signPoints = value['data']['signPoints'];
        });
        getlog();
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getUserdetail() async {
    var userinfos = await getUser();
    if (userinfos != null) {
      setState(() {
        userinfo = json.decode(userinfos);
      });
    } else {
      setState(() {
        userinfo = null;
      });
    }
  }

  getUser() async {
    try {
      String token = await Storage.getString('userInfo');
      return token;
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Successlogin>(context);
    final counterTaskback = Provider.of<Taskback>(context);
    final integral = Provider.of<Integral>(context);
    if (integral.count) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        //用延迟防止报错
        integral.increment(false);
      });
      getlog();
    }

    if (counter.count || counterTaskback.count) {
      getUserdetail();
      getlog();
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        counter.increment(false);
      });
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        counterTaskback.increment(false);
      });
    }

    Ui.init(context);
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

    showtask(continuousDays, signPoints) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                  width: Ui.width(500),
                  height: Ui.width(694),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(Ui.width(20.0))),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: Ui.width(490),
                        height: Ui.width(588),
                        margin: EdgeInsets.fromLTRB(Ui.width(5), 0, 0, 0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/2.0x/signing.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin:
                                  EdgeInsets.fromLTRB(0, Ui.width(200), 0, 0),
                              child: Text(
                                '连续签到${continuousDays}天',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(34.0)),
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.fromLTRB(0, Ui.width(110), 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '+',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Color(0xFFFFE1A5),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(40.0)),
                                  ),
                                  SizedBox(
                                    width: Ui.width(10),
                                  ),
                                  Text(
                                    '${signPoints}',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Color(0xFFFFE1A5),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(90.0)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: Ui.width(215),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: Ui.width(56),
                              height: Ui.width(56),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      AssetImage('images/2.0x/closesing.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
            );
          });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            appBar: PreferredSize(
                child: Container(
                  height: Ui.height(0),
                ),
                preferredSize: Size(0, 0)),
            body: Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                  0, Ui.width(30) + MediaQuery.of(context).padding.top, 0, 0),
              child: ListView(
                children: <Widget>[
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            if (await getToken() != null) {
                              Navigator.pushNamed(context, '/info');
                            } else {
                              Navigator.pushNamed(context, '/login');
                            }
                          },
                          child: Container(
                            width: Ui.width(44),
                            height: Ui.width(38),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/2.0x/personal.png'),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.pushNamed(
                              context,
                              '/conversation',
                            );
                            // var tel = await Storage.getString('phone');
                            // var url = 'tel:${tel.replaceAll(' ', '')}';
                            // if (await canLaunch(url)) {
                            //   await launch(url);
                            // } else {
                            //   throw '拨打失败';
                            // }
                          },
                          child: Container(
                            width: Ui.width(38),
                            height: Ui.width(38),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/2.0x/call.png'),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.fromLTRB(0, Ui.width(67), Ui.width(0), 0),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(Ui.width(49), 0, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  if (await getToken() == null) {
                                    Navigator.pushNamed(context, '/login');
                                  }
                                },
                                child: Container(
                                  width: Ui.width(152),
                                  height: Ui.width(152),
                                  child: AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: userinfo == null
                                        ? Image.asset('images/2.0x/nologin.png')
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(90.0),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              width: Ui.width(120),
                                              height: Ui.width(120),
                                              imageUrl: '${userinfo['avatar']}',
                                            ),
                                          ),

                                    // ClipRRect(
                                    //     borderRadius:
                                    //         BorderRadius.circular(90.0),
                                    //     child: Image.network(
                                    //       '${userinfo['avatar']}',
                                    //       fit: BoxFit.cover,
                                    //       width: Ui.width(120),
                                    //       height: Ui.width(120),
                                    //     ),
                                    //   ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Ui.width(39),
                              ),
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () async {
                                        if (await getToken() == null) {
                                          Navigator.pushNamed(
                                              context, '/login');
                                        }
                                      },
                                      child: Text(
                                        userinfo == null
                                            ? '请登录'
                                            : '${userinfo['nickname']}',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(40.0)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Ui.width(10),
                                    ),
                                    Text(
                                      '总积分 ${this.point}',
                                      style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ],
                                ),
                              ),

                              // SizedBox(
                              //   height: Ui.width(40),
                              // ),
                              // InkWell(
                              //   onTap: () async {
                              //     if (await getToken() != null) {
                              //       TalkingDataAppAnalytics.onEvent(
                              //         eventID: 'tuanyou',
                              //         eventLabel: '团油',
                              //       );
                              //       var longitude =
                              //           await Storage.getString('longitude');
                              //       var latitude =
                              //           await Storage.getString('latitude');
                              //       if (userinfo['mobile'] != null &&
                              //           userinfo['mobile'] != '') {
                              //         Navigator.pushNamed(context, '/tuanyou',
                              //             arguments: {
                              //               'mobile': userinfo['mobile'],
                              //               'longitude': longitude,
                              //               'latitude': latitude
                              //             });
                              //       } else {
                              //         Toast.show('请去个人中心完善手机信息', context,
                              //             backgroundColor: Color(0xff5b5956),
                              //             backgroundRadius: Ui.width(16),
                              //             duration: Toast.LENGTH_SHORT,
                              //             gravity: Toast.CENTER);
                              //         Future.delayed(Duration(seconds: 1), () {
                              //           Navigator.pushNamed(context, '/info');
                              //         });
                              //       }
                              //     } else {
                              //       showtosh();
                              //     }

                              //     // var url =
                              //     //     'https://test-open.czb365.com/redirection/todo/?platformType=98637607&platformCode=${userinfo['mobile']}&latitude=${latitude}&longitude=${longitude}';
                              //     // if (await canLaunch(url)) {
                              //     //   await launch(url);
                              //     // } else {
                              //     //   Toast.show('请求失败～', context,
                              //     //       backgroundColor: Color(0xff5b5956),
                              //     //       backgroundRadius: Ui.width(16),
                              //     //       duration: Toast.LENGTH_SHORT,
                              //     //       gravity: Toast.CENTER);
                              //     // }
                              //   },
                              //   child: Container(
                              //     width: Ui.width(702),
                              //     height: Ui.width(120),
                              //     child: url != ''
                              //         ? CachedNetworkImage(
                              //             fit: BoxFit.cover,
                              //             width: Ui.width(702),
                              //             height: Ui.width(120),
                              //             imageUrl: '${url}')

                              //         // Image.network(
                              //         //     '${url}',
                              //         //     fit: BoxFit.cover,
                              //         //     width: Ui.width(702),
                              //         //     height: Ui.width(120),
                              //         //   )
                              //         : Text(''),
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        Positioned(
                            right: 0,
                            top: Ui.width(33),
                            child: InkWell(
                              onTap: () async {
                                if (status == 2) {
                                  if (await getToken() != null) {
                                    await signIn();
                                    showtask(continuousDays, signPoints);
                                  } else {
                                    showtosh();
                                  }
                                }
                              },
                              child: Container(
                                width: Ui.width(160),
                                alignment: Alignment.center,
                                height: Ui.width(58),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: Ui.width(1),
                                      color: status == 2
                                          ? Color(0xFF111F37)
                                          : Color(0xFFD10123)),
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(Ui.width(50))),
                                ),
                                child: Text(
                                  status == 2 ? '立即签到' : '已签到',
                                  style: TextStyle(
                                      color: status == 2
                                          ? Color(0xFF111F37)
                                          : Color(0xFFD10123),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(26.0)),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(
                        Ui.width(30), Ui.width(70), Ui.width(30), 0),
                    width: Ui.width(690),
                    height: Ui.width(268),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          // box-shadow:0px 2px 17px 0px rgba(217,217,217,0.5);
                          BoxShadow(
                            color: Color(0xFFD9D9D9),
                            offset: Offset(0.0, Ui.width(2)), //阴影xy轴偏移量
                            blurRadius: Ui.width(17), //阴影模糊程度
                            // spreadRadius: 1.0 //阴影扩散程度
                          )
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(30), Ui.width(33), 0, Ui.width(47)),
                          child: Text(
                            '车主服务',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(32.0)),
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              InkWell(
                                onTap: (){
                                     launchWeChatMiniProgram(
                                        username: "gh_a6440e9b5c75",
                                        path: '/pages/index/index',
                                      );
                                },
                                child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset('images/2.0x/oil.png',
                                        width: Ui.width(70),
                                        height: Ui.height(70)),
                                    Text(
                                      '加油7折起',
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ],
                                ),
                              ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (await getToken() != null) {
                                    Navigator.pushNamed(
                                        context, '/tokenwebview',
                                        arguments: {'url': 'applovecar'});
                                  } else {
                                    showtosh();
                                  }
                                },
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('images/2.0x/mylovecar.png',
                                          width: Ui.width(70),
                                          height: Ui.height(70)),
                                      Text(
                                        '我的爱车',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () async {
                                    if (await getToken() != null) {
                                      Navigator.pushNamed(context, '/location');
                                    } else {
                                      showtosh();
                                    }
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('images/2.0x/location.png',
                                            width: Ui.width(70),
                                            height: Ui.height(70)),
                                        Text(
                                          '爱车定位',
                                          style: TextStyle(
                                              color: Color(0xFF111F37),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(26.0)),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      if (await getToken() != null) {
                        Navigator.pushNamed(context, '/listorder');
                      } else {
                        showtosh();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                          Ui.width(40), Ui.width(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '我的订单',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/myorder.png',
                                width: Ui.width(50), height: Ui.height(50)),
                          )
                        ],
                      ),
                    ),
                  ),
                  // InkWell(
                  //   onTap: () async {
                  //     if (await getToken() != null) {
                  //       Navigator.pushNamed(context, '/tokenwebview',
                  //           arguments: {'url': 'applovecar'});
                  //     } else {
                  //       showtosh();
                  //     }
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                  //         Ui.width(40), Ui.width(30)),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: <Widget>[
                  //         Container(
                  //           child: Row(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: <Widget>[
                  //               Text(
                  //                 '我的爱车',
                  //                 style: TextStyle(
                  //                     color: Color(0xFF111F37),
                  //                     fontWeight: FontWeight.w400,
                  //                     fontFamily:
                  //                         'PingFangSC-Medium,PingFang SC',
                  //                     fontSize: Ui.setFontSizeSetSp(32.0)),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         Container(
                  //           child: Image.asset('images/2.0x/mylovecar.png',
                  //               width: Ui.width(50), height: Ui.height(50)),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // InkWell(
                  //   onTap: () async {
                  //     if (await getToken() != null) {
                  //       Navigator.pushNamed(context, '/location');
                  //     } else {
                  //       showtosh();
                  //     }
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                  //         Ui.width(40), Ui.width(30)),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: <Widget>[
                  //         Container(
                  //           child: Row(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: <Widget>[
                  //               Text(
                  //                 '爱车定位',
                  //                 style: TextStyle(
                  //                     color: Color(0xFF111F37),
                  //                     fontWeight: FontWeight.w400,
                  //                     fontFamily:
                  //                         'PingFangSC-Medium,PingFang SC',
                  //                     fontSize: Ui.setFontSizeSetSp(32.0)),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         Container(
                  //           child: Image.asset('images/2.0x/location.png',
                  //               width: Ui.width(47), height: Ui.height(47)),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // InkWell(
                  //   onTap: () async {
                  //     if (await getToken() != null) {
                  //       Navigator.pushNamed(context, '/addresslist');
                  //     } else {
                  //       showtosh();
                  //     }
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                  //         Ui.width(40), Ui.width(30)),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       children: <Widget>[
                  //         Container(
                  //           child: Row(
                  //             crossAxisAlignment: CrossAxisAlignment.center,
                  //             children: <Widget>[
                  //               Text(
                  //                 '我的地址',
                  //                 style: TextStyle(
                  //                     color: Color(0xFF111F37),
                  //                     fontWeight: FontWeight.w400,
                  //                     fontFamily:
                  //                         'PingFangSC-Medium,PingFang SC',
                  //                     fontSize: Ui.setFontSizeSetSp(32.0)),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         Container(
                  //           child: Image.asset('images/2.0x/myadressnew.png',
                  //               width: Ui.width(50), height: Ui.height(50)),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  InkWell(
                    onTap: () async {
                      if (await getToken() != null) {
                        Navigator.pushNamed(context, '/rollbag');
                      } else {
                        showtosh();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                          Ui.width(40), Ui.width(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '我的券包',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rollbag.png',
                                width: Ui.width(50), height: Ui.height(50)),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await getToken() != null) {
                        Navigator.pushNamed(context, '/task');
                      } else {
                        showtosh();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                          Ui.width(40), Ui.width(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '我的任务',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '邀请有礼',
                                  style: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                ),
                                SizedBox(
                                  width: Ui.width(20),
                                ),
                                Image.asset('images/2.0x/mytask.png',
                                    width: Ui.width(50), height: Ui.height(50))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.pushNamed(context, '/easywebview',
                      //     arguments: {'url': 'apprlue'});
                      Navigator.pushNamed(context, '/about',);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(45),
                          Ui.width(40), Ui.width(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '关于我们',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/about.png',
                                width: Ui.width(50), height: Ui.height(50)),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
