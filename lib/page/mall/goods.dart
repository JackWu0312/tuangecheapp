import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import '../../common/Storage.dart';
import 'package:provider/provider.dart';
import '../../provider/Addressselect.dart';
import 'dart:io';
import 'package:flutter_html/flutter_html.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/Carnum.dart';
import '../../provider/Successlogin.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../config/config.dart';
import '../../common/CommonBottomSheet.dart';

class Goods extends StatefulWidget {
  final Map arguments;
  Goods({Key key, this.arguments}) : super(key: key);
  @override
  _GoodsState createState() => _GoodsState();
}

class _GoodsState extends State<Goods> with SingleTickerProviderStateMixin {
  var _initKeywordsController = new TextEditingController();
  TabController _tabController;
  bool isloading = false;
  String nums = '1';
  List listAllimage = [];
  List list = [];
  int points = 0;
  double retailPrice = 0;
  double price = 0;
  int style = 1; //1 ios 2安卓
  var data;
  var limit;
  Map specifications = {};
  // var retailPrice=0;
  // List products = [];
  var productsgoods = [];
  var goodIds = '';
  var objkey = {};
  var stringnum = '';
  var picUrl = '';
  var count = 0;
  var flages = true;
  // var tips = '';
  StreamSubscription<WeChatShareResponse> _wxlogin;

  void initState() {
    super.initState();
    this._initKeywordsController.text = nums;
    _tabController = TabController(length: 2, vsync: this);
    getData();
    // getcount();
    getstyle();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxlogin = fluwx.responseFromShare.listen((data) {
      if (data.errCode == 0) {
        print('分享成功！');
        getShare();
      }
    });
  }

  getShare() {
    HttpUtlis.post("wx/share/callback",
        params: {'dataId': widget.arguments['id'], 'type': 2, 'platform': 1},
        success: (value) async {
      if (value['errno'] == 0) {
        print('分享成功～');
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  void dispose() {
    _wxlogin.cancel();
    super.dispose();
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

  calculate(setBottomState) async {
    if (nums == '') {
      setState(() {
        nums = '1';
      });
    }
    await HttpUtlis.post('wx/goods/calculate',
        params: {'id': goodIds, 'number': int.parse(nums)}, success: (value) {
      if (value['errno'] == 0) {
        setBottomState(() {
          retailPrice = value['data']['price'];
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
    print(widget.arguments['id']);
    await HttpUtlis.get('wx/goods/${widget.arguments['id']}', success: (value) {
      if (value['errno'] == 0) {
        var datas = value['data']['specifications'];
        // print(json.encode(value['data']['specifications'])=='{}');
        // print(json.encode(value['data']['specifications']));
        // var tip = '';
        if (json.encode(value['data']['specifications']) != '{}') {
          for (var key in datas.keys) {
            // tip += key;
            for (int i = 0, len = datas['${key}'].length; i < len; i++) {
              if (i == 0) {
                datas['${key}'][i]['isSelect'] = true;
              } else {
                datas['${key}'][i]['isSelect'] = false;
              }
            }
          }
        }

        // var listsproducts = value['data']['products'];
        // for (var i = 0; i < listsproducts.length; i++) {
        //   listsproducts[i]['specif'] = '';
        //   for (var keys in listsproducts[i]['specifications'].keys) {
        //     listsproducts[i]['specif'] +=
        //         keys + listsproducts[i]['specifications']['${keys}'];
        //   }
        // }
        setState(() {
          // tips = tip;
          listAllimage = value['data']['goods']['gallery'];
          data = value['data'];
          specifications = datas;
          list = value['data']["attributes"];
          // points = data['goods']['points'];
          productsgoods = value['data']['products'];
          // retailPrice = data['goods']['retailPrice'];
        });
        if (json.encode(value['data']['specifications']) != '{}') {
          getgoodIds();
          // setState(() {
          //   price = value['data']['products'][0]['price'];
          // });
        } else {
          setState(() {
            goodIds = value['data']['products'][0]['id'];
            price = value['data']['products'][0]['price'];
            retailPrice = value['data']['products'][0]['price'];
            picUrl = value['data']['products'][0]['picUrl'];
            limit = value['data']['products'][0]['limit'];
          });
          setState(() {
            objkey = {};
            stringnum = '';
          });
        }
        //  print(goodIds);
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

  getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
  }

  List<Widget> getlist() {
    return list.map((val) {
      return Container(
        margin: EdgeInsets.fromLTRB(0, Ui.width(50), 0, 0),
        width: Ui.width(750),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: Ui.width(200),
              child: Text(
                '${val['label']}',
                style: TextStyle(
                    color: Color(0xFF9398A5),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                    fontSize: Ui.setFontSizeSetSp(28.0)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Text(
                  val['value'] == null ? '' : '${val['value']}',
                  style: TextStyle(
                      color: Color(0xFF111F37),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'PingFangSC-Medium,PingFang SC',
                      fontSize: Ui.setFontSizeSetSp(28.0)),
                ),
              ),
            )
          ],
        ),
      );
    }).toList();
  }

  getcount(carnum) async {
    await HttpUtlis.get('wx/cart/count', success: (value) {
      if (value['errno'] == 0) {
        if (value['data']['count'] != null) {
          setState(() {
            count = value['data']['count'];
          });
        } else {
          setState(() {
            count = 0;
          });
        }
      }
      carnum.increment(count);
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  shpingcar(carnum) async {
    await HttpUtlis.post('wx/cart/save',
        params: {'id': '', 'productId': goodIds, 'number': int.parse(nums)},
        success: (value) {
      // print(value);
      if (value['errno'] == 0) {
        carnum.increment(value['data']['count']);
        Timer(new Duration(seconds: 1), () {
          Navigator.pop(context);
        });
        Toast.show('添加成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getgoodIds() {
    var data = specifications;
    // var strings = '';
    var obj = {};
    for (var key in data.keys) {
      for (var s = 0; s < data['${key}'].length; s++) {
        if (data['${key}'][s]['isSelect']) {
          obj['${key}'] = data['${key}'][s]['value'];
        }
      }
    }
    // print(obj.toString());
    var keylist = [];
    for (var key in obj.keys) {
      keylist.add(key);
    }
    setState(() {
      objkey = obj;
    });
    stringnum = '';
    objkey.forEach((key, value) {
      if (keylist.length > 1) {
        stringnum = value + '/${stringnum}';
      } else {
        stringnum = value + '${stringnum}';
      }
    });
    if (keylist.length > 1) {
      stringnum = stringnum.substring(0, stringnum.length - 1);
    }
    // for (var key in obj.keys) {
    for (var w = 0, len = productsgoods.length; w < len; w++) {
      var flage = false;
      for (var i = 0; i < keylist.length; i++) {
        if (productsgoods[w]['specifications']['${keylist[i]}'] ==
            obj['${keylist[i]}']) {
          flage = true;
        } else {
          flage = false;
          break;
        }
      }
      if (flage) {
        setState(() {
          goodIds = productsgoods[w]['id'];
          price = productsgoods[w]['price'];
          retailPrice = productsgoods[w]['price'];
          picUrl = productsgoods[w]['picUrl'];
          limit = productsgoods[w]['limit'];
        });
      }
    }
    // print(goodIds);
    // }
  }

  getdom(setBottomState) {
    List<Widget> list = [];
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    specifications.forEach((key, value) {
      list.add(Container(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              Ui.width(0), Ui.width(0), Ui.width(0), Ui.width(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(20)),
                child: Text(
                  '${key}',
                  style: TextStyle(
                      color: Color(0xFF111F37),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'PingFangSC-Medium,PingFang SC',
                      fontSize: Ui.setFontSizeSetSp(28.0)),
                ),
              ),
              Container(child: getchilddome(value, key, setBottomState))
            ],
          ),
        ),
      ));
    });
    content = new Column(
      children: list,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    return content;
  }

  getchilddome(value, key, setBottomState) {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (int i = 0, len = value.length; i < len; i++) {
      tiles.add(InkWell(
          onTap: () {
            var data = specifications;
            for (int j = 0; j < data['${key}'].length; j++) {
              data['${key}'][j]['isSelect'] = false;
              data['${key}'][i]['isSelect'] = true;
            }
            getgoodIds();
            setBottomState(() {
              specifications = data;
            });
          },
          child: Container(
            // width: Ui.width(150),
            constraints: BoxConstraints(
              minWidth: Ui.width(150),
            ),
            // height: Ui.width(50),
            padding: EdgeInsets.fromLTRB(
                Ui.width(15), Ui.width(10), Ui.width(15), Ui.width(10)),
            // margin: EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
            // alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  value[i]['isSelect'] ? Color(0xFFFFF4F6) : Color(0xFFF5F5F5),
              border: Border.all(
                  width: Ui.width(1),
                  color: value[i]['isSelect']
                      ? Color(0xFFD10123)
                      : Color(0xFFF5F5F5)),
            ),
            child: Text(
              '${value[i]['value']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: value[i]['isSelect']
                      ? Color(0xFFD10123)
                      : Color(0xFF5E6578),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                  fontSize: Ui.setFontSizeSetSp(24.0)),
            ),
          )));
    }
    content = new Wrap(
      children: tiles,
      spacing: Ui.width(20),
      runSpacing: Ui.width(30),
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    final counters = Provider.of<Addressselect>(context);
    final carnum = Provider.of<Carnum>(context);
    var counter = Provider.of<Successlogin>(context);
    if (flages) {
      getcount(carnum);
      flages = false;
    }
    if (counter.count) {
      flages = true;
    }
    //优惠卷 底部弹窗
    couponBottomSheet(showtosh) {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (contex) {
            return StatefulBuilder(
              builder: (BuildContext context, setBottomState) {
                return GestureDetector(
                  //解决showModalBottomSheet点击消失的问题
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    return false;
                  },
                  child: Container(
                    height: Ui.width(900) +
                        MediaQuery.of(context).viewInsets.bottom,
                    color: Color(0xFFFFFFFF),
                    width: Ui.width(750),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.fromLTRB(
                                    0, Ui.width(35), 0, Ui.width(20)),
                                child: Text(
                                  '优惠券',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    Ui.width(24), 0, 0, Ui.width(20)),
                                child: Text(
                                  '领券',
                                  style: TextStyle(
                                      color: Color(0xFF5E6578),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(
                                    Ui.width(24), 0, Ui.width(24), 0),
                                width: Ui.width(750),
                                height: Ui.width(650),
                                child: ListView(
                                  children: <Widget>[
                                    Container(
                                      width: Ui.width(702),
                                      height: Ui.width(190),
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, 0, Ui.width(20)),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: AssetImage(
                                            'images/2.0x/border.png'),
                                        fit: BoxFit.fill,
                                      )),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(460),
                                            height: Ui.width(190),
                                            padding: EdgeInsets.fromLTRB(
                                                Ui.width(26),
                                                Ui.width(20),
                                                0,
                                                Ui.width(13)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '汽车机油专享券',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF111F37),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(12),
                                                      ),
                                                      Text(
                                                        '仅限于汽车机油类商品使用',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '2020.04.06-2020.04.16',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: Ui.width(229),
                                            height: Ui.width(190),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              //bgselectroll
                                              image: AssetImage(
                                                  'images/2.0x/bgroll.png'),
                                              fit: BoxFit.fill,
                                            )),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: Ui.width(18),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '￥',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                      SizedBox(
                                                        width: Ui.width(10),
                                                      ),
                                                      Text(
                                                        '200',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    52.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(8),
                                                ),
                                                Container(
                                                  child: Text(
                                                    '满2000元使用',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFD10123),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                22.0)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(10),
                                                ),
                                                Container(
                                                  width: Ui.width(140),
                                                  height: Ui.width(45),
                                                  color: Color(0xFFD10123),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '立即领取',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                22.0)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: Ui.width(702),
                                      height: Ui.width(190),
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, 0, Ui.width(20)),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: AssetImage(
                                            'images/2.0x/border.png'),
                                        fit: BoxFit.fill,
                                      )),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(460),
                                            height: Ui.width(190),
                                            padding: EdgeInsets.fromLTRB(
                                                Ui.width(26),
                                                Ui.width(20),
                                                0,
                                                Ui.width(13)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '汽车机油专享券',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF111F37),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(12),
                                                      ),
                                                      Text(
                                                        '仅限于汽车机油类商品使用',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '2020.04.06-2020.04.16',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: Ui.width(229),
                                            height: Ui.width(190),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              //bgselectroll
                                              image: AssetImage(
                                                  'images/2.0x/bgroll.png'),
                                              fit: BoxFit.fill,
                                            )),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: Ui.width(18),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '￥',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                      SizedBox(
                                                        width: Ui.width(10),
                                                      ),
                                                      Text(
                                                        '200',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    52.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(8),
                                                ),
                                                Container(
                                                  child: Text(
                                                    '满2000元使用',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFD10123),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                22.0)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(10),
                                                ),
                                                Container(
                                                  width: Ui.width(140),
                                                  height: Ui.width(45),
                                                  color: Color(0xFFD10123),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '立即领取',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                22.0)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: Ui.width(702),
                                      height: Ui.width(190),
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, 0, Ui.width(20)),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: AssetImage(
                                            'images/2.0x/border.png'),
                                        fit: BoxFit.fill,
                                      )),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(460),
                                            height: Ui.width(190),
                                            padding: EdgeInsets.fromLTRB(
                                                Ui.width(26),
                                                Ui.width(20),
                                                0,
                                                Ui.width(13)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '汽车机油专享券',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF111F37),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(12),
                                                      ),
                                                      Text(
                                                        '仅限于汽车机油类商品使用',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '2020.04.06-2020.04.16',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: Ui.width(229),
                                            height: Ui.width(190),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              //bgselectroll
                                              image: AssetImage(
                                                  'images/2.0x/bgroll.png'),
                                              fit: BoxFit.fill,
                                            )),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: Ui.width(18),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '￥',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                      SizedBox(
                                                        width: Ui.width(10),
                                                      ),
                                                      Text(
                                                        '200',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    52.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(8),
                                                ),
                                                Container(
                                                  child: Text(
                                                    '满2000元使用',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFD10123),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                22.0)),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: Ui.width(10),
                                                ),
                                                Container(
                                                  width: Ui.width(140),
                                                  height: Ui.width(45),
                                                  color: Color(0xFFD10123),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '立即领取',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                22.0)),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            left: Ui.width(24),
                            bottom: Ui.width(20),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: Ui.width(702),
                                height: Ui.width(76),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Ui.width(8.0))),
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
                                  '确定',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              },
            );
          });
    }

    //商品选择弹窗
    commodityBottomSheet(showtosh, counters, type, carnum) {
      //type 1 加入购物车 2 立即购买
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (contex) {
            return StatefulBuilder(
              builder: (BuildContext context, setBottomState) {
                return GestureDetector(
                  //解决showModalBottomSheet点击消失的问题
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    return false;
                  },
                  child: Container(
                    height: Ui.width(900) +
                        MediaQuery.of(context).viewInsets.bottom,
                    color: Color(0xFFFFFFFF),
                    width: Ui.width(750),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(24), 0, Ui.width(24), 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      0, Ui.width(30), 0, Ui.width(30)),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1,
                                              color: Color(0xffEAEAEA)))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: Ui.width(245),
                                        height: Ui.width(245),
                                        child: CachedNetworkImage(
                                                    width: Ui.width(245),
                                        height: Ui.width(245),
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        picUrl !=
                                                        null
                                                    ? '${picUrl}'
                                                    : '${listAllimage[0]}'),
                                        // decoration: BoxDecoration(
                                        //     image: DecorationImage(
                                        //         fit: BoxFit.fill,
                                        //         image: NetworkImage(picUrl !=
                                        //                 null
                                        //             ? '${picUrl}'
                                        //             : '${listAllimage[0]}'))),
                                      ),
                                      SizedBox(
                                        width: Ui.width(30),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: Ui.width(65),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      '${price}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFD10123),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  42.0)),
                                                    ),
                                                    SizedBox(
                                                      width: Ui.width(3),
                                                    ),
                                                    Text(
                                                      '元',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFD10123),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  24.0)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: Ui.width(10),
                                              ),
                                              Container(
                                                child: Text(
                                                  '${data['goods']['counterPrice']}元',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: Color(0xFF9398A5),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: Ui.width(40),
                                              ),
                                              Container(
                                                child: Text(
                                                  '${stringnum}',
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              Container(
                                width: Ui.width(702),
                                height: Ui.width(470),
                                child: ListView(
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0, Ui.width(40), 0, 0),
                                        child: getdom(setBottomState)),
                                    Container(
                                      child: Text(
                                        '购买数量',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(28.0)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Ui.width(10),
                                    ),
                                    Container(
                                      width: Ui.width(702),
                                      // padding: EdgeInsets.fromLTRB(
                                      //     Ui.width(40), 0, Ui.width(45), 0),
                                      // margin: EdgeInsets.fromLTRB(0, Ui.width(185), 0, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              '数量:',
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      26.0)),
                                            ),
                                          ),
                                          Container(
                                            // width: Ui.width(750),
                                            height: Ui.width(56),
                                            // margin:
                                            //     EdgeInsets.fromLTRB(0, Ui.width(110), 0, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  limit == 0
                                                      ? '不限购'
                                                      : '限购${limit}件',
                                                  style: TextStyle(
                                                      color: Color(0xFFD10123),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                ),
                                                SizedBox(
                                                  width: Ui.width(30),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (int.parse(nums) > 1) {
                                                      setBottomState(() {
                                                        nums =
                                                            (int.parse(nums) -
                                                                    1)
                                                                .toString();
                                                      });
                                                    } else {
                                                      setBottomState(() {
                                                        nums = '1';
                                                      });
                                                    }
                                                    setBottomState(() {
                                                      _initKeywordsController
                                                          .text = nums;
                                                    });
                                                    calculate(setBottomState);
                                                  },
                                                  child: Container(
                                                    width: Ui.width(35),
                                                    height: Ui.width(35),
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: Ui.width(35),
                                                      height: Ui.width(3),
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                  'images/2.0x/reduce.png'))),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    width: Ui.width(100),
                                                    height: Ui.width(60),
                                                    color: Color(0xFFF4F4F4),
                                                    alignment: Alignment.center,
                                                    margin: EdgeInsets.fromLTRB(
                                                        Ui.width(27),
                                                        0,
                                                        Ui.width(27),
                                                        0),
                                                    child: TextField(
                                                      controller:
                                                          TextEditingController
                                                              .fromValue(
                                                        TextEditingValue(
                                                            // 设置内容
                                                            text:
                                                                _initKeywordsController
                                                                    .text,
                                                            // 保持光标在最后
                                                            selection: TextSelection.fromPosition(TextPosition(
                                                                affinity:
                                                                    TextAffinity
                                                                        .downstream,
                                                                offset:
                                                                    _initKeywordsController
                                                                        .text
                                                                        .length))),
                                                      ),

                                                      // controller: this._initKeywordsController,
                                                      autofocus: false,
                                                      textAlign:
                                                          TextAlign.center,
                                                      keyboardAppearance:
                                                          Brightness.light,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0XFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  32)),
                                                      decoration: InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.fromLTRB(
                                                                  0,
                                                                  Ui.width(16),
                                                                  0,
                                                                  style == 1
                                                                      ? Ui.width(
                                                                          26)
                                                                      : Ui.width(
                                                                          30))),
                                                      onChanged: (value) {
                                                        if (int.parse(value) <
                                                            1) {
                                                          setBottomState(() {
                                                            nums = '1';
                                                          });
                                                          Toast.show(
                                                              "数量不能低于1哦～",
                                                              context,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xff5b5956),
                                                              backgroundRadius:
                                                                  Ui.width(8),
                                                              duration: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  Toast.CENTER);
                                                          // Toast(context,msg:'数量不能低于1哦～');
                                                        } else if (int.parse(
                                                                    value) >
                                                                limit &&
                                                            limit != 0) {
                                                          setBottomState(() {
                                                            nums = limit
                                                                .toString();
                                                          });
                                                          // Toast.info(`超过限购数量哦～`);
                                                          Toast.show("超过限购数量哦～",
                                                              context,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xff5b5956),
                                                              backgroundRadius:
                                                                  Ui.width(8),
                                                              duration: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  Toast.CENTER);
                                                        } else if (value ==
                                                            '') {
                                                          setBottomState(() {
                                                            nums = '1';
                                                          });
                                                        } else {
                                                          setBottomState(() {
                                                            nums = value;
                                                          });
                                                        }
                                                        // if (1 <= int.parse(value)) {
                                                        //   setBottomState(() {
                                                        //     nums = value;
                                                        //   });
                                                        // } else {
                                                        //   setBottomState(() {
                                                        //     nums = '1';
                                                        //   });
                                                        // }
                                                        setBottomState(() {
                                                          _initKeywordsController
                                                              .text = nums;
                                                        });
                                                        this.calculate(
                                                            setBottomState);
                                                      },
                                                    )),
                                                InkWell(
                                                  onTap: () {
                                                    if (int.parse(nums) >=
                                                            limit &&
                                                        limit != 0) {
                                                      setBottomState(() {
                                                        nums = limit.toString();
                                                      });
                                                    } else {
                                                      setBottomState(() {
                                                        nums =
                                                            (int.parse(nums) +
                                                                    1)
                                                                .toString();
                                                      });
                                                    }
                                                    setBottomState(() {
                                                      _initKeywordsController
                                                          .text = nums;
                                                    });

                                                    calculate(setBottomState);
                                                  },
                                                  child: Container(
                                                    width: Ui.width(35),
                                                    height: Ui.width(35),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                                'images/2.0x/add.png'))),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            top: Ui.width(30),
                            right: Ui.width(24),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                'images/2.0x/clonse.png',
                                width: Ui.width(32),
                                height: Ui.width(32),
                              ),
                            )),
                        Positioned(
                            bottom: Ui.width(20),
                            left: Ui.width(24),
                            child: InkWell(
                              onTap: () async {
                                if (await getToken() != null) {
                                  if (type == 1) {
                                    shpingcar(carnum);
                                  } else {
                                    counters.increment({});
                                    Navigator.pushNamed(
                                        context, '/ordercomgoods',
                                        arguments: {
                                          "num": nums,
                                          "id": widget.arguments['id'],
                                          'goodIds': goodIds,
                                          'objkey': objkey,
                                          'price': price,
                                          'stringnum': stringnum,
                                        });
                                  }
                                } else {
                                  showtosh();
                                }

                                // type==1?
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: Ui.width(702),
                                height: Ui.width(76),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Ui.width(8.0))),
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
                                  type == 1 ? '加入购物车' : "立即购买",
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                            )
                            //  Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   crossAxisAlignment: CrossAxisAlignment.center,
                            //   children: <Widget>[
                            //     SizedBox(
                            //       width: Ui.width(40),
                            //     ),
                            //     Container(
                            //       child: Column(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.center,
                            //         children: <Widget>[
                            //           Image.asset(
                            //             'images/2.0x/call.png',
                            //             width: Ui.width(40),
                            //             height: Ui.width(40),
                            //           ),
                            //           SizedBox(
                            //             height: Ui.width(10),
                            //           ),
                            //           Text(
                            //             ' 客服',
                            //             style: TextStyle(
                            //                 color: Color(0xFF111F37),
                            //                 fontWeight: FontWeight.w400,
                            //                 fontFamily:
                            //                     'PingFangSC-Medium,PingFang SC',
                            //                 fontSize:
                            //                     Ui.setFontSizeSetSp(20.0)),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //     SizedBox(
                            //       width: Ui.width(50),
                            //     ),
                            //     Container(
                            //         child: Stack(
                            //       children: <Widget>[
                            //         Container(
                            //           alignment: Alignment.center,
                            //           child: Column(
                            //             mainAxisAlignment:
                            //                 MainAxisAlignment.center,
                            //             crossAxisAlignment:
                            //                 CrossAxisAlignment.center,
                            //             children: <Widget>[
                            //               Image.asset(
                            //                 'images/3.0x/shopping.png',
                            //                 width: Ui.width(40),
                            //                 height: Ui.width(40),
                            //               ),
                            //               SizedBox(
                            //                 height: Ui.width(10),
                            //               ),
                            //               Text(
                            //                 '  购物车',
                            //                 textAlign: TextAlign.center,
                            //                 style: TextStyle(
                            //                     color: Color(0xFF111F37),
                            //                     fontWeight: FontWeight.w400,
                            //                     fontFamily:
                            //                         'PingFangSC-Medium,PingFang SC',
                            //                     fontSize:
                            //                         Ui.setFontSizeSetSp(20.0)),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //         Positioned(
                            //           top: Ui.width(10),
                            //           right: 0,
                            //           child: Container(
                            //             width: Ui.width(28),
                            //             height: Ui.width(28),
                            //             alignment: Alignment.center,
                            //             decoration: BoxDecoration(
                            //                 color: Colors.white,
                            //                 borderRadius: new BorderRadius.all(
                            //                     new Radius.circular(
                            //                         Ui.width(28.0))),
                            //                 border: Border.all(
                            //                     color: Color(0xFFD10123),
                            //                     width: Ui.width(1))),
                            //             child: Text(
                            //               '10',
                            //               style: TextStyle(
                            //                   color: Color(0xFFD10123),
                            //                   fontWeight: FontWeight.w400,
                            //                   fontFamily:
                            //                       'PingFangSC-Medium,PingFang SC',
                            //                   fontSize:
                            //                       Ui.setFontSizeSetSp(18.0)),
                            //             ),
                            //           ),
                            //         )
                            //       ],
                            //     )),
                            //     SizedBox(
                            //       width: Ui.width(55),
                            //     ),
                            //     Container(
                            //       width: Ui.width(460),
                            //       height: Ui.width(76),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.start,
                            //         crossAxisAlignment:
                            //             CrossAxisAlignment.start,
                            //         children: <Widget>[
                            //           Container(
                            //             width: Ui.width(230),
                            //             height: Ui.width(76),
                            //             alignment: Alignment.center,
                            //             decoration: BoxDecoration(
                            //               color: Color(0xFF111F37),
                            //               borderRadius: BorderRadius.horizontal(
                            //                   left:
                            //                       Radius.circular(Ui.width(8))),
                            //             ),
                            //             child: Text(
                            //               '加入购物车',
                            //               style: TextStyle(
                            //                   color: Color(0xFFFFFFFF),
                            //                   fontWeight: FontWeight.w400,
                            //                   fontFamily:
                            //                       'PingFangSC-Medium,PingFang SC',
                            //                   fontSize:
                            //                       Ui.setFontSizeSetSp(28.0)),
                            //             ),
                            //           ),
                            //           InkWell(
                            //             onTap: () async {
                            //               if (await getToken() != null) {
                            //                 counters.increment({});
                            //                 Navigator.pushNamed(
                            //                     context, '/ordercomgoods',
                            //                     arguments: {
                            //                       "num": nums,
                            //                       "id": widget.arguments['id'],
                            //                       'goodIds': goodIds,
                            //                       'objkey': objkey,
                            //                       'price': price,
                            //                       'stringnum': stringnum
                            //                     });
                            //               } else {
                            //                 showtosh();
                            //               }
                            //             },
                            //             child: Container(
                            //               width: Ui.width(230),
                            //               height: Ui.width(76),
                            //               alignment: Alignment.center,
                            //               decoration: BoxDecoration(
                            //                 gradient: LinearGradient(
                            //                   begin: Alignment.centerLeft,
                            //                   end: Alignment.centerRight,
                            //                   colors: [
                            //                     Color(0xFFEA4802),
                            //                     Color(0xFFD10123),
                            //                   ],
                            //                 ),
                            //                 color: Color(0xFF111F37),
                            //                 borderRadius:
                            //                     BorderRadius.horizontal(
                            //                         right: Radius.circular(
                            //                             Ui.width(8))),
                            //               ),
                            //               child: Text(
                            //                 '立即购买',
                            //                 style: TextStyle(
                            //                     color: Color(0xFFFFFFFF),
                            //                     fontWeight: FontWeight.w400,
                            //                     fontFamily:
                            //                         'PingFangSC-Medium,PingFang SC',
                            //                     fontSize:
                            //                         Ui.setFontSizeSetSp(28.0)),
                            //               ),
                            //             ),
                            //           )
                            //         ],
                            //       ),
                            //     )
                            //   ],
                            // ),
                            )
                      ],
                    ),
                  ),
                );
              },
            );
          });
    }

    // _attrBottomSheet(showtosh, counters) {
    //   showModalBottomSheet(
    //       context: context,
    //       builder: (contex) {
    //         return StatefulBuilder(
    //           builder: (BuildContext context, setBottomState) {
    //             return GestureDetector(
    //               //解决showModalBottomSheet点击消���的问题
    //               onTap: () {
    //                 FocusScope.of(context).requestFocus(FocusNode());
    //                 return false;
    //               },
    //               child: Container(
    //                 height: Ui.width(440) +
    //                     MediaQuery.of(context).viewInsets.bottom,
    //                 color: Color(0xFFFFFFFF),
    //                 width: Ui.width(750),
    //                 child: Stack(
    //                   children: <Widget>[
    //                     Container(
    //                       width: Ui.width(750),
    //                       margin: EdgeInsets.fromLTRB(
    //                           Ui.width(40), Ui.width(40), 0, 0),
    //                       height: Ui.width(40),
    //                       alignment: Alignment.centerLeft,
    //                       child: Text(
    //                         '购买数量',
    //                         style: TextStyle(
    //                             color: Color(0xFF111F37),
    //                             fontWeight: FontWeight.w400,
    //                             fontFamily: 'PingFangSC-Medium,PingFang SC',
    //                             fontSize: Ui.setFontSizeSetSp(28.0)),
    //                       ),
    //                     ),
    //                     Container(
    //                       margin: EdgeInsets.fromLTRB(
    //                           Ui.width(40), Ui.width(110), 0, 0),
    //                       child: RichText(
    //                         text: TextSpan(
    //                           text: '${retailPrice}',
    //                           style: TextStyle(
    //                               color: Color(0xFFD10123),
    //                               fontWeight: FontWeight.w400,
    //                               fontFamily: 'PingFangSC-Medium,PingFang SC',
    //                               fontSize: Ui.setFontSizeSetSp(42.0)),
    //                           children: <TextSpan>[
    //                             TextSpan(
    //                                 text: ' 元',
    //                                 style: TextStyle(
    //                                     color: Color(0xFFD10123),
    //                                     fontWeight: FontWeight.w400,
    //                                     fontFamily:
    //                                         'PingFangSC-Medium,PingFang SC',
    //                                     fontSize: Ui.setFontSizeSetSp(32.0))),
    //                             // TextSpan(
    //                             //     text: ' +${retailPrice}元',
    //                             //     style: TextStyle(
    //                             //         color: Color(0xFFD10123),
    //                             //         fontWeight: FontWeight.w400,
    //                             //         fontFamily:
    //                             //             'PingFangSC-Medium,PingFang SC',
    //                             //         fontSize: Ui.setFontSizeSetSp(28.0))),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                     Container(
    //                       width: Ui.width(750),
    //                       padding: EdgeInsets.fromLTRB(
    //                           Ui.width(40), 0, Ui.width(45), 0),
    //                       margin: EdgeInsets.fromLTRB(0, Ui.width(185), 0, 0),
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: <Widget>[
    //                           Container(
    //                             child: Text(
    //                               '数量:',
    //                               style: TextStyle(
    //                                   color: Color(0xFF111F37),
    //                                   fontWeight: FontWeight.w400,
    //                                   fontFamily:
    //                                       'PingFangSC-Medium,PingFang SC',
    //                                   fontSize: Ui.setFontSizeSetSp(26.0)),
    //                             ),
    //                           ),
    //                           Container(
    //                             // width: Ui.width(750),
    //                             height: Ui.width(56),
    //                             // margin:
    //                             //     EdgeInsets.fromLTRB(0, Ui.width(110), 0, 0),
    //                             child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               children: <Widget>[
    //                                 Text(
    //                                   data['products'][0]['limit'] == 0
    //                                       ? '不限购'
    //                                       : '限购${data['products'][0]['limit']}件',
    //                                   style: TextStyle(
    //                                       color: Color(0xFFD10123),
    //                                       fontWeight: FontWeight.w400,
    //                                       fontFamily:
    //                                           'PingFangSC-Medium,PingFang SC',
    //                                       fontSize: Ui.setFontSizeSetSp(24.0)),
    //                                 ),
    //                                 SizedBox(
    //                                   width: Ui.width(30),
    //                                 ),
    //                                 InkWell(
    //                                   onTap: () {
    //                                     if (int.parse(nums) > 1) {
    //                                       setBottomState(() {
    //                                         nums = (int.parse(nums) - 1)
    //                                             .toString();
    //                                       });
    //                                     } else {
    //                                       setBottomState(() {
    //                                         nums = '1';
    //                                       });
    //                                     }
    //                                     setBottomState(() {
    //                                       _initKeywordsController.text = nums;
    //                                     });
    //                                     calculate(setBottomState);
    //                                   },
    //                                   child: Container(
    //                                     width: Ui.width(35),
    //                                     height: Ui.width(35),
    //                                     alignment: Alignment.center,
    //                                     child: Container(
    //                                       width: Ui.width(35),
    //                                       height: Ui.width(3),
    //                                       decoration: BoxDecoration(
    //                                           image: DecorationImage(
    //                                               fit: BoxFit.cover,
    //                                               image: AssetImage(
    //                                                   'images/2.0x/reduce.png'))),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 Container(
    //                                     width: Ui.width(100),
    //                                     height: Ui.width(60),
    //                                     color: Color(0xFFF4F4F4),
    //                                     alignment: Alignment.center,
    //                                     margin: EdgeInsets.fromLTRB(
    //                                         Ui.width(27), 0, Ui.width(27), 0),
    //                                     child: TextField(
    //                                       controller:
    //                                           TextEditingController.fromValue(
    //                                         TextEditingValue(
    //                                             // 设置内容
    //                                             text: _initKeywordsController
    //                                                 .text,
    //                                             // 保持光标在最后
    //                                             selection: TextSelection
    //                                                 .fromPosition(TextPosition(
    //                                                     affinity: TextAffinity
    //                                                         .downstream,
    //                                                     offset:
    //                                                         _initKeywordsController
    //                                                             .text.length))),
    //                                       ),

    //                                       // controller: this._initKeywordsController,
    //                                       autofocus: false,
    //                                       textAlign: TextAlign.center,
    //                                       keyboardAppearance: Brightness.light,
    //                                       keyboardType: TextInputType.number,
    //                                       style: TextStyle(
    //                                           color: Color(0XFF111F37),
    //                                           fontWeight: FontWeight.w400,
    //                                           fontSize:
    //                                               Ui.setFontSizeSetSp(32)),
    //                                       decoration: InputDecoration(
    //                                           border: InputBorder.none,
    //                                           contentPadding:
    //                                               EdgeInsets.fromLTRB(
    //                                                   0,
    //                                                   Ui.width(16),
    //                                                   0,
    //                                                   style == 1
    //                                                       ? Ui.width(26)
    //                                                       : Ui.width(30))),
    //                                       onChanged: (value) {
    //                                         if (int.parse(value) < 1) {
    //                                           setBottomState(() {
    //                                             nums = '1';
    //                                           });
    //                                           Toast.show("数量不能低于1哦～", context,
    //                                               backgroundColor:
    //                                                   Color(0xff5b5956),
    //                                               backgroundRadius: Ui.width(8),
    //                                               duration: Toast.LENGTH_SHORT,
    //                                               gravity: Toast.CENTER);
    //                                           // Toast(context,msg:'数量不能低于1哦～');
    //                                         } else if (int.parse(value) >
    //                                                 data['products'][0]
    //                                                     ['limit'] &&
    //                                             data['products'][0]['limit'] !=
    //                                                 0) {
    //                                           setBottomState(() {
    //                                             nums = data['products'][0]
    //                                                     ['limit']
    //                                                 .toString();
    //                                           });
    //                                           // Toast.info(`超过限购数量哦～`);
    //                                           Toast.show("超过限购数量哦～", context,
    //                                               backgroundColor:
    //                                                   Color(0xff5b5956),
    //                                               backgroundRadius: Ui.width(8),
    //                                               duration: Toast.LENGTH_SHORT,
    //                                               gravity: Toast.CENTER);
    //                                         } else if (value == '') {
    //                                           setBottomState(() {
    //                                             nums = '';
    //                                           });
    //                                         } else {
    //                                           setBottomState(() {
    //                                             nums = value;
    //                                           });
    //                                         }
    //                                         // if (1 <= int.parse(value)) {
    //                                         //   setBottomState(() {
    //                                         //     nums = value;
    //                                         //   });
    //                                         // } else {
    //                                         //   setBottomState(() {
    //                                         //     nums = '1';
    //                                         //   });
    //                                         // }
    //                                         setBottomState(() {
    //                                           _initKeywordsController.text =
    //                                               nums;
    //                                         });
    //                                         this.calculate(setBottomState);
    //                                       },
    //                                     )),
    //                                 InkWell(
    //                                   onTap: () {
    //                                     if (int.parse(nums) >=
    //                                             data['products'][0]['limit'] &&
    //                                         data['products'][0]['limit'] != 0) {
    //                                       setBottomState(() {
    //                                         nums = data['products'][0]['limit']
    //                                             .toString();
    //                                       });
    //                                     } else {
    //                                       setBottomState(() {
    //                                         nums = (int.parse(nums) + 1)
    //                                             .toString();
    //                                       });
    //                                     }
    //                                     setBottomState(() {
    //                                       _initKeywordsController.text = nums;
    //                                     });

    //                                     calculate(setBottomState);
    //                                   },
    //                                   child: Container(
    //                                     width: Ui.width(35),
    //                                     height: Ui.width(35),
    //                                     decoration: BoxDecoration(
    //                                         image: DecorationImage(
    //                                             fit: BoxFit.cover,
    //                                             image: AssetImage(
    //                                                 'images/2.0x/add.png'))),
    //                                   ),
    //                                 )
    //                               ],
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Container(
    //                       margin: EdgeInsets.fromLTRB(0, Ui.width(270), 0, 0),
    //                       padding: EdgeInsets.fromLTRB(
    //                           Ui.width(40), 0, Ui.width(40), 0),
    //                       child: Text.rich(new TextSpan(
    //                           text: '*',
    //                           style: new TextStyle(
    //                             color: Color(0xFFD10123),
    //                             fontSize: Ui.setFontSizeSetSp(22),
    //                             fontFamily: 'PingFangSC-Regular,PingFang SC',
    //                             fontWeight: FontWeight.w400,
    //                             decoration: TextDecoration.none,
    //                           ),
    //                           children: <TextSpan>[
    //                             new TextSpan(
    //                               text:
    //                                   '划线价:是指品牌专柜价、商品吊牌价、正品零售价、厂商指导价或该产品曾经展示过的销售价等，并非原价、仅供参考',
    //                               style: new TextStyle(
    //                                 color: Color(0xFF9398A5),
    //                                 fontSize: Ui.setFontSizeSetSp(22),
    //                                 fontFamily:
    //                                     'PingFangSC-Regular,PingFang SC',
    //                                 fontWeight: FontWeight.w400,
    //                                 decoration: TextDecoration.none,
    //                               ),
    //                             ),
    //                           ])),
    //                     ),
    //                     Positioned(
    //                         right: Ui.width(20),
    //                         top: Ui.width(20),
    //                         child: InkWell(
    //                           onTap: () {
    //                             Navigator.of(context).pop();
    //                           },
    //                           child: Container(
    //                             width: Ui.width(30),
    //                             height: Ui.width(30),
    //                             decoration: BoxDecoration(
    //                                 image: DecorationImage(
    //                                     fit: BoxFit.cover,
    //                                     image: AssetImage(
    //                                         'images/2.0x/clonse.png'))),
    //                           ),
    //                         )),
    //                     Positioned(
    //                         bottom: 0,
    //                         left: 0,
    //                         child: InkWell(
    //                           onTap: () async {
    //                             if (await getToken() != null) {
    //                               counters.increment({});
    //                               Navigator.pushNamed(context, '/ordercomgoods',
    //                                   arguments: {
    //                                     "num": nums,
    //                                     "id": widget.arguments['id'],
    //                                     'goodIds': goodIds,
    //                                     'objkey': objkey,
    //                                     'price': price,
    //                                   });
    //                             } else {
    //                               showtosh();
    //                             }
    //                           },
    //                           child: Container(
    //                             alignment: Alignment.center,
    //                             width: Ui.width(750),
    //                             height: Ui.width(90),
    //                             decoration: BoxDecoration(
    //                               gradient: LinearGradient(
    //                                 begin: Alignment.centerLeft,
    //                                 end: Alignment.centerRight,
    //                                 colors: [
    //                                   Color(0xFFEA4802),
    //                                   Color(0xFFD10123),
    //                                 ],
    //                               ),
    //                             ),
    //                             child: Text(
    //                               '确认',
    //                               style: TextStyle(
    //                                   color: Color(0xFFFFFFFF),
    //                                   fontWeight: FontWeight.w400,
    //                                   fontFamily:
    //                                       'PingFangSC-Medium,PingFang SC',
    //                                   fontSize: Ui.setFontSizeSetSp(32.0)),
    //                             ),
    //                           ),
    //                         ))
    //                   ],
    //                 ),
    //               ),
    //             );
    //           },
    //         );
    //       });
    // }

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '商品详情',
          style: TextStyle(
              color: Color(0xFF111F37),
              fontWeight: FontWeight.w500,
              fontFamily: 'PingFangSC-Medium,PingFang SC',
              fontSize: Ui.setFontSizeSetSp(36.0)),
        ),
        centerTitle: true,
        elevation: 0,
        brightness: Brightness.light,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Color(0xFF111F37),
          labelColor: Color(0xFFD10123),
          indicatorColor: Color(0xFFD10123),
          indicatorPadding:
              EdgeInsets.fromLTRB(Ui.width(145), 0, Ui.width(145), 0),
          unselectedLabelStyle: new TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'PingFangSC-Medium,PingFang SC',
              fontSize: Ui.setFontSizeSetSp(30.0)),
          labelStyle: new TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'PingFangSC-Medium,PingFang SC',
              fontSize: Ui.setFontSizeSetSp(30.0)),
          tabs: <Widget>[
            Tab(
              text: '商品',
            ),
            Tab(
              text: '详情',
            ),
          ],
        ),
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
                                  '${Config.weblink}appgooddetail/${widget.arguments['id']}',
                              title: '${data['brand']['name']}',
                              description: '${data['goods']['name']}',
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
          ? Stack(
              children: <Widget>[
                TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    Container(
                      // height: double.infinity,
                      // color: Colors.red,
                      color: Color(0xFFFFFFFF),
                      child: ListView(
                        children: <Widget>[
                          Container(
                            width: Ui.width(750),
                            alignment: Alignment.center,
                            child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Swiper(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return CachedNetworkImage(
                                      width: Ui.width(750),
                                      fit: BoxFit.fill,
                                      imageUrl: '${listAllimage[index]}',
                                    );

                                    //  new Image.network(
                                    //   '${listAllimage[index]}',
                                    //   fit: BoxFit.fill,
                                    // );
                                  },
                                  itemCount: listAllimage.length,
                                  autoplay:
                                      listAllimage.length > 1 ? true : false,
                                )),
                          ),
                          Container(
                            width: Ui.width(750),
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.fromLTRB(Ui.width(40),
                                Ui.width(30), Ui.width(40), Ui.width(30)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "[ ${data['brand']['name']} ] ${data['goods']['name']}",
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(36.0)),
                                ),
                                // SizedBox(height: Ui.width(30)),
                                // Text(
                                //   '${data['goods']['name']}',
                                //   style: TextStyle(
                                //       color: Color(0xFF111F37),
                                //       fontWeight: FontWeight.w400,
                                //       fontFamily:
                                //           'PingFangSC-Medium,PingFang SC',
                                //       fontSize: Ui.setFontSizeSetSp(34.0)),
                                // ),
                                SizedBox(height: Ui.width(20)),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          RichText(
                                            text: TextSpan(
                                              text: '${this.price}',
                                              style: TextStyle(
                                                  color: Color(0xFFD10123),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      42.0)),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: ' 元',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFD10123),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                24.0))),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: Ui.width(20),
                                          ),
                                          Text(
                                            '${data['goods']['counterPrice']}元',
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                color: Color(0xFF9398A5),
                                                fontWeight: FontWeight.w400,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(24.0)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // InkWell(
                                    //   onTap: () {
                                    //     couponBottomSheet(showtosh);
                                    //   },
                                    //   child: Container(
                                    //     child: Text(
                                    //       '领券',
                                    //       textAlign: TextAlign.center,
                                    //       style: TextStyle(
                                    //           color: Color(0xFFD10123),
                                    //           fontWeight: FontWeight.w400,
                                    //           fontFamily:
                                    //               'PingFangSC-Medium,PingFang SC',
                                    //           fontSize:
                                    //               Ui.setFontSizeSetSp(26.0)),
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: Ui.width(750),
                            alignment: Alignment.centerLeft,
                            height: Ui.width(50),
                            color: Color(0xFFF8F9FB),
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(40), 0, Ui.width(40), 0),
                            child: Text(
                              '规格',
                              style: TextStyle(
                                  color: Color(0xFF9398A5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(28.0)),
                            ),
                          ),
                          Container(
                              width: Ui.width(750),
                              alignment: Alignment.centerLeft,
                              // height: Ui.width(176),
                              color: Color(0xFFFFFFFF),
                              padding: EdgeInsets.fromLTRB(
                                  Ui.width(40), 0, Ui.width(40), Ui.width(50)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: getlist(), //getlist(),
                              )),
                          // Container(child: getdom()),
                          SizedBox(
                            height: Ui.width(100),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: ListView(
                        children: <Widget>[
                          // Container(
                          //   width: Ui.width(750),
                          //   alignment: Alignment.centerLeft,
                          //   height: Ui.width(60),
                          //   color: Color(0xFFF8F9FB),
                          //   padding: EdgeInsets.fromLTRB(
                          //       Ui.width(40), 0, Ui.width(40), 0),
                          //   child: Text(
                          //     '商品详情',
                          //     style: TextStyle(
                          //         color: Color(0xFF9398A5),
                          //         fontWeight: FontWeight.w400,
                          //         fontFamily: 'PingFangSC-Medium,PingFang SC',
                          //         fontSize: Ui.setFontSizeSetSp(28.0)),
                          //   ),
                          // ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(40), 0, Ui.width(40), 0),
                            color: Colors.white,
                            child: data['goods']['detail'] != null
                                ? Html(
                                    data:
                                        '<div>${data['goods']['detail'].replaceAll('height="', '')}</div>',
                                  )
                                : Text(''),
                          ),
                          SizedBox(
                            height: Ui.width(120),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: Ui.width(750),
                    height: Ui.width(110),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0XFFDFE3EC),
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: Ui.width(40),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/call.png',
                                  width: Ui.width(40),
                                  height: Ui.width(40),
                                ),
                                SizedBox(
                                  height: Ui.width(10),
                                ),
                                Text(
                                  ' 客服',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(20.0)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: Ui.width(50),
                        ),
                        InkWell(
                          onTap: () async {
                            if (await getToken() != null) {
                              Navigator.pushNamed(
                                context,
                                '/shoppingcart',
                              );
                            } else {
                              showtosh();
                            }
                          },
                          child: Container(
                              child: Stack(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'images/3.0x/shopping.png',
                                      width: Ui.width(40),
                                      height: Ui.width(40),
                                    ),
                                    SizedBox(
                                      height: Ui.width(10),
                                    ),
                                    Text(
                                      '  购物车',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(20.0)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: Ui.width(10),
                                right: 0,
                                child: Container(
                                  width: Ui.width(28),
                                  height: Ui.width(28),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(Ui.width(28.0))),
                                      border: Border.all(
                                          color: Color(0xFFD10123),
                                          width: Ui.width(1))),
                                  child: Text(
                                    '${carnum.count}',
                                    style: TextStyle(
                                        color: Color(0xFFD10123),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(18.0)),
                                  ),
                                ),
                              )
                            ],
                          )),
                        ),
                        SizedBox(
                          width: Ui.width(55),
                        ),
                        Container(
                          width: Ui.width(460),
                          height: Ui.width(76),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  commodityBottomSheet(
                                      showtosh, counters, 1, carnum);
                                },
                                child: Container(
                                  width: Ui.width(230),
                                  height: Ui.width(76),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF111F37),
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(Ui.width(8))),
                                  ),
                                  child: Text(
                                    '加入购物车',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(28.0)),
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    commodityBottomSheet(
                                        showtosh, counters, 2, carnum);
                                  },
                                  child: Container(
                                    width: Ui.width(230),
                                    height: Ui.width(76),
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
                                      color: Color(0xFF111F37),
                                      borderRadius: BorderRadius.horizontal(
                                          right: Radius.circular(Ui.width(8))),
                                    ),
                                    child: Text(
                                      '立即购买',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
                // Positioned(
                //     bottom: 0,
                //     left: 0,
                //     child: InkWell(
                //       onTap: () {
                //         _attrBottomSheet(showtosh, counters);
                //       },
                //       child: Container(
                //         alignment: Alignment.center,
                //         width: Ui.width(750),
                //         height: Ui.width(90),
                //         decoration: BoxDecoration(
                //           gradient: LinearGradient(
                //             begin: Alignment.centerLeft,
                //             end: Alignment.centerRight,
                //             colors: [
                //               Color(0xFFEA4802),
                //               Color(0xFFD10123),
                //             ],
                //           ),
                //         ),
                //         child: Text(
                //           '立即购买',
                //           style: TextStyle(
                //               color: Color(0xFFFFFFFF),
                //               fontWeight: FontWeight.w400,
                //               fontFamily: 'PingFangSC-Medium,PingFang SC',
                //               fontSize: Ui.setFontSizeSetSp(32.0)),
                //         ),
                //       ),
                //     ))
              ],
            )
          : Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: LoadingDialog(
                text: "加载中…",
              ),
            ),
    );
  }
}
