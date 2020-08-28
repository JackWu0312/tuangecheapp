import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_tuangeche/ui/ui.dart';
// import 'package:flutter_easyrefresh/easy_refresh.dart';
import './test.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import '../../common/Storage.dart';

class Integral extends StatefulWidget {
  Integral({Key key}) : super(key: key);

  @override
  _IntegralState createState() => _IntegralState();
}

class _IntegralState extends State<Integral> {
  //  ScrollController _scrollController = new ScrollController();
  // EasyRefreshController _controller;
  bool isloading = false;
  List banner = [];
  var obj = {};
  // int page = 1;
  // int size = 4;
  List list = [];
  @override
  void initState() {
    super.initState();
    // _controller = EasyRefreshController();
    getData();
    getBanner();
  }

  getBanner() {
    HttpUtlis.get('wx/points/lottery/banners', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          banner = value['data'];
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

  getData() async {
    await HttpUtlis.get('wx/points/lottery/now', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          obj = value['data'];
          list = value['data']["prizes"];
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

  List<Widget> getList() {
    return list.map((value) {
      // print(value);
      return InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/commodity',
              arguments: {"id": value['id']});
        },
        child: Container(
          width: Ui.width(750),
          height: Ui.width(240),
          padding: EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
          decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              border: Border(
                  bottom: BorderSide(width: 1, color: Color(0xffEAEAEA)))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: Ui.width(180),
                  height: Ui.width(180),
                  margin: EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //     image: NetworkImage(
                  //       'https://litecarmall.oss-cn-beijing.aliyuncs.com/nz3fju0c0iefuz32zdtk.jpg',
                  //     ),
                  //     fit: BoxFit.cover,
                  //   ),
                  // )
                  child: CachedNetworkImage(
                      width: Ui.width(180),
                      height: Ui.width(180),
                      fit: BoxFit.fill,
                      imageUrl: '${value["picUrl"]}}')),
              Expanded(
                  flex: 1,
                  child: Container(
                    padding:
                        EdgeInsets.fromLTRB(0, Ui.width(22), 0, Ui.width(22)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${value["goodsName"]}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(32.0)),
                        ),
                        // SizedBox(
                        //   height: Ui.width(15),
                        // ),
                        Text(
                          '市场参考价：${value["price"]}元',
                          style: TextStyle(
                              color: Color(0xFF9398A5),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(24.0)),
                        ),
                        // SizedBox(
                        //   height: Ui.width(30),
                        // ),
                        RichText(
                          text: TextSpan(
                            text: '${value["points"]}',
                            style: TextStyle(
                                color: Color(0xFFD10123),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(36.0)),
                            children: <TextSpan>[
                              TextSpan(
                                text: '积分',
                                style: TextStyle(
                                    color: Color(0xFFD10123),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(22.0)),
                              ),
                            ],
                          ),
                        ),
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.end,
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: <Widget>[
                        //     Text(
                        //       '${value["points"]}',
                        //       style: TextStyle(
                        //           color: Color(0xFFD10123),
                        //           fontWeight: FontWeight.w400,
                        //           fontFamily: 'PingFangSC-Medium,PingFang SC',
                        //           fontSize: Ui.setFontSizeSetSp(36.0)),
                        //     ),
                        //     Text(
                        //       '积分',
                        //       style: TextStyle(
                        //           color: Color(0xFFD10123),
                        //           fontWeight: FontWeight.w400,
                        //           fontFamily: 'PingFangSC-Medium,PingFang SC',
                        //           fontSize: Ui.setFontSizeSetSp(22.0)),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ))
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget borderwidth(height) {
    return Container(
      width: double.infinity,
      height: Ui.width(height),
      color: Color(0XFFF8F9FB),
    );
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
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '1积分 抽爆品',
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
                  if (await getToken() != null) {
                    Navigator.pushNamed(context, '/record');
                  } else {
                    showtosh();
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 0, Ui.width(40), 0),
                  child: Text(
                    '抽奖记录',
                    style: TextStyle(
                        color: Color(0xFF111F37),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'PingFangSC-Medium,PingFang SC',
                        fontSize: Ui.setFontSizeSetSp(30.0)),
                  ),
                ))
          ],
        ),
        body: isloading
            ?
            // EasyRefresh(
            //     // enableControlFinishRefresh: true,
            //     // enableControlFinishLoad: true,
            //     controller: _controller,
            //     header: ClassicalHeader(
            //       // enableInfiniteRefresh: false,
            //       refreshText: '下拉刷新哦～',
            //       refreshReadyText: '下拉刷新哦～',
            //       refreshingText: '加载中～',
            //       refreshedText: '加载完成',
            //       infoText: "更新时间 %T",
            //       infoColor: Color(0XFF111F37),
            //       textColor: Color(0XFF111F37),
            //     ),
            //     footer: ClassicalFooter(
            //       // enableInfiniteLoad: false,
            //       loadText: '',Nofind
            //       loadReadyText: '',
            //       loadingText: '加载中～',
            //       loadedText: '加载中完成～',
            //       loadFailedText: '',
            //       noMoreText: '我是有底线的哦～',
            //       infoText: "更新时间 %T",
            //       bgColor: Color(0xFFFFFFFF),
            //       infoColor: Color(0XFF111F37),
            //       textColor: Color(0XFF111F37),
            //       // enableHapticFeedback: true,
            //     ),
            //     onRefresh: () async {
            //       await Future.delayed(Duration(seconds: 2), () {
            //         _controller.resetLoadState();
            //       });
            //     },
            //     onLoad: () async {
            //       await Future.delayed(Duration(seconds: 2), () {
            //         _controller.finishLoad();
            //       });
            //     },
            //     child:)
            Container(
                color: Color(0xFFFFFFFF),
                child: ListView(
                  children: <Widget>[
                    Container(
                      width: Ui.width(750),
                      height: Ui.width(280),
                      alignment: Alignment.center,
                      child:

                          // AspectRatio(
                          //     aspectRatio: 2 / 1,
                          //     child:
                          banner.length > 0
                              ? Swiper(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return CachedNetworkImage(
                                        width: Ui.width(750),
                                        height: Ui.width(280),
                                        fit: BoxFit.fill,
                                        imageUrl: "${banner[index]['url']}");

                                    // new Image.network(
                                    //   "${banner[index]['url']}",
                                    //   fit: BoxFit.fill,
                                    // );
                                  },
                                  itemCount: banner.length,
                                  autoplay: banner.length > 1 ? true : false,
                                  pagination: SwiperPagination(
                                      alignment: Alignment.bottomCenter,
                                      builder: new SwiperCustomPagination(
                                          builder: (BuildContext context,
                                              SwiperPluginConfig config) {
                                        return new PageIndicator(
                                          layout: PageIndicatorLayout.NIO,
                                          size: 8.0,
                                          space: 15.0,
                                          count: banner.length,
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.4),
                                          activeColor: Color(0XFF111F37),
                                          controller: config.pageController,
                                        );
                                      })),
                                )
                              : Text(''),
                    ),
                    list.length > 0
                        ? Container(
                            width: Ui.width(680),
                            height: Ui.width(100),
                            color: Color(0XFFFFFFFF),
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(40), 0, Ui.width(30), 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '开奖日期：${obj["date"]}',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                      Text(
                                        '（${obj['title']}）',
                                        style: TextStyle(
                                            color: Color(0xFF9398A5),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/integralrule');
                                  },
                                  child: Container(
                                    width: Ui.width(125),
                                    height: Ui.width(40),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: Ui.width(1),
                                          color: Color(0xffD10123)),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Text(
                                      '活动规则',
                                      style: TextStyle(
                                          color: Color(0xFFD10123),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(22.0)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox(),
                    list.length > 0 ? borderwidth(16.0) : SizedBox(),
                    list.length > 0
                        ? Container(
                            width: Ui.width(750),
                            color: Color(0xFFFFFFFF),
                            child: Column(
                              children: getList(),
                            ),
                          )
                        : SizedBox(),
                    list.length > 0
                        ? SizedBox()
                        : Container(
                            margin: EdgeInsets.fromLTRB(0, Ui.width(200), 0, 0),
                            child: Center(
                              child: Container(
                                height: Ui.width(450),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: Ui.width(400),
                                      child: AspectRatio(
                                        aspectRatio: 1 / 1,
                                        child: Image.asset(
                                            'images/2.0x/nofind.png'),
                                      ),
                                    ),
                                    Text(
                                      '暂无抽奖活动',
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}
