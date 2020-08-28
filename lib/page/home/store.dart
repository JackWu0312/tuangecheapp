import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../mall/test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';
import 'dart:io'; //提供Platform接口
import '../../common/Storage.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Store extends StatefulWidget {
  final Map arguments;
  Store({Key key, this.arguments}) : super(key: key);
  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  var list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TalkingDataAppAnalytics.onPageStart('门店详情');
    // print(widget.arguments['store']['gallery'].length);
    getmaps();
  }

  getmaps() async {
    if (Platform.isIOS) {
      //ios相关代码
      var urlbaiduIos =
          'baidumap://map/geocoder?location=${widget.arguments['store']['latitude']},${widget.arguments['store']['longitude']}&coord_type=gcj02&src=ios.baidu.openAPIdemo';
      // var urlgaodeIos ='iosamap://viewMap?sourceApplication=applicationName&poiname=${widget.arguments['store']['address']}&lat=${widget.arguments['store']['latitude']}&lon=${widget.arguments['store']['longitude']}&dev=0';
      var urlgaodeIos =
          'iosamap://navi?sourceApplication=applicationName&poiname=fangheng&poiid=BGVIS&lat=${widget.arguments['store']['latitude']}&lon=${widget.arguments['store']['longitude']}&dev=1&style=2';
      // print('object');
      // print(await canLaunch(urlgaodeIos));
      // print('object');
      if (await canLaunch(urlgaodeIos)) {
        list.add({'url': urlgaodeIos, 'title': '高德地图'});
      }
      if (await canLaunch(urlbaiduIos)) {
        list.add({'url': urlbaiduIos, 'title': '百度地图'});
      }
    }
    if (Platform.isAndroid) {
      var urlbaiduAndroid =
          'bdapp://map/marker?location=${widget.arguments['store']['latitude']},${widget.arguments['store']['longitude']}&title=${widget.arguments['store']['name']}&content=${widget.arguments['store']['address']}&src=andr.baidu.openAPIdemo'; // 百度地图
      var urlgaodeAndroid =
          'androidamap://navi?sourceApplication=团个车&poiname=${widget.arguments['store']['name']}&lat=${widget.arguments['store']['latitude']}&lon=${widget.arguments['store']['longitude']}&dev=0';
      if (await canLaunch(urlgaodeAndroid)) {
        list.add({'url': urlgaodeAndroid, 'title': '高德地图'});
      }
      if (await canLaunch(urlbaiduAndroid)) {
        list.add({'url': urlbaiduAndroid, 'title': '百度地图'});
      }
    }
  }

  @override
  void dispose() {
    TalkingDataAppAnalytics.onPageEnd('门店详情');
    super.dispose();
  }

  getlistWidget() {
    List<Widget> lists = [];
    Widget content;
    for (var item in list) {
      lists.add(ListTile(
        title: Text('${item['title']}', textAlign: TextAlign.center),
        onTap: () async {
          if (await canLaunch(item['url'])) {
            // 判断当前手机是否安装某app. 能否正常跳转
            await launch(item['url']);
          } else {
            Toast.show('请安装相关地图APP～', context,
                backgroundColor: Color(0xff5b5956),
                backgroundRadius: Ui.width(16),
                duration: Toast.LENGTH_SHORT,
                gravity: Toast.CENTER);
          }
        },
      ));
    }
    lists.add(ListTile(
      title: Text('取消', textAlign: TextAlign.center),
      onTap: () {
        Navigator.pop(context, '取消');
      },
    ));
    content = new Column(
      children: lists,
      mainAxisAlignment: MainAxisAlignment.center,
    );
    return content;
  }

  Future _openModalBottomSheet() async {
    final option = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(height: 200.0, child: getlistWidget());
        });

    print(option);
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '门店详情',
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
      ),
      body: Container(
          color: Colors.white,
          // padding: EdgeInsets.fromLTRB(Ui.width(24), 0, Ui.width(24), 0),
          child: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Container(
                    width: Ui.width(750),
                    height: Ui.width(375),
                    alignment: Alignment.center,
                    child: widget.arguments['store']['gallery'].length == 0
                        ? Container(
                            child: CachedNetworkImage(
                                width: Ui.width(750),
                                height: Ui.width(375),
                                fit: BoxFit.fill,
                                imageUrl:
                                    "https://tuangeche.oss-cn-qingdao.aliyuncs.com/7bvsgvhse8ntuczukpsc.png"),
                            // decoration: BoxDecoration(
                            //   image: DecorationImage(
                            //     image: NetworkImage(
                            //         "https://tuangeche.oss-cn-qingdao.aliyuncs.com/7bvsgvhse8ntuczukpsc.png?x-oss-process=image/resize,p_70"),
                            //     fit: BoxFit.fill,
                            //   ),
                            // ),
                          )
                        : Swiper(
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                  onTap: () {
                                    print('object');
                                  },
                                  child: Container(
                                    child: CachedNetworkImage(
                                        width: Ui.width(750),
                                        height: Ui.width(375),
                                        fit: BoxFit.fill,
                                        imageUrl:
                                            "${widget.arguments['store']['gallery'][index]}"),
                                    // decoration: BoxDecoration(
                                    //   image: DecorationImage(
                                    //     image: NetworkImage(
                                    //         '${widget.arguments['store']['gallery'][index]}?x-oss-process=image/resize,p_70'),
                                    //     fit: BoxFit.fill,
                                    //   ),
                                    // ),
                                  ));
                            },
                            itemCount:
                                widget.arguments['store']['gallery'].length,
                            autoplay:
                                widget.arguments['store']['gallery'].length > 1
                                    ? true
                                    : false,
                            pagination: SwiperPagination(
                              alignment: Alignment.bottomCenter,
                              builder: new SwiperCustomPagination(builder:
                                  (BuildContext context,
                                      SwiperPluginConfig config) {
                                return new PageIndicator(
                                  layout: PageIndicatorLayout.NIO,
                                  size: 8.0,
                                  space: 15.0,
                                  count: widget
                                      .arguments['store']['gallery'].length,
                                  color: Color.fromRGBO(255, 255, 255, 0.4),
                                  activeColor: Color(0XFF111F37),
                                  controller: config.pageController,
                                );
                              }),
                            )),
                  ),
                  InkWell(
                    onTap: () async {
                      if (list.length == 0) {
                        Toast.show('请安装相关地图APP～', context,
                            backgroundColor: Color(0xff5b5956),
                            backgroundRadius: Ui.width(16),
                            duration: Toast.LENGTH_SHORT,
                            gravity: Toast.CENTER);
                      } else {
                        _openModalBottomSheet();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(Ui.width(30), Ui.width(25),
                          Ui.width(30), Ui.width(25)),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: Ui.width(16),
                                  color: Color(0xFFF8F9FB)))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width: Ui.width(590),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${widget.arguments['store']['name']}',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(38.0)),
                                      ),
                                      SizedBox(height: Ui.width(10)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(84),
                                            alignment: Alignment.center,
                                            height: Ui.width(36),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFD92818),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Ui.width(4)),
                                            ),
                                            child: Text(
                                              '代理商',
                                              style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      22.0)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: Ui.width(20),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  '总评分',
                                                  style: TextStyle(
                                                      color: Color(0xFF6A7182),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                ),
                                                Text(
                                                  ' ${widget.arguments['store']['star']}',
                                                  style: TextStyle(
                                                      color: Color(0xFFD92818),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              26.0)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: Ui.width(40),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  '总订单',
                                                  style: TextStyle(
                                                      color: Color(0xFF6A7182),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                ),
                                                Text(
                                                  ' ${widget.arguments['store']['sales']}',
                                                  style: TextStyle(
                                                      color: Color(0xFFD92818),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              26.0)),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset(
                                        'images/2.0x/adress.png',
                                        width: Ui.width(50),
                                        height: Ui.width(50),
                                      ),
                                      SizedBox(
                                        height: Ui.width(6),
                                      ),
                                      Text(
                                        '${widget.arguments['store']['distance']}km',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(24.0)),
                                      ),
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                          SizedBox(height: Ui.width(10)),
                          Container(
                            child: Text(
                              '${widget.arguments['store']['address']}',
                              style: TextStyle(
                                  color: Color(0xFF6A7182),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(24.0)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      Ui.width(30),
                      Ui.width(30),
                      Ui.width(30),
                      Ui.width(110),
                    ),
                    child: Html(
                      data: widget.arguments['store']['detail'] != null
                          ? '<div>${widget.arguments['store']['detail'].replaceAll('height="', '')}</div>'
                          : '暂无门店详情～，请联系客服。',
                    ),
                  )
                ],
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: InkWell(
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
                      height: Ui.width(90),
                      width: Ui.width(750),
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
                        '联系门店',
                        style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(32.0)),
                      ),
                    ),
                  ))
            ],
          )),
    );
  }
}
