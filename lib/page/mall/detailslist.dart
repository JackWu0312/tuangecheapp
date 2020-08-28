import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
// import '../../common/Storage.dart';
// import '../../common/LoadingDialog.dart';
import '../../common/Nofind.dart';
import 'package:toast/toast.dart';
import 'dart:io';

class Detailslist extends StatefulWidget {
  final Map arguments;
  Detailslist({Key key, this.arguments}) : super(key: key);

  @override
  _DetailslistState createState() => _DetailslistState();
}

class _DetailslistState extends State<Detailslist> {
  ScrollController _scrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int active = 1;
  int brand;
  String brandIds = '';
  String minPrice = '';
  String maxPrice = '';
  String points = '';
  int page = 1;
  int limit = 10;
  List list = [];
  List brandlist = [];
  var _initminController = new TextEditingController();
  var _initmaxController = new TextEditingController();
  // bool isloading = false;
  bool nolist = true;
  bool isMore = true;
  int style = 1; //1 ios 2安卓
  void initState() {
    super.initState();
    // print(widget.arguments['title']);
    // _controller = EasyRefreshController();
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
    getBrands();
    getstyle();
  }

  getstyle() {
    if (Platform.isIOS) {
      setState(() {
        style = 1;
      });
    } else if (Platform.isAndroid) {
      setState(() {
        style = 2;
      });
    }
  }

  getData() {
    // setState(() {
    //   isloading = false;
    // });
    if (isMore) {
      HttpUtlis.get(
          'wx/points/goods?name=${widget.arguments['title']}&brandIds=${brandIds}&categoryIds=${widget.arguments['id']}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortMap={points:${points}}&page=${page}&limit=${limit}',
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
      // setState(() {
      //   this.isloading = true;
      // });
    }
  }

  getBrands() {
    // print(widget.arguments['id'] is String);
    HttpUtlis.get(
        'wx/points/getBrandsByCategory?categoryId=${widget.arguments['id']}',
        success: (value) {
      //  print(value['data']);

      if (value['errno'] == 0) {
        List list = value['data'].map((val) {
          val['active'] = false;
          return val;
        }).toList();
        setState(() {
          brandlist = list;
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

  reset() {
    List list = brandlist.map((val) {
      val['active'] = false;
      return val;
    }).toList();
    setState(() {
      brandlist = list;
    });
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Scaffold(
            key: _scaffoldKey,
            drawerEdgeDragWidth: 0.0,
            endDrawer: Drawer(
              child: Container(
                width: Ui.width(610),
                height: double.infinity,
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: ListView(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), Ui.width(40), 0, Ui.width(40)),
                            child: Text(
                              '品牌',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(28.0)),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), 0, Ui.width(30), 0),
                            child: Wrap(
                                runSpacing: Ui.width(20),
                                spacing: Ui.width(20),
                                children: brandlist.asMap().keys.map((index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        brandlist[index]['active'] =
                                            !brandlist[index]['active'];
                                      });
                                      List lists = brandIds.split(',');
                                      if (brandlist[index]['active']) {
                                        lists.add(brandlist[index]['id']);
                                      } else {
                                        lists.remove(brandlist[index]['id']);
                                      }
                                      String str = lists.join(",");
                                      if (str != '') {
                                        if (str[0] == ',') {
                                          str = str.substring(1);
                                        }
                                      }

                                      setState(() {
                                        page = 1;
                                        list = [];
                                        isMore = true;
                                        brandIds = str;
                                      });
                                      print(brandIds);
                                      getData();
                                    },
                                    child: Container(
                                      height: Ui.width(60),
                                      padding: EdgeInsets.fromLTRB(
                                          Ui.width(30), 0, Ui.width(30), 0),
                                      decoration: BoxDecoration(
                                          color: brandlist[index]['active']
                                              ? Color(0xFFFFF5F6)
                                              : Color(0xFFF8F9FB),
                                          borderRadius: BorderRadius.circular(
                                              Ui.width(7)),
                                          border: brandlist[index]['active']
                                              ? Border.all(
                                                  color: Color(0xFFD10123),
                                                  width: Ui.width(1))
                                              : Border.all(
                                                  color: Color(0xFFF8F9FB),
                                                  width: Ui.width(1))),
                                      child: Container(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '${brandlist[index]['name']}',
                                            style: TextStyle(
                                                color: brandlist[index]
                                                        ['active']
                                                    ? Color(0xFFD10123)
                                                    : Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(26.0)),
                                          ),
                                        ],
                                      )),
                                    ),
                                  );
                                }).toList()),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), Ui.width(40), 0, Ui.width(40)),
                            child: Text(
                              '价格',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(28.0)),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: Ui.width(195),
                                  height: Ui.width(60),
                                  child: TextField(
                                    controller: this._initminController,
                                    style: TextStyle(
                                        color: Color(0XFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontSize: Ui.setFontSizeSetSp(28)),
                                    textAlign: TextAlign.center,
                                    keyboardAppearance: Brightness.light,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: '最低价',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFC4C9D3),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0),
                                      ),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Color(0xFFF8F9FB),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          style == 1
                                              ? Ui.width(26)
                                              : Ui.width(30)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFF8F9FB)),
                                        borderRadius:
                                            BorderRadius.circular(Ui.width(7)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFF8F9FB)),
                                        borderRadius:
                                            BorderRadius.circular(Ui.width(7)),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        minPrice = value;
                                        page = 1;
                                        list = [];
                                        isMore = true;
                                      });
                                      getData();
                                    },
                                  ),
                                ),
                                Container(
                                  width: Ui.width(60),
                                  height: Ui.width(1),
                                  color: Color(0xFF9398A5),
                                  margin: EdgeInsets.fromLTRB(
                                      Ui.width(25), 0, Ui.width(25), 0),
                                ),
                                Container(
                                  width: Ui.width(195),
                                  height: Ui.width(60),
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        maxPrice = value;
                                        page = 1;
                                        list = [];
                                        isMore = true;
                                      });
                                      getData();
                                    },
                                    controller: this._initmaxController,
                                    style: TextStyle(
                                        color: Color(0XFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontSize: Ui.setFontSizeSetSp(28)),
                                    textAlign: TextAlign.center,
                                    keyboardAppearance: Brightness.light,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: '最高价',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFC4C9D3),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0),
                                      ),
                                      border: InputBorder.none,
                                      filled: true,
                                      fillColor: Color(0xFFF8F9FB),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          0,
                                          style == 1
                                              ? Ui.width(26)
                                              : Ui.width(30)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFF8F9FB)),
                                        borderRadius:
                                            BorderRadius.circular(Ui.width(7)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xFFF8F9FB)),
                                        borderRadius:
                                            BorderRadius.circular(Ui.width(7)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: Ui.width(22),
                      left: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(30), 0, Ui.width(30), 0),
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  points = '';
                                  brandIds = '';
                                  minPrice = '';
                                  maxPrice = '';
                                  page = 1;
                                  list = [];
                                  isMore = true;
                                });
                                getData();
                                reset();
                                _initminController.text = '';
                                _initmaxController.text = '';
                              },
                              child: Container(
                                width: Ui.width(196),
                                height: Ui.width(84),
                                alignment: Alignment.center,
                                child: Text(
                                  '重置',
                                  style: TextStyle(
                                      color: Color(0xFFD10123),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    border: Border.all(
                                        color: Color(0xFFD10123),
                                        width: Ui.width(1)),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(Ui.width(8.0)))),
                              ),
                            ),
                            SizedBox(
                              width: Ui.width(20),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: Ui.width(284),
                                height: Ui.width(84),
                                alignment: Alignment.center,
                                child: Text(
                                  '确定',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                                decoration: BoxDecoration(
                                    color: Color(0xFFD10123),
                                    border: Border.all(
                                        color: Color(0xFFD10123),
                                        width: Ui.width(1)),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(Ui.width(8.0)))),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  color: Color(0xFFF8F9FB),
                  // color: Colors.red,
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
                                      Navigator.pushNamed(
                                          context, '/goodsdetail',
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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

                                              //  AspectRatio(
                                              //     aspectRatio: 1 / 1,
                                              //     child: Image.network(
                                              //         '${val["picUrl"]}')),
                                              ),
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                Ui.width(20),
                                                0,
                                                Ui.width(20),
                                                0),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(0xFF111F37),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              28.0)),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(20),
                                                ),
                                                Text(
                                                  '${val["points"]}积分+${val["retailPrice"]}元',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(0xFFD10123),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
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
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
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
                              margin:
                                  EdgeInsets.fromLTRB(0, Ui.width(60), 0, 0),
                              child: !nolist ? Text('我是有底线的哦～') : null,
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
                                  brandIds = '';
                                  minPrice = '';
                                  maxPrice = '';
                                  page = 1;
                                  list = [];
                                  isMore = true;
                                });
                                getData();
                                reset();
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
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
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
                                  brandIds = '';
                                  minPrice = '';
                                  maxPrice = '';
                                  page = 1;
                                  list = [];
                                  isMore = true;
                                });
                                getData();
                                reset();
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
                        Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  active = 3;
                                  points = '';
                                  // brandIds = '';
                                  // minPrice = '';
                                  // maxPrice = '';
                                });
                                _scaffoldKey.currentState.openEndDrawer();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '筛选',
                                  style: TextStyle(
                                      color: active == 3
                                          ? Color(0xFFD10123)
                                          : Color(0xFF333333),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
