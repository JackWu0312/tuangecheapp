import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
// import './test.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import '../../common/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../provider/Successlogin.dart';
import './test.dart';
import 'package:toast/toast.dart';

class Mallpage extends StatefulWidget {
  Mallpage({Key key}) : super(key: key);

  @override
  _MallpageState createState() => _MallpageState();
}

class _MallpageState extends State<Mallpage> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  EasyRefreshController _controller;
  bool isloading = false;
  var item = {};
  List categories = [];
  List list = [];
  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    getData();
  }

  getclear() async {
    await Storage.clear();
    getData();
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
    await HttpUtlis.get('wx/points/index', success: (value) {
      if (value['errno'] == 0) {
        var newlist = value['data']['categories'].map((values) {
          values["picUrl"] = values["picUrl"] != null
              ? values["picUrl"]
              : 'https://litecarmall.oss-cn-beijing.aliyuncs.com/a9aweabmhhggjkjiwqq7.jpg';
          return values;
        }).toList();
        setState(() {
          item = value['data'];
          categories = newlist;
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
    setState(() {
      this.isloading = true;
    });
  }

  Widget borderwidth(height) {
    return Container(
      width: double.infinity,
      height: Ui.width(height),
      color: Color(0XFFF8F9FB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Successlogin>(context);
    if (counter.count) {
       Future.delayed(Duration(milliseconds: 200)).then((e) {
      counter.increment(false);
    });
      //  counter.increment(false);
      getData();
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
                                              borderRadius:
                                                  BorderRadius.vertical(
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
                                              borderRadius:
                                                  BorderRadius.vertical(
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
          '积分商城',
          style: TextStyle(
              color: Color(0xFF111F37),
              fontWeight: FontWeight.w500,
              fontFamily: 'PingFangSC-Medium,PingFang SC',
              fontSize: Ui.setFontSizeSetSp(36.0)),
        ),
        centerTitle: true,
        elevation: 0,
        brightness: Brightness.light,
      ),
      body: EasyRefresh(
        enableControlFinishRefresh: false,
        enableControlFinishLoad: true,
        controller: _controller,
        header: ClassicalHeader(
          refreshText: '下拉刷新哦～',
          refreshReadyText: '下拉刷新哦～',
          refreshingText: '加载中～',
          refreshedText: '加载完成',
          infoText: "更新时间 %T",
          infoColor: Color(0XFF111F37),
          textColor: Color(0XFF111F37),
        ),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2), () {
            getData();
            _controller.resetLoadState();
          });
        },
        child: isloading
            ? ListView(
                children: <Widget>[
                  Container(
                    width: Ui.width(750),
                    height: Ui.width(280),
                    alignment: Alignment.center,
                    child: item['banners']!=null? 
                    // AspectRatio(
                    //     aspectRatio: 2 / 1,
                    //     child:
                         Swiper(
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/bannerwebview',
                                    arguments: {
                                      "url": item['banners'][index]['link'],
                                      "title": item['banners'][index]['name']
                                    });
                              },
                              child: Image.network(
                                "${item['banners'][index]['url']}",
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          itemCount: item['banners'].length,
                          autoplay: item['banners'].length>1?true:false,
                          pagination: SwiperPagination(
                              alignment: Alignment.bottomCenter,
                              builder: new SwiperCustomPagination(builder:
                                  (BuildContext context,
                                      SwiperPluginConfig config) {
                                return new PageIndicator(
                                  layout: PageIndicatorLayout.NIO,
                                  size: 8.0,
                                  space: 15.0,
                                  count: item['banners'].length,
                                  color: Color.fromRGBO(255, 255, 255, 0.4),
                                  activeColor: Color(0XFF111F37),
                                  controller: config.pageController,
                                );
                              }),
                        )):Text(''),
                  ),
                  Container(
                    width: Ui.width(750.0),
                    height: Ui.width(90.0),
                    color: Color(0XFFFFFFFF),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            // alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/integral.png',
                                  width: Ui.width(29.0),
                                  height: Ui.width(32.0),
                                ),
                                SizedBox(
                                  width: Ui.width(20),
                                ),

                                RichText(
                                  text: TextSpan(
                                    text: '积分  ',
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(28.0)),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: item["points"] == null
                                              ? '0'
                                              : '${item["points"]}',
                                          style: TextStyle(
                                              color: Color(0xFFD10123),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () async {
                                if (await getToken() != null) {
                                  Navigator.pushNamed(context, '/exchange');
                                } else {
                                  showtosh();
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'images/2.0x/exchange.png',
                                      width: Ui.width(29.0),
                                      height: Ui.width(32.0),
                                    ),
                                    SizedBox(
                                      width: Ui.width(20),
                                    ),
                                    Text('兑换记录',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(28.0))),
                                  ],
                                ),
                              ),
                            )),
                        // Expanded(
                        //   flex: 1,
                        //   child: Container(
                        //     alignment: Alignment.center,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       crossAxisAlignment: CrossAxisAlignment.center,
                        //       children: <Widget>[
                        //         Image.asset(
                        //           'images/2.0x/rollbag.png',
                        //           width: Ui.width(29.0),
                        //           height: Ui.width(32.0),
                        //         ),
                        //         SizedBox(
                        //           width: Ui.width(20),
                        //         ),
                        //         Text('券包',
                        //             style: TextStyle(
                        //                 color: Color(0xFF111F37),
                        //                 fontWeight: FontWeight.w400,
                        //                 fontFamily:
                        //                     'PingFangSC-Medium,PingFang SC',
                        //                 fontSize: Ui.setFontSizeSetSp(28.0))),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  borderwidth(16.0),
                  // Container(
                  //     width: Ui.width(624.0),
                  //     color: Color(0XFFFFFFFF),
                  //     padding: EdgeInsets.fromLTRB(Ui.width(63), Ui.width(60),
                  //         Ui.width(63), Ui.width(60)),
                  //     child: Wrap(
                  //         spacing: Ui.width(66),
                  //         runSpacing: Ui.width(70),
                  //         crossAxisAlignment: WrapCrossAlignment.start,
                  //         // alignment:WrapAlignment.spaceBetween,
                  //         children: this.categories.map((items) {
                  //           return InkWell(
                  //             onTap: () {
                  //               Navigator.pushNamed(context, '/detailslist',
                  //                   arguments: {
                  //                     "id": items['id'],
                  //                     "title": items['name']
                  //                   });
                  //             },
                  //             child: Container(
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 crossAxisAlignment: CrossAxisAlignment.center,
                  //                 children: <Widget>[
                  //                   Image.network(
                  //                     '${items["picUrl"]}',
                  //                     width: Ui.width(70.0),
                  //                     height: Ui.width(70.0),
                  //                   ),
                  //                   SizedBox(
                  //                     height: Ui.width(17.0),
                  //                   ),
                  //                   Text(
                  //                     '${items["name"]}',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF111F37),
                  //                         fontWeight: FontWeight.w400,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(26.0)),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //           );
                  //         }).toList())),
                  Container(
                    color: Color(0xFFFFFFFF),
                    padding: EdgeInsets.fromLTRB(
                        Ui.width(24), Ui.width(30), 0, Ui.width(15)),
                    child: Text(
                      '热门活动',
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(40.0)),
                    ),
                  ),
                  Container(
                    color: Color(0xFFFFFFFF),
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(24), 0, Ui.width(24), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            if (await getToken() != null) {
                              Navigator.pushNamed(
                                context,
                                '/tokenwebview',
                                arguments: {
                                  'url':'applotterys'
                                }
                              );
                            } else {
                              showtosh();
                            }
                          },
                          child: Container(
                            width: Ui.width(341),
                            height: Ui.width(226),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/2.0x/turntable.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(35),
                                  left: Ui.width(30),
                                  child: Text(
                                    '幸运大转盘',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(34.0)),
                                  ),
                                ),
                                Positioned(
                                  top: Ui.width(83),
                                  left: Ui.width(30),
                                  child: Text(
                                    '积分“转”大奖',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(24.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/integral');
                          },
                          child: Container(
                            width: Ui.width(341),
                            height: Ui.width(226),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/2.0x/explosive.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                 Positioned(
                                  top: Ui.width(35),
                                  left: Ui.width(30),
                                  child: Text(
                                    '1积分 抽爆品',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(34.0)),
                                  ),
                                ),
                                Positioned(
                                  top: Ui.width(83),
                                  left: Ui.width(30),
                                  child: Text(
                                    '兑海量好礼',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(24.0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Container(
                  //   color: Color(0xFFFFFFFF),
                  //   padding: EdgeInsets.fromLTRB(
                  //       Ui.width(24), Ui.width(40), 0, Ui.width(15)),
                  //   child: Text(
                  //     '商城通用券',
                  //     style: TextStyle(
                  //         color: Color(0xFF111F37),
                  //         fontWeight: FontWeight.w500,
                  //         fontFamily: 'PingFangSC-Medium,PingFang SC',
                  //         fontSize: Ui.setFontSizeSetSp(40.0)),
                  //   ),
                  // ),
                  // Container(
                  //   width: Ui.width(725),
                  //   height: Ui.width(190),
                  //   color: Color(0xFFFFFFFF),
                  //   padding: EdgeInsets.fromLTRB(Ui.width(24), 0, 0, 0),
                  //   child: ListView(
                  //     scrollDirection: Axis.horizontal,
                  //     children: <Widget>[
                  //       Container(
                  //         width: Ui.width(318),
                  //         height: Ui.width(190),
                  //         decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //             image: AssetImage(
                  //               'images/2.0x/volume.png',
                  //             ),
                  //             fit: BoxFit.fitWidth,
                  //           ),
                  //         ),
                  //         child: Stack(
                  //           children: <Widget>[
                  //             Positioned(
                  //               top: Ui.width(28),
                  //               left: Ui.width(20),
                  //               child: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.start,
                  //                 crossAxisAlignment: CrossAxisAlignment.end,
                  //                 children: <Widget>[
                  //                   Text(
                  //                     '￥',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF8D551B),
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(28.0)),
                  //                   ),
                  //                   Text(
                  //                     '30',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF8D551B),
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(42.0)),
                  //                   ),
                  //                   SizedBox(
                  //                     width: Ui.width(10),
                  //                   ),
                  //                   Container(
                  //                     alignment: Alignment.topLeft,
                  //                     width: Ui.width(160),
                  //                     child: Column(
                  //                       crossAxisAlignment:
                  //                           CrossAxisAlignment.start,
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.start,
                  //                       children: <Widget>[
                  //                         Text(
                  //                           '汽车音响专享券',
                  //                           textAlign: TextAlign.left,
                  //                           style: TextStyle(
                  //                               color: Color(0xFF8E541C),
                  //                               fontWeight: FontWeight.w400,
                  //                               fontFamily:
                  //                                   'PingFangSC-Medium,PingFang SC',
                  //                               fontSize:
                  //                                   Ui.setFontSizeSetSp(22.0)),
                  //                         ),
                  //                         Text(
                  //                           '满2000元使用',
                  //                           textAlign: TextAlign.right,
                  //                           style: TextStyle(
                  //                               color: Color(0xFF8E541C),
                  //                               fontWeight: FontWeight.w400,
                  //                               fontFamily:
                  //                                   'PingFangSC-Medium,PingFang SC',
                  //                               fontSize:
                  //                                   Ui.setFontSizeSetSp(22.0)),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: Ui.width(318),
                  //         height: Ui.width(190),
                  //         decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //             image: AssetImage(
                  //               'images/2.0x/volume.png',
                  //             ),
                  //             fit: BoxFit.fitWidth,
                  //           ),
                  //         ),
                  //         child: Stack(
                  //           children: <Widget>[
                  //             Positioned(
                  //               top: Ui.width(35),
                  //               left: Ui.width(20),
                  //               child: Row(
                  //                 children: <Widget>[
                  //                   Text(
                  //                     '￥',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF8D551B),
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(28.0)),
                  //                   ),
                  //                   Text(
                  //                     '200',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF8D551B),
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(42.0)),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //             Positioned(
                  //               top: Ui.width(27),
                  //               left: Ui.width(140),
                  //               child: Container(
                  //                 alignment: Alignment.topLeft,
                  //                 width: Ui.width(160),
                  //                 child: Column(
                  //                   crossAxisAlignment:
                  //                       CrossAxisAlignment.start,
                  //                   mainAxisAlignment: MainAxisAlignment.start,
                  //                   children: <Widget>[
                  //                     Text(
                  //                       '汽车音响专享券',
                  //                       textAlign: TextAlign.left,
                  //                       style: TextStyle(
                  //                           color: Color(0xFF8E541C),
                  //                           fontWeight: FontWeight.w400,
                  //                           fontFamily:
                  //                               'PingFangSC-Medium,PingFang SC',
                  //                           fontSize:
                  //                               Ui.setFontSizeSetSp(22.0)),
                  //                     ),
                  //                     Text(
                  //                       '满2000元使用',
                  //                       textAlign: TextAlign.right,
                  //                       style: TextStyle(
                  //                           color: Color(0xFF8E541C),
                  //                           fontWeight: FontWeight.w400,
                  //                           fontFamily:
                  //                               'PingFangSC-Medium,PingFang SC',
                  //                           fontSize:
                  //                               Ui.setFontSizeSetSp(22.0)),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         width: Ui.width(318),
                  //         height: Ui.width(190),
                  //         decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //             image: AssetImage(
                  //               'images/2.0x/volume.png',
                  //             ),
                  //             fit: BoxFit.fitWidth,
                  //           ),
                  //         ),
                  //         child: Stack(
                  //           children: <Widget>[
                  //             Positioned(
                  //               top: Ui.width(35),
                  //               left: Ui.width(20),
                  //               child: Row(
                  //                 children: <Widget>[
                  //                   Text(
                  //                     '￥',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF8D551B),
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(28.0)),
                  //                   ),
                  //                   Text(
                  //                     '20',
                  //                     style: TextStyle(
                  //                         color: Color(0xFF8D551B),
                  //                         fontWeight: FontWeight.w500,
                  //                         fontFamily:
                  //                             'PingFangSC-Medium,PingFang SC',
                  //                         fontSize: Ui.setFontSizeSetSp(42.0)),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Container(
                    color: Color(0xFFFFFFFF),
                    padding: EdgeInsets.fromLTRB(Ui.width(24), Ui.width(24), Ui.width(24), Ui.width(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '新品推荐',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(42.0)),
                        ),
                        // Container(
                        //   child: Row(
                        //     children: <Widget>[
                        //       Text(
                        //         '更多',
                        //         style: TextStyle(
                        //             color: Color(0xFF6A7182),
                        //             fontWeight: FontWeight.w400,
                        //             fontFamily: 'PingFangSC-Medium,PingFang SC',
                        //             fontSize: Ui.setFontSizeSetSp(26.0)),
                        //       ),
                        //       SizedBox(
                        //         width: Ui.width(12),
                        //       ),
                        //       Image.asset(
                        //         'images/2.0x/rightmore.png',
                        //         width: Ui.width(13.0),
                        //         height: Ui.width(26.0),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    color: Color(0xFFFFFFFF),
                    width: Ui.width(725),
                    height: Ui.width(405),
                    padding: EdgeInsets.fromLTRB(Ui.width(24), 0, 0, Ui.width(35)),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: item['products'].length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/goodsdetail',
                                arguments: {
                                  "id": item['products'][index]['id'],
                                });
                          },
                          child: Container(
                            width: Ui.width(280),
                            height: Ui.width(370),
                            margin: EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Image.network(
                                  '${item['products'][index]['picUrl']}',
                                  width: Ui.width(280),
                                  height: Ui.width(280),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  height: Ui.width(10),
                                ),
                                Container(
                                  width: Ui.width(280),
                                  child: Text(
                                    '${item['products'][index]['name']}',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(28.0)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  width: Ui.width(280),
                                  child: Text(
                                    '${item['products'][index]['points']}积分',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Color(0xFFD10123),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(24.0)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    child: Column(
                      children: list.map((val) {
                        return Container(
                          child: Column(
                            children: <Widget>[
                              borderwidth(16.0),
                              Container(
                                color: Color(0xFFFFFFFF),
                                padding: EdgeInsets.fromLTRB(Ui.width(24),
                                    Ui.width(35), Ui.width(24), Ui.width(25)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${val['label']}',
                                      style: TextStyle(
                                          color: Color(0xFF6A7182),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/integrallist',
                                            arguments: {
                                              "minPoints":
                                                  val['minPoints'] == null
                                                      ? ''
                                                      : val['minPoints'],
                                              "maxPoints":
                                                  val['maxPoints'] == null
                                                      ? ''
                                                      : val['maxPoints'],
                                              "title": val['label']
                                            });
                                      },
                                      child: Container(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              '更多',
                                              style: TextStyle(
                                                  color: Color(0xFF6A7182),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      26.0)),
                                            ),
                                            SizedBox(
                                              width: Ui.width(12),
                                            ),
                                            Image.asset(
                                              'images/2.0x/rightmore.png',
                                              width: Ui.width(13.0),
                                              height: Ui.width(26.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                  color: Color(0xFFFFFFFF),
                                  width: Ui.width(725),
                                  height: Ui.width(340),
                                  padding: EdgeInsets.fromLTRB(
                                      Ui.width(24), 0, 0, 0),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: val['goods'].length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/goodsdetail',
                                              arguments: {
                                                "id": val['goods'][index]['id'],
                                              });
                                        },
                                        child: Container(
                                          width: Ui.width(220),
                                          height: Ui.width(340),
                                          margin: EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Image.network(
                                                '${val['goods'][index]['picUrl']}',
                                                width: Ui.width(220),
                                                height: Ui.width(220),
                                               fit: BoxFit.contain,
                                              ),
                                              SizedBox(
                                                height: Ui.width(20),
                                              ),
                                              Container(
                                                width: Ui.width(220),
                                                child: Text(
                                                  '${val['goods'][index]['name']}',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Color(0xFF111F37),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              28.0)),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                width: Ui.width(220),
                                                child: Text(
                                                  '${val['goods'][index]["points"]}积分',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Color(0xFFD10123),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                
                ],
              )
            : Container(
                margin: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: LoadingDialog(
                  text: "加载中…",
                ),
              ),
      ),
    );
  }
}
