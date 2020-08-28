import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter/services.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/Storage.dart';
import 'package:provider/provider.dart';
import '../../provider/Successlogin.dart';
import 'package:url_launcher/url_launcher.dart';

class Userpage extends StatefulWidget {
  Userpage({Key key}) : super(key: key);

  @override
  _UserpageState createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  Map status = {
    "0": "秒杀订单",
    "101": "待回访",
    "102": "已取消",
    "103": "已取消",
    "201": "已付款",
    "202": "订单取消，退款中",
    "203": "已退款",
    "301": "已回访",
    "302": "已核销",
    "303": "已出库",
    "401": "已收货",
    "402": "已收货"
  };
  Map paid = {
    0: false,
    101: false,
    102: false,
    103: false,
    202: false,
    203: false,
    201: true,
    301: true,
    302: true,
    303: true,
    401: true,
    402: true
  };
  List list = [];
  var userinfo;
  @override
  void initState() {
    super.initState();
    // getOrder();
    getUserdetail();
    // getclear();
  }

  getOrder() {
    HttpUtlis.get('wx/order/list?limit=1000', success: (value) {
      if (value['errno'] == 0) {
        // print(value['data']);
        setState(() {
          list = value['data']['list'];
        });
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    // setState(() {
    //   this.isloading = true;
    // });
  }

  getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
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

  getclear() async {
    await Storage.clear();
  }

  getUser() async {
    try {
      String token = await Storage.getString('userInfo');
      return token;
    } catch (e) {
      return '';
    }
  }

  getorderList() {
    return list.length > 0
        ? Container(
            padding: EdgeInsets.fromLTRB(Ui.width(36), 0, 0, 0),
            height: Ui.width(310),
            width: Ui.width(750),
            child: ListView.builder(
              itemBuilder: (context, index) {
                // print(list[index]['order']['addTime'] is String);
                // String addtime = list[index]['order']['addTime'];
                // addtime.substring(0,9);
                // list[index]['order']['addTime']=addtime;
                // print(addtime.substring(0,9));
                return Container(
                  width: Ui.width(620),
                  height: Ui.width(262),
                  margin: EdgeInsets.fromLTRB(
                      Ui.width(20), Ui.width(20), Ui.width(20), Ui.width(20)),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.all(Radius.circular(Ui.width(8.0))),
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0XFFDFE3EC),
                          offset: Offset(1, 1),
                          blurRadius: Ui.width(10.0),
                        ),
                        // BoxShadow(
                        //   color: Color(0XFFDFE3EC),
                        //   offset: Offset(-1, -1),
                        //   blurRadius: Ui.width(10.0),
                        // ),
                        // BoxShadow(
                        //   color: Color(0XFFDFE3EC),
                        //   offset: Offset(1, -1),
                        //   blurRadius: Ui.width(10.0),
                        // ),
                        // BoxShadow(
                        //   color: Color(0XFFDFE3EC),
                        //   offset: Offset(-1, 1),
                        //   blurRadius: Ui.width(10.0),
                        // ),
                      ]),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(0, Ui.width(15), 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(Ui.width(24), 0, 0, 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      left: BorderSide(
                                          width: Ui.width(6),
                                          color: Color(0xffD10123)))),
                              child: Text(
                                '拼团单',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                            ),
                            Container(
                                width: Ui.width(165),
                                height: Ui.width(46),
                                alignment: Alignment.center,
                                child: Text(
                                  '${list[index]['order']['addTime'].substring(0, 9)}',
                                  style: TextStyle(
                                      color: Color(0xFF9398A5),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(24.0)),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF0F2F6),
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(Ui.width(23))),
                                ))
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                        margin: EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: Ui.width(190),
                              height: Ui.width(160),
                              margin:
                                  EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(190),
                                    height: Ui.width(130),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(Ui.width(6))),
                                      child: CachedNetworkImage(
                                          width: Ui.width(190),
                                          height: Ui.width(130),
                                          fit: BoxFit.fill,
                                          imageUrl:
                                              '${list[index]['goods'][0]['picUrl']}'),
                                    ),
                                    // decoration: BoxDecoration(
                                    //     // color: Colors.red,
                                    //     image: DecorationImage(
                                    //       image: NetworkImage(
                                    //         '${list[index]['goods'][0]['picUrl']}?x-oss-process=image/resize,p_70',
                                    //       ),
                                    //       fit: BoxFit.fitWidth,
                                    //     ),
                                    //     borderRadius: BorderRadius.vertical(
                                    //         top: Radius.circular(Ui.width(6)))),
                                  ),
                                  Container(
                                    width: Ui.width(190),
                                    height: Ui.width(30),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(Ui.width(6))),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF69C7FF),
                                          Color(0xFF3895FF),
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      list[index]['order']['status']['value'] ==
                                              0
                                          ? '${list[index]['order']['type']['label']}'
                                          : '${status["${list[index]["order"]["status"]["value"]}"]}',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(22.0)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, Ui.width(10), 0),
                                      child: Text(
                                        '${list[index]['goods'][0]['name']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(34.0)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Ui.width(18),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, Ui.width(10), 0),
                                      child: Text(
                                        '小团集采价：${list[index]['goods'][0]['retailPrice']}${list[index]['goods'][0]['unit']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Color(0xFF9398A5),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Ui.width(30),
                                    ),
                                    // Container(
                                    //     width: double.infinity,
                                    //     margin: EdgeInsets.fromLTRB(
                                    //         0, 0, Ui.width(10), 0),
                                    //     child: Row(
                                    //       children: <Widget>[
                                    //         Text(
                                    //           '预定金：',
                                    //           maxLines: 1,
                                    //           overflow: TextOverflow.ellipsis,
                                    //           style: TextStyle(
                                    //               color: Color(0xFF9398A5),
                                    //               fontWeight: FontWeight.w400,
                                    //               fontFamily:
                                    //                   'PingFangSC-Medium,PingFang SC',
                                    //               fontSize: Ui.setFontSizeSetSp(
                                    //                   26.0)),
                                    //         ),
                                    //         Text(
                                    //           '200元',
                                    //           maxLines: 1,
                                    //           overflow: TextOverflow.ellipsis,
                                    //           style: TextStyle(
                                    //               color: Color(0xFFD10123),
                                    //               fontWeight: FontWeight.w400,
                                    //               fontFamily:
                                    //                   'PingFangSC-Medium,PingFang SC',
                                    //               fontSize: Ui.setFontSizeSetSp(
                                    //                   26.0)),
                                    //         )
                                    //       ],
                                    //     )),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              itemCount: list.length,
              scrollDirection: Axis.horizontal,
            ),
          )
        : Container(
            height: 0,
          );
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Successlogin>(context);
    if (counter.count) {
      getUserdetail();
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        counter.increment(false);
      });
    }
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
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(
                                                  Ui.width(20)))),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
            appBar: PreferredSize(
                child: Container(
                  height: Ui.height(0),
                ),
                preferredSize: Size(0, 0)),
            body: Container(
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    height: Ui.height(290.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            width: Ui.width(750),
                            // height: Ui.width(270),
                            child: AspectRatio(
                              aspectRatio: 25 / 9,
                              child: Image.asset('images/2.0x/myinfobg.png'),
                            ),
                          ),
                        ),
                        Positioned(
                            top: Ui.width(140),
                            left: Ui.width(55),
                            child: InkWell(
                              onTap: () async {
                                if (await getToken() != null) {
                                  await Storage.setString("info", "info");
                                  Navigator.pushNamed(context, '/info');
                                } else {
                                  await Storage.setString("info", "login");
                                  Navigator.pushNamed(context, '/login');
                                }
                              },
                              child: Container(
                                width: Ui.width(150),
                                height: Ui.width(150),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Ui.width(90.0))),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: userinfo == null
                                      ? Image.asset('images/2.0x/loginnew.png')
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(90.0),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: Ui.width(120),
                                            height: Ui.width(120),
                                            imageUrl: '${userinfo['avatar']}',
                                          )
                                          // Image.network(
                                          //   '${userinfo['avatar']}',
                                          //   fit: BoxFit.cover,
                                          //   width: Ui.width(120),
                                          //   height: Ui.width(120),
                                          // ),
                                          ),
                                ),
                              ),
                            )),
                        Positioned(
                            top: Ui.width(200),
                            left: Ui.width(240),
                            child: InkWell(
                              onTap: () async {
                                if (await getToken() != null) {
                                  Navigator.pushNamed(context, '/info');
                                } else {
                                  Navigator.pushNamed(context, '/login');
                                }
                              },
                              child: Container(
                                child: Text(
                                  userinfo == null
                                      ? '请登录'
                                      : '${userinfo['nickname']}',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                            ))
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
                      padding: EdgeInsets.fromLTRB(Ui.width(36), Ui.width(30),
                          Ui.width(50), Ui.width(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/order.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '我的订单',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
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
                                  '查看全部',
                                  style: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                ),
                                SizedBox(
                                  width: Ui.width(14),
                                ),
                                Image.asset('images/2.0x/rightmy.png',
                                    width: Ui.width(13), height: Ui.height(26)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // getorderList(),
                  InkWell(
                    onTap: () async {
                      if (await getToken() != null) {
                        Navigator.pushNamed(context, '/tokenwebview',
                            arguments: {'url': 'applovecar'});
                      } else {
                        showtosh();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(Ui.width(36), Ui.width(30),
                          Ui.width(50), Ui.width(60)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/mycar.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '我的爱车',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rightmy.png',
                                width: Ui.width(15), height: Ui.height(28)),
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
                      padding: EdgeInsets.fromLTRB(
                          Ui.width(36), 0, Ui.width(50), Ui.width(60)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/task.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '我的任务',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rightmy.png',
                                width: Ui.width(15), height: Ui.height(28)),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (await getToken() != null) {
                        Navigator.pushNamed(context, '/addresslist');
                      } else {
                        showtosh();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          Ui.width(36), 0, Ui.width(50), Ui.width(60)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/myadress.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '我的地址',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rightmy.png',
                                width: Ui.width(15), height: Ui.height(28)),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/easywebview',
                          arguments: {'url': 'apprlue'});
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          Ui.width(36), 0, Ui.width(50), Ui.width(60)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/myagreement.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '隐私政策',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rightmy.png',
                                width: Ui.width(15), height: Ui.height(28)),
                          )
                        ],
                      ),
                    ),
                  ),
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
                      padding: EdgeInsets.fromLTRB(
                          Ui.width(36), 0, Ui.width(50), Ui.width(60)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/mycall.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '客服电话',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rightmy.png',
                                width: Ui.width(15), height: Ui.height(28)),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/easywebview',
                          arguments: {'url': 'appabout'});
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                          Ui.width(36), 0, Ui.width(50), Ui.width(60)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/myinfos.png',
                                  width: Ui.width(50),
                                  height: Ui.height(50),
                                ),
                                SizedBox(
                                  width: Ui.width(13),
                                ),
                                Text(
                                  '关于我们',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Image.asset('images/2.0x/rightmy.png',
                                width: Ui.width(15), height: Ui.height(28)),
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
