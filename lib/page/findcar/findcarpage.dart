import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
// import 'package:amap_location/amap_location.dart';
// import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

class Findcarpage extends StatefulWidget {
  Findcarpage({Key key}) : super(key: key);

  @override
  _FindcarpageState createState() => _FindcarpageState();
}

class _FindcarpageState extends State<Findcarpage> with AutomaticKeepAliveClientMixin{
  @override bool get wantKeepAlive => true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  EasyRefreshController _controller;
  int avtive = 0;
  bool isloading = false;
  List hotCar = [];
  // List footprint = [];
  List brandGroups = [];
  var items = {};
  List listname = [];
  List listall = [];
  List listitem = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (Platform.isIOS) {
    //   AMapLocationClient.setApiKey("810afd6d200f01c90313503cdeb5130e");
    //   //ios相关代码
    // } else if (Platform.isAndroid) {
    //   //android相关代码
    // }
    _controller = EasyRefreshController();
    hotCategories();
    // prints();
    getData();
  }

  hotCategories() async {
    await HttpUtlis.get('wx/catalog/hotCategories', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          hotCar = value['data'];
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

  // prints() async {
  //   await HttpUtlis.get('wx/footprint/list', success: (value) {
  //     if (value['errno'] == 0) {
  //       setState(() {
  //         footprint = value['data']['list'];
  //       });
  //     }
  //   }, failure: (error) {
  //     Toast.show('${error}', context,
  //         backgroundColor: Color(0xff5b5956),
  //         backgroundRadius: Ui.width(16),
  //         duration: Toast.LENGTH_SHORT,
  //         gravity: Toast.CENTER);
  //   });
  // }

  Widget titlenew(value) {
    return Text(
      value,
      style: TextStyle(
          color: Color(0XFF111F37),
          fontSize: Ui.setFontSizeSetSp(42),
          fontWeight: FontWeight.w500,
          fontFamily: 'PingFangSC-Regular,PingFang SC;'),
    );
  }

  getData() async {
    await HttpUtlis.get('wx/brand/groups', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          brandGroups = value['data'];
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

  detailData(item) async {
    await HttpUtlis.get('wx/catalog/listByBrandId?brandId=${item['id']}',
        success: (value) {
      // print(value['data']);
      if (value['errno'] == 0) {
        var list = ['全部'];
        for (var i = 0, len = value['data'].length; i < len; i++) {
          list.add(value['data'][i]['name']);
        }
        setState(() {
          listname = list;
          avtive = 0;
          listall = value['data'];
          listitem = value['data'];
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

  getlist(list) {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var item in list) {
      tiles.add(InkWell(
        onTap: () {
          setState(() {
            items = item;
          });
          detailData(item);
          _scaffoldKey.currentState.openEndDrawer();
        },
        child: Container(
          width: Ui.width(750),
          height: Ui.height(90),
          color: Color(0xFFFFFFFF),
          // padding:EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(Ui.width(40), 0, 0, 0),
                child: Row(
                  children: <Widget>[
                    Container(
                      child: CachedNetworkImage(
                        width: Ui.width(70),
                        // height: Ui.width(220),
                        // fit: BoxFit.fill,
                        imageUrl: '${item['picUrl']}',
                      ),
                    ),

                    // Image.network(
                    //   '${item['picUrl']}',
                    //   width: Ui.width(70),
                    // ),
                    SizedBox(
                      width: Ui.width(20),
                    ),
                    Text('${item['name']}',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontSize: Ui.setFontSizeSetSp(30),
                            fontFamily: 'PingFangSC-Regular,PingFang SC'))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, Ui.width(40), 0),
                child: Row(
                  children: <Widget>[
                    Text('历史成交${item['saleCount']}+',
                        style: TextStyle(
                            color: Color(0xFFC4C9D3),
                            fontSize: Ui.setFontSizeSetSp(26),
                            fontFamily: 'PingFangSC-Regular,PingFang SC')),
                    Icon(
                      Icons.chevron_right,
                      size: Ui.setFontSizeSetSp(36),
                      color: Color(0xFFC4C9D3),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ));
    }
    content = new Column(children: tiles);
    return content;
  }

  getitemlist(list) {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var item in list) {
      tiles.add(InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/vehicletype', arguments: {
              "item": item,
            });
          },
          child: Container(
            width: double.infinity,
            height: Ui.width(200),
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                Ui.width(30), Ui.width(30), Ui.width(30), 0),
            child: Row(
              children: <Widget>[
                Container(
                  width: Ui.width(225),
                  height: Ui.height(170),
                  // color: Colors.red,
                  margin: EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                  // child:
                  // AspectRatio(
                  // aspectRatio: 4 / 3,
                  child:  CachedNetworkImage(
                        width: Ui.width(225),
                         height: Ui.height(170),
                        fit: BoxFit.fill,
                        imageUrl: '${item['picUrl']}',
                      ),
                  // Image.network('${item['picUrl']}'),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              '${item['name']}',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(34.0)),
                            ),
                          ),
                          RichText(
                            textAlign: TextAlign.end,
                            text: TextSpan(
                              text: '${item['priceRange']}',
                              style: TextStyle(
                                  color: Color(0xFFD10123),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(28.0)),
                              children: <TextSpan>[
                                // TextSpan(
                                //     text: '起',
                                //     style: TextStyle(
                                //         color: Color(0xFFD10123),
                                //         fontWeight: FontWeight.w400,
                                //         fontFamily:
                                //             'PingFangSC-Medium,PingFang SC',
                                //         fontSize: Ui.setFontSizeSetSp(22.0))),
                              ],
                            ),
                          ),
                          Container(
                            width: Ui.width(140),
                            height: Ui.width(32),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF3F5),
                              border: Border.all(
                                  width: Ui.width(1), color: Color(0xffD10123)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              '在售${item['saleCount']}款车型',
                              style: TextStyle(
                                  color: Color(0xFFD10123),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(20.0)),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          )));
    }
    content = new Column(children: tiles);
    return content;
  }

  List<Widget> getband() {
    return brandGroups.map((value) {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              width: Ui.width(710),
              height: Ui.height(50),
              color: Color(0xFFF8F9FB),
              padding: EdgeInsets.fromLTRB(Ui.width(40), 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${value['key']}',
                      style: TextStyle(
                          color: Color(0xFFC4C9D3),
                          fontSize: Ui.setFontSizeSetSp(32),
                          fontFamily: 'PingFangSC-Regular,PingFang SC'))
                ],
              ),
            ),
            Container(child: getlist(value['brands'])),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
            title: Text(
              '找车',
              style: TextStyle(
                  color: Color(0xFF111F37),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                  fontSize: Ui.setFontSizeSetSp(36.0)),
            ),
            centerTitle: true,
            elevation: 0,
            brightness: Brightness.light,
            leading: Text('')),
        body: Scaffold(
          key: _scaffoldKey,
          drawerEdgeDragWidth: 0.0,
          endDrawer: Drawer(
            child: Container(
              height: double.infinity,
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  Container(
                    height: Ui.width(100),
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                               Container(
                      child: CachedNetworkImage(
                        width: Ui.width(70),
                        // height: Ui.width(220),
                        // fit: BoxFit.fill,
                        imageUrl: '${items['picUrl']}',
                      ),
                    ),
                              // Image.network(
                              //   '${items['picUrl']}',
                              //   width: Ui.width(70),
                              // ),
                              SizedBox(
                                width: Ui.width(20),
                              ),
                              Text(
                                '${items['name']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontSize: Ui.setFontSizeSetSp(30),
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Text.rich(TextSpan(
                                  text: '成交数',
                                  style: TextStyle(
                                      color: Color(0xFF9398A5),
                                      fontSize: Ui.setFontSizeSetSp(26),
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontWeight: FontWeight.w400),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${items['saleCount']}',
                                      style: TextStyle(
                                        color: Color(0xFFD10123),
                                      ),
                                    ),
                                    TextSpan(text: '笔')
                                  ]))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: Ui.width(16),
                    color: Color(0XFFF8F9FB),
                  ),
                  Container(
                      width: double.infinity,
                      height: Ui.width(76),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: listname.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                avtive = index;
                                listitem =
                                    index == 0 ? listall : [listall[index - 1]];
                              });
                            },
                            child: Container(
                              height:
                                  avtive == index ? Ui.width(76) : Ui.width(76),
                              alignment: Alignment.center,
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(80), 0, Ui.width(40), 0),
                              decoration: BoxDecoration(
                                  border: avtive == index
                                      ? Border(
                                          bottom: BorderSide(
                                              width: Ui.width(6),
                                              color: Color(0xffD10123)))
                                      : Border(
                                          bottom: BorderSide(
                                              width: Ui.width(0),
                                              color: Color(0xffFFFFFF)))),
                              child: Text(
                                '${listname[index]}',
                                style: TextStyle(
                                  color: avtive == index
                                      ? Color(0xFFD10123)
                                      : Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(26),
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                  Container(
                    child: Column(
                        children: listitem.map((val) {
                      return Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: Ui.width(60),
                              padding:
                                  EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                              color: Color(0XFFF8F9FB),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${val['name']}',
                                style: TextStyle(
                                  color: Color(0xFF9398A5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(24),
                                ),
                              ),
                            ),
                            Container(
                              child: getitemlist(val['children']),
                            )
                          ],
                        ),
                      );
                    }).toList()),
                  )
                ],
              ),
            ),
          ),
          body: EasyRefresh(
            enableControlFinishRefresh: false,
            enableControlFinishLoad: true,
            controller: _controller,
            header: ClassicalHeader(
              // enableInfiniteRefresh: false,
              refreshText: '下拉刷新哦～',
              refreshReadyText: '下拉刷新哦～',
              refreshingText: '加载中～',
              refreshedText: '加载完成',
              // refreshFailedText: FlutterI18n.translate(context, 'refreshFailed'),
              // noMoreText: FlutterI18n.translate(context, 'noMore'),
              infoText: "更新时间 %T",
              // bgColor: _headerFloat ? Theme.of(context).primaryColor : null,
              //   infoColor: _headerFloat ? Colors.black87 : Colors.teal,
              //   float: _headerFloat,
              infoColor: Color(0XFF111F37),
              textColor: Color(0XFF111F37),
            ),
            // // footer: ClassicalFooter(),
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 2), () {
                print('111');
                // setState(() {
                //   _count = 20;
                // });
                _controller.resetLoadState();
              });
            },
            child: isloading
                ? ListView(
                    children: <Widget>[
                      Container(
                        color: Color(0XFFFFFFFF),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(40), 0, 0),
                        child: titlenew('热门车型'),
                      ),
                      Container(
                        color: Color(0XFFFFFFFF),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(30), Ui.width(0), 0),
                        child: Wrap(
                            children: hotCar.map((val) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/vehicletype',
                                  arguments: {
                                    "item": val,
                                  });
                            },
                            child: Container(
                              width: Ui.width(200),
                              margin: EdgeInsets.fromLTRB(
                                  0, Ui.width(40), Ui.width(35), 0),
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: Ui.width(200),
                                      height: Ui.width(150),
                                      child: CachedNetworkImage(
                                          width: Ui.width(390),
                                          height: Ui.width(220),
                                          fit: BoxFit.fill,
                                          imageUrl: '${val['picUrl']}'),
                                      // decoration: BoxDecoration(
                                      //     image: DecorationImage(
                                      //         fit: BoxFit.cover,
                                      //         image: NetworkImage(
                                      //             '${val['picUrl']}?x-oss-process=image/resize,p_70'))),
                                    ),
                                    SizedBox(
                                      height: Ui.width(5),
                                    ),
                                    Text(
                                      '${val['name']}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontSize: Ui.setFontSizeSetSp(24),
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList()),
                      ),
                      // Container(
                      //   color: Color(0XFFFFFFFF),
                      //   height: Ui.width(150),
                      //   padding: EdgeInsets.fromLTRB(
                      //       Ui.width(40), Ui.width(50), Ui.width(40), 0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: <Widget>[
                      //       Container(
                      //         height: Ui.width(60),
                      //         margin:
                      //             EdgeInsets.fromLTRB(0, 0, Ui.width(70), 0),
                      //         alignment: Alignment.center,
                      //         child: Text(
                      //           '看过:',
                      //           overflow: TextOverflow.ellipsis,
                      //           maxLines: 1,
                      //           style: TextStyle(
                      //               color: Color(0xFF111F37),
                      //               fontSize: Ui.setFontSizeSetSp(30),
                      //               fontFamily: 'PingFangSC-Medium,PingFang SC',
                      //               fontWeight: FontWeight.w500),
                      //         ),
                      //       ),
                      //       Expanded(
                      //           flex: 1,
                      //           child: Container(
                      //               child: ListView.builder(
                      //             scrollDirection: Axis.horizontal,
                      //             itemCount: footprint.length,
                      //             itemBuilder: (context, index) {
                      //               return InkWell(
                      //                 onTap: () {
                      //                   Navigator.pushNamed(
                      //                       context, '/cardetail',
                      //                       arguments: {
                      //                         "id": footprint[index]['goodsId'],
                      //                       });
                      //                 },
                      //                 child: Container(
                      //                   padding: EdgeInsets.fromLTRB(0,
                      //                       Ui.width(20.0), 0, Ui.width(20.0)),
                      //                   child: Container(
                      //                     height: Ui.width(60),
                      //                     margin: EdgeInsets.fromLTRB(
                      //                         0, 0, Ui.width(40.0), 0),
                      //                     padding: EdgeInsets.fromLTRB(
                      //                         Ui.width(20.0),
                      //                         0,
                      //                         Ui.width(20.0),
                      //                         0),
                      //                     child: Center(
                      //                       child: Text(
                      //                           '${footprint[index]['name']}',
                      //                           style: TextStyle(
                      //                               color: Color(0xFF111F37),
                      //                               fontSize:
                      //                                   Ui.setFontSizeSetSp(24),
                      //                               fontFamily:
                      //                                   'PingFangSC-Medium,PingFang SC',
                      //                               fontWeight:
                      //                                   FontWeight.w400)),
                      //                     ),
                      //                     decoration: BoxDecoration(
                      //                         color: Colors.white,
                      //                         borderRadius: BorderRadius.all(
                      //                             Radius.circular(
                      //                                 Ui.width(60.0))),
                      //                         shape: BoxShape.rectangle,
                      //                         boxShadow: [
                      //                           BoxShadow(
                      //                             color: Color(0XFFDFE3EC),
                      //                             offset: Offset(1, 1),
                      //                             blurRadius: Ui.width(20.0),
                      //                           ),
                      //                         ]),
                      //                   ),
                      //                 ),
                      //               );
                      //             },
                      //           )))
                      //     ],
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(50), 0, Ui.width(40)),
                        color: Color(0XFFFFFFFF),
                        child: titlenew('品牌选择'),
                      ),
                      Container(
                        child: Column(children: getband()),
                      )
                    ],
                  )
                : Container(
                    margin: EdgeInsets.fromLTRB(0, 200, 0, 0),
                    child: LoadingDialog(
                      text: "加载中…",
                    ),
                  ),
          ),
        ));
  }
}
