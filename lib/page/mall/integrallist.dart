import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/Nofind.dart';
import 'package:toast/toast.dart';

class Integrallist extends StatefulWidget {
  final Map arguments;
  Integrallist({Key key, this.arguments}) : super(key: key);

  @override
  _IntegrallistState createState() => _IntegrallistState();
}

class _IntegrallistState extends State<Integrallist> {
  ScrollController _scrollController = new ScrollController();

  int active = 1;
  int solt = 2;
  bool nolist = true;
  bool isMore = true;
  int page = 1;
  int limit = 10;
  List list = [];
  String points = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print(widget.arguments['title']);
    // print(widget.arguments['minPoints']);
    // print(widget.arguments['maxPoints']);
    _scrollController.addListener(() {
      // print(_scrollController.position.pixels); //获取滚动条下拉的距离
      // print(_scrollController.position.maxScrollExtent); //获取整个页面的高度
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 60) {
        // print(_scrollController.position.pixels);
        if (nolist) {
          getData();
        }
        setState(() {
          isMore = false;
        });
      }
    });
    getData();
  }

  getData() {
    if (isMore) {
      HttpUtlis.get(
          'wx/points/goods?&page=${page}&limit=${limit}&minPoints=${widget.arguments['minPoints']}&maxPoints=${widget.arguments['maxPoints']}&sortMap={points:${points}}',
          success: (value) {
        if (value['errno'] == 0) {
          // print(value['data']['list'].length);
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

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.arguments['title']}',
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
        body: Stack(
          children: <Widget>[
            Container(
              color: Color(0xFFF8F9FB),
              padding: EdgeInsets.fromLTRB(
                  Ui.width(30), Ui.width(110), Ui.width(30), Ui.width(20)),
              child: list.length > 0
                  ? ListView(
                      controller: _scrollController,
                      children: <Widget>[
                        Wrap(
                            runSpacing: Ui.width(20),
                            spacing: Ui.width(20),
                            children: list.map((val) {
                              //asMap().keys
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/goodsdetail',
                                      arguments: {
                                        "id": val['id'],
                                      });
                                },
                                child: Container(
                                  width: Ui.width(335),
                                  height: Ui.width(500),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(Ui.width(10.0)))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // Text('${val}'),
                                      Container(
                                          width: Ui.width(335),
                                          height: Ui.width(335),
                                          // color: Colors.red,
                                          child: CachedNetworkImage(
                                              width: Ui.width(335),
                                              height: Ui.width(335),
                                              fit: BoxFit.fill,
                                              imageUrl: '${val["picUrl"]}')
                                          // AspectRatio(
                                          //     aspectRatio: 1 / 1,
                                          //     child: Image.network(
                                          //         '${val["picUrl"]}')),
                                          ),
                                      Container(
                                        padding: EdgeInsets.fromLTRB(
                                            Ui.width(20), 0, Ui.width(20), 0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            //  SizedBox(
                                            //   height: Ui.width(6),
                                            // ),
                                            // Text(
                                            //   'ipip',
                                            //   style: TextStyle(
                                            //       color: Color(0xFF111F37),
                                            //       fontWeight: FontWeight.w500,
                                            //       fontFamily:
                                            //           'PingFangSC-Medium,PingFang SC',
                                            //       fontSize:
                                            //           Ui.setFontSizeSetSp(28.0)),
                                            // ),
                                            SizedBox(
                                              height: Ui.width(5),
                                            ),
                                            Text(
                                              '${val['name']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      28.0)),
                                            ),
                                            SizedBox(
                                              height: Ui.width(20),
                                            ),
                                            Text(
                                              '${val["points"]}积分+${val["retailPrice"]}元',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(0xFFD10123),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      28.0)),
                                            ),
                                            SizedBox(
                                              height: Ui.width(6),
                                            ),
                                            Text(
                                              '${val["counterPrice"]}元',
                                              style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  color: Color(0xFF9398A5),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      22.0)),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.fromLTRB(0, Ui.width(60), 0, 0),
                          child: !nolist ? Text('我是有底线的哦～') : Text(''),
                        )
                      ],
                    )
                  : Nofind(
                      text: "没有更多商品哦～",
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                color: Color(0xFFFFFFFF),
                // color: Colors.red,
                width: Ui.width(750),
                height: Ui.width(90),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              active = 1;
                              points = '';
                              page = 1;
                              list = [];
                              isMore = true;
                            });
                            getData();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '推荐',
                              style: TextStyle(
                                  color: active == 1
                                      ? Color(0xFFD10123)
                                      : Color(0xFF333333),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            String solts = points == ''
                                ? 'asc'
                                : points == 'asc' ? 'desc' : 'asc';
                            setState(() {
                              active = 2;
                              points = solts;
                              page = 1;
                              list = [];
                              isMore = true;
                            });
                            getData();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '积分排序',
                                  style: TextStyle(
                                      color: active == 2
                                          ? Color(0xFFD10123)
                                          : Color(0xFF333333),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      Ui.width(35.0), Ui.width(5.0), 0, 0),
                                  child: active == 2
                                      ? points == 'asc'
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Image.asset(
                                                  'images/2.0x/topselect.png',
                                                  width: Ui.width(21.0),
                                                  height: Ui.width(9.0),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(10),
                                                ),
                                                Image.asset(
                                                  'images/2.0x/bottom.png',
                                                  width: Ui.width(21.0),
                                                  height: Ui.width(9.0),
                                                )
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Image.asset(
                                                  'images/2.0x/top.png',
                                                  width: Ui.width(21.0),
                                                  height: Ui.width(9.0),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(10),
                                                ),
                                                Image.asset(
                                                  'images/2.0x/bottomselect.png',
                                                  width: Ui.width(21.0),
                                                  height: Ui.width(9.0),
                                                )
                                              ],
                                            )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              'images/2.0x/top.png',
                                              width: Ui.width(21.0),
                                              height: Ui.width(9.0),
                                            ),
                                            SizedBox(
                                              height: Ui.width(10),
                                            ),
                                            Image.asset(
                                              'images/2.0x/bottom.png',
                                              width: Ui.width(21.0),
                                              height: Ui.width(9.0),
                                            )
                                          ],
                                        ),
                                )
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
