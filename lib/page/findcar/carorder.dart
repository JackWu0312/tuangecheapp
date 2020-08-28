import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../ui/ui.dart';
import 'package:city_pickers/city_pickers.dart';
// import 'package:amap_location/amap_location.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/Storage.dart';
import 'package:provider/provider.dart';
import '../../provider/Rollbag.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

// import 'dart:io';
class Carorder extends StatefulWidget {
  final Map arguments;
  Carorder({Key key, this.arguments}) : super(key: key);
  @override
  _CarorderState createState() => _CarorderState();
}

class _CarorderState extends State<Carorder> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var latitude;
  var longitude;
  var timer;
  List checkbok = [
    {'name': '贷款购车', 'value': false},
    {
      'name': '帮上牌',
      'value': false
      // checked: 'true'
    },
    {'name': '置换换车', 'value': false},
    {
      'name': '店内全险',
      'value': true,
    }
  ];
  int active = 1;
  var agents;
  var agentId = '';
  var agentsNew;
  var agentIdNew = '';
  String citys = '';
  Map specifications = {};
  String userName = '';
  var mobile = '';
  int pickupCycle = 0;
  var pickerData = '';
  var productId;
  List products = [];
  var goodIds = '';
  var message = '';
  List checkboxValue = [];
  var total = 0;
  var _initnameController = new TextEditingController();
  var _initmobileController = new TextEditingController();
  var _initagentsController = new TextEditingController();
  var _initmessageController = new TextEditingController();
  var selectroll;
  var numbers;

  void initState() {
    // TODO: implement initState
    super.initState();
    TalkingDataAppAnalytics.onPageStart('车辆下单'); //埋点使用
    getdata();
    getcoupon();
    Future.delayed(Duration(seconds: 1), () {
      getlocation();
    });
    getcheckbox();
  }

  @override
  void dispose() {
    TalkingDataAppAnalytics.onPageEnd('车辆下单');
    super.dispose();
  }

  getcheckbox() {
    checkboxValue = [];
    for (var i = 0; i < checkbok.length; i++) {
      if (checkbok[i]['value']) {
        checkboxValue.add(checkbok[i]['name']);
      }
    }
  }

  getlocation() async {
    var city = await Storage.getString('city');
    var longitude = await Storage.getString('longitude');
    var latitude = await Storage.getString('latitude');
    setState(() {
      citys = city;
    });
    getjxs(longitude, latitude);
  }

  getcoupon() async {
    await HttpUtlis.get('wx/coupon/availableCoupon/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          total = value['data']['total'];
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

  getjxs(longitude, latitude) async {
    await HttpUtlis.post("wx/agent/nearest",
        params: {'longitude': longitude, 'latitude': latitude},
        success: (value) async {
      if (value['errno'] == 0) {
        setState(() {
          agents = value['data'];
          agentId = value['data']['id'];
          agentsNew = value['data'];
          agentIdNew = value['data']['id'];
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

  agentschangge(val) async {
    if (val != '') {
      await HttpUtlis.get('wx/agent/search?name=${val}', success: (value) {
        if (value['errno'] == 0) {
          if (json.encode(value['data']) != '{}') {
            setState(() {
              agents = value['data'];
              agentId = value['data']['id'];
            });
          } else {
            setState(() {
              agents = agentsNew;
              agentId = agentIdNew;
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
    } else {
      setState(() {
        agents = agentsNew;
        agentId = agentIdNew;
      });
    }
  }

  Widget borderwidth(height) {
    return Container(
      width: double.infinity,
      height: Ui.height(height),
      color: Color(0XFFF8F9FB),
    );
  }

  getgoodIds() {
    var data = specifications;
    var strings = '';
    for (var key in data.keys) {
      for (var s = 0; s < data['${key}'].length; s++) {
        if (data['${key}'][s]['isSelect']) {
          strings += key + '【' + data['${key}'][s]['value'] + '】';
        }
      }
    }
    for (var w = 0, len = products.length; w < len; w++) {
      if (products[w]['specifications'] == strings) {
        setState(() {
          goodIds = products[w]['id'];
          numbers = products[w]['number'];
        });
        print(numbers);
      }
    }
  }

  getchilddome(value, key) {
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
            setState(() {
              specifications = data;
            });
          },
          child: Container(
            width: Ui.width(118),
            height: Ui.width(50),
            // margin: EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  value[i]['isSelect'] ? Color(0xFFD10123) : Color(0xFFFFFFFF),
              border: Border.all(
                  width: Ui.width(1),
                  color: value[i]['isSelect']
                      ? Color(0xFFD10123)
                      : Color(0xFFE0E3E9)),
            ),
            child: Text(
              '${value[i]['value']}',
              style: TextStyle(
                  color: value[i]['isSelect']
                      ? Color(0xFFFFFFFF)
                      : Color(0xFF111F37),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                  fontSize: Ui.setFontSizeSetSp(26.0)),
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

  getdom() {
    List<Widget> list = [];
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    specifications.forEach((key, value) {
      list.add(Container(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              Ui.width(40), Ui.width(50), Ui.width(0), Ui.width(60)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(50)),
                child: Text(
                  '${key}',
                  style: TextStyle(
                      color: Color(0xFF111F37),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PingFangSC-Medium,PingFang SC',
                      fontSize: Ui.setFontSizeSetSp(42.0)),
                ),
              ),
              Container(child: getchilddome(value, key))
            ],
          ),
        ),
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
          width: Ui.width(16),
          color: Color(0XFFF8F9FB),
        ))),
      ));
    });
    content = new Column(
      children: list,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    return content;
  }

  getyuyue() async {
    if (this.userName == '') {
      Toast.show("请输入姓名", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
        .hasMatch(mobile)) {
      Toast.show("请输入正确的手机号码", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }

    await HttpUtlis.post("wx/book/submit", params: {
      "goodsId": productId,
      "productId": goodIds,
      'name': userName,
      'phone': mobile,
      'city': citys,
      'remark': message,
    }, success: (value) async {
      print(value);
      if (value['errno'] == 0) {
        Toast.show('预约成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        timer = new Timer(new Duration(seconds: 1), () {
          Navigator.pop(context);
        });
        // Navigator.pop(context);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  submit() async {
    // if (this.userName == '') {
    //   Toast.show("请输入姓名", context,
    //       backgroundColor: Color(0xff5b5956),
    //       backgroundRadius: Ui.width(16),
    //       duration: Toast.LENGTH_SHORT,
    //       gravity: Toast.CENTER);
    //   return;
    // }
    // if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
    //     .hasMatch(mobile)) {
    //   Toast.show("请输入正确的手机号码", context,
    //       backgroundColor: Color(0xff5b5956),
    //       backgroundRadius: Ui.width(16),
    //       duration: Toast.LENGTH_SHORT,
    //       gravity: Toast.CENTER);
    //   return;
    // }
    if (this.agentId == '') {
      Toast.show("请填写经销商", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    if (this.citys == '') {
      Toast.show("请选择上牌城市", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }

    await HttpUtlis.post("wx/cart/fastAdd",
        params: {'goodsId': productId, 'productId': goodIds},
        success: (value) async {
      if (value['errno'] == 0) {
        await HttpUtlis.post("wx/order/submit", params: {
          'consignee': widget.arguments['realname'],
          'mobile': widget.arguments['mobile'],
          'cartId': value['data']['id'],
          'agentId': agentId,
          'message': message,
          'couponUserId': selectroll != null && json.encode(selectroll) != '{}'
              ? selectroll['couponUserId']
              : '',
          'extra': {
            "上牌城市": citys,
            "附加条件": checkboxValue,
          },
          // 'mode': active
        }, success: (val) async {
          if (val['errno'] == 0) {
            TalkingDataAppAnalytics.onEvent(
                eventID: 'carorder',
                eventLabel: '车辆下单',
                params: {"cartId": value['data']['id']});

            Navigator.pushNamed(context, '/sure',
                arguments: {'id': val['data']['id']});
          }
        }, failure: (error) {
          Toast.show('${error}', context,
              backgroundColor: Color(0xff5b5956),
              backgroundRadius: Ui.width(16),
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.CENTER);
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

  getdata() async {
    // print(widget.arguments['id']);
    await HttpUtlis.get('wx/goods/detail?id=${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        var data = value['data']['specifications'];
        for (var key in data.keys) {
          for (int i = 0, len = data['${key}'].length; i < len; i++) {
            if (i == 0) {
              data['${key}'][i]['isSelect'] = true;
            } else {
              data['${key}'][i]['isSelect'] = false;
            }
          }
        }

        var list = value['data']['products'];
        for (var i = 0; i < list.length; i++) {
          list[i]['specifications'] = list[i]['specifications'].join('');
        }
        setState(() {
          pickupCycle = value['data']['info']['pickupCycle'];
          specifications = data;
          productId = value['data']['info']['id'];
          products = list;
        });
        getgoodIds();
        print(numbers);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Rollbag>(context);
    if (json.encode(counter.count) != '{}') {
      setState(() {
        selectroll = counter.count;
      });
    } else {
      setState(() {
        selectroll = null;
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
                  width: Ui.width(550),
                  height: Ui.width(300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.all(Radius.circular(Ui.width(8.0))),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          right: Ui.width(20),
                          top: Ui.width(20),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset('images/2.0x/clonse.png',
                                  width: Ui.width(28), height: Ui.width(28)))),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(30), Ui.width(70), Ui.width(30), 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: RichText(
                                text: TextSpan(
                                  text: '预付费方式：',
                                  style: TextStyle(
                                      color: Color(0xFF5E6578),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '先付款再提车先付款再提车先付款再提车',
                                        style: TextStyle(
                                          color: Color(0xFF5E6578),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                              child: RichText(
                                text: TextSpan(
                                  text: '后付费方式：',
                                  style: TextStyle(
                                      color: Color(0xFF5E6578),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '先付款再提车先付款再提车先付款再提车',
                                        style: TextStyle(
                                          color: Color(0xFF5E6578),
                                        )),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          });
    }

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              '拼团下单',
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
                counter.increment({});
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
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(90)),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(50),
                            Ui.width(40), Ui.width(20)),
                        child: Text(
                          '个人信息',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(42.0)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(10), Ui.width(40), 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '姓名',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                            ),
                            Container(
                              height: Ui.width(60),
                              width: Ui.width(400),
                              alignment: Alignment.centerRight,
                              // color: Colors.white,
                              child:  Text(
                                '${widget.arguments['realname']}',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                              
                              
                              
                              // TextField(
                              //   autofocus: false,
                              //   controller: _initnameController,
                              //   // textInputAction: TextInputAction.none,
                              //   keyboardAppearance: Brightness.light,
                              //   keyboardType: TextInputType.text,
                              //   textAlign: TextAlign.right,
                              //   style: TextStyle(
                              //       color: Color(0XFF111F37),
                              //       fontWeight: FontWeight.w400,
                              //       fontSize: Ui.setFontSizeSetSp(30)),
                              //   decoration: InputDecoration(
                              //       border: InputBorder.none,
                              //       hintText: '请输入您的姓名',
                              //       hintStyle: TextStyle(
                              //           color: Color(0xFFC4C9D3),
                              //           fontWeight: FontWeight.w400,
                              //           fontFamily: 'Helvetica;',
                              //           fontSize: Ui.setFontSizeSetSp(30.0))),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       userName = value;
                              //     });
                              //   },
                              // ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(10), Ui.width(40), 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '联系电话',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                            ),
                            Container(
                               height: Ui.width(60),
                              width: Ui.width(400),
                              alignment: Alignment.centerRight,
                              // color: Colors.white,
                              child:  Text(
                                '${widget.arguments['mobile']}',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                              
                              
                              // TextField(
                              //   controller: _initmobileController,
                              //   autofocus: false,
                              //   // textInputAction: TextInputAction.none,
                              //   keyboardAppearance: Brightness.light,
                              //   keyboardType: TextInputType.phone,
                              //   textAlign: TextAlign.right,
                              //   style: TextStyle(
                              //       color: Color(0XFF111F37),
                              //       fontWeight: FontWeight.w400,
                              //       fontSize: Ui.setFontSizeSetSp(30)),
                              //   decoration: InputDecoration(
                              //       border: InputBorder.none,
                              //       hintText: '请输入您的联系电话',
                              //       hintStyle: TextStyle(
                              //           color: Color(0xFFC4C9D3),
                              //           fontWeight: FontWeight.w400,
                              //           fontFamily: 'Helvetica;',
                              //           fontSize: Ui.setFontSizeSetSp(30.0))),
                              //   onChanged: (value) {
                              //     setState(() {
                              //       mobile = value;
                              //     });
                              //   },
                              // ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            Ui.width(40), Ui.width(10), Ui.width(40), 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '代理商',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                            ),
                            Container(
                              // height: Ui.width(60),
                              width: Ui.width(400),
                              alignment: Alignment.centerRight,
                              // color: Colors.white,
                              child: TextField(
                                autofocus: false,
                                controller: _initagentsController,
                                // textInputAction: TextInputAction.none,
                                keyboardAppearance: Brightness.light,
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Color(0XFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontSize: Ui.setFontSizeSetSp(30)),
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '请输入代理商',
                                    hintStyle: TextStyle(
                                        color: Color(0xFFC4C9D3),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Helvetica;',
                                        fontSize: Ui.setFontSizeSetSp(30.0))),
                                onChanged: (value) {
                                  agentschangge(value);
                                  // mobile = value;
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: agents != null
                            ? Column(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      // if( agents['detail']!=null){
                                      Navigator.pushNamed(context, '/store',
                                          arguments: {'store': agents});
                                      // }else {
                                      //       Toast.show('暂无门店详情', context,
                                      //           backgroundColor: Color(0xff5b5956),
                                      //           backgroundRadius: Ui.width(16),
                                      //           duration: Toast.LENGTH_SHORT,
                                      //           gravity: Toast.CENTER);
                                      //     }
                                    },
                                    child: Container(
                                        width: Ui.width(670),
                                        margin: EdgeInsets.fromLTRB(
                                            0, Ui.width(20), 0, 0),
                                        padding: EdgeInsets.fromLTRB(
                                            Ui.width(25),
                                            Ui.width(20),
                                            Ui.width(40),
                                            Ui.width(20)),
                                        constraints: BoxConstraints(
                                          minHeight: Ui.width(120),
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: Ui.width(1),
                                                color: Color(0xFFD10123)),
                                            color: Color(0xFFFFF6F7)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                '${agents['name']}',
                                                style: TextStyle(
                                                    color: Color(0xFF111F37),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            26.0)),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, Ui.width(6), 0, 0),
                                              child: Text(
                                                '${agents['address']}',
                                                style: TextStyle(
                                                    color: Color(0xFF9398A5),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            24.0)),
                                              ),
                                            )
                                          ],
                                        )),
                                  )
                                ],
                              )
                            : Text(''),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(50),
                            Ui.width(40), Ui.width(50)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '上牌城市',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0)),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                Result result = await CityPickers.showCityPicker(
                                    context: context,
                                    height: Ui.width(500),
                                    showType: ShowType.pc,
                                    cancelWidget: Text('取消',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Color(0xFF3895FF),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(30.0))),
                                    confirmWidget: Text('确定',
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Color(0xFF3895FF),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(30.0))));
                                if (result != null) {
                                  setState(() {
                                    // province = result.provinceName;
                                    citys = result.cityName;
                                    // county = result.areaName;
                                  });
                                }
                              },
                              child: Container(
                                  // height: Ui.width(60),
                                  width: Ui.width(400),
                                  alignment: Alignment.centerRight,
                                  // color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        this.citys != null ? '${citys}' : '',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(30.0)),
                                      ),
                                      SizedBox(
                                        width: Ui.width(20),
                                      ),
                                      Image.asset('images/2.0x/btm.png',
                                          width: Ui.width(27),
                                          height: Ui.width(27))
                                    ],
                                  )),
                            )
                          ],
                        ),
                      ),
                      // numbers == 0 ? SizedBox() : borderwidth(16.0),
                      borderwidth(16.0),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            //Ui.width(50)
                            Ui.width(40),
                            0,
                            Ui.width(40),
                            0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Container(
                            //   decoration: BoxDecoration(
                            //       border: Border(
                            //           bottom: BorderSide(
                            //     width: Ui.width(1),
                            //     color: numbers == 0
                            //         ? Color(0XFFFFFFFF)
                            //         : Color(0XFFEAEAEA),
                            //   ))),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: <Widget>[
                            //       Container(
                            //         child: Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.spaceBetween,
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.center,
                            //           children: <Widget>[
                            //             Text(
                            //               '付款方式',
                            //               style: TextStyle(
                            //                   color: Color(0xFF111F37),
                            //                   fontWeight: FontWeight.w500,
                            //                   fontFamily:
                            //                       'PingFangSC-Medium,PingFang SC',
                            //                   fontSize:
                            //                       Ui.setFontSizeSetSp(42.0)),
                            //             ), //showtosh

                            //             InkWell(
                            //                 onTap: () {
                            //                   showtosh();
                            //                 },
                            //                 child: Image.asset(
                            //                     'images/2.0x/doubt.png',
                            //                     width: Ui.width(34),
                            //                     height: Ui.width(34)))
                            //           ],
                            //         ),
                            //       ),
                            //       Container(
                            //         margin: EdgeInsets.fromLTRB(
                            //             0, Ui.width(35), 0, Ui.width(35)),
                            //         child: Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.start,
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.center,
                            //           children: <Widget>[
                            //             InkWell(
                            //               onTap: () {
                            //                 setState(() {
                            //                   active = 1;
                            //                 });
                            //               },
                            //               child: Container(
                            //                 child: Row(
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment.start,
                            //                   crossAxisAlignment:
                            //                       CrossAxisAlignment.center,
                            //                   children: <Widget>[
                            //                     active == 1
                            //                         ? Image.asset(
                            //                             'images/2.0x/redioSelect.png',
                            //                             width: Ui.width(41),
                            //                             height: Ui.width(34))
                            //                         : Image.asset(
                            //                             'images/2.0x/redio.png',
                            //                             width: Ui.width(34),
                            //                             height: Ui.width(34)),
                            //                     SizedBox(
                            //                       width: Ui.width(23),
                            //                     ),
                            //                     Text(
                            //                       '预付费方式',
                            //                       style: TextStyle(
                            //                           color: active == 1
                            //                               ? Color(0xFFD10123)
                            //                               : Color(0xFF111F37),
                            //                           fontWeight:
                            //                               FontWeight.w400,
                            //                           fontFamily:
                            //                               'PingFangSC-Medium,PingFang SC',
                            //                           fontSize:
                            //                               Ui.setFontSizeSetSp(
                            //                                   28.0)),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),
                            //             SizedBox(
                            //               width: Ui.width(120),
                            //             ),
                            //             InkWell(
                            //               onTap: () {
                            //                 setState(() {
                            //                   active = 2;
                            //                 });
                            //               },
                            //               child: Container(
                            //                 child: Row(
                            //                   mainAxisAlignment:
                            //                       MainAxisAlignment.start,
                            //                   crossAxisAlignment:
                            //                       CrossAxisAlignment.center,
                            //                   children: <Widget>[
                            //                     active == 2
                            //                         ? Image.asset(
                            //                             'images/2.0x/redioSelect.png',
                            //                             width: Ui.width(41),
                            //                             height: Ui.width(34))
                            //                         : Image.asset(
                            //                             'images/2.0x/redio.png',
                            //                             width: Ui.width(34),
                            //                             height: Ui.width(34)),
                            //                     SizedBox(
                            //                       width: Ui.width(23),
                            //                     ),
                            //                     Text(
                            //                       '后付费方式',
                            //                       style: TextStyle(
                            //                           color: active == 2
                            //                               ? Color(0xFFD10123)
                            //                               : Color(0xFF111F37),
                            //                           fontWeight:
                            //                               FontWeight.w400,
                            //                           fontFamily:
                            //                               'PingFangSC-Medium,PingFang SC',
                            //                           fontSize:
                            //                               Ui.setFontSizeSetSp(
                            //                                   28.0)),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             )
                            //           ],
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
                            numbers == 0
                                ? SizedBox()
                                : Container(
                                    height: Ui.width(90),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '优惠券',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Container(
                                          width: Ui.width(400),
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  if (total > 0) {
                                                    if (selectroll != null) {
                                                      Navigator.pushNamed(
                                                          context, '/usecoupon',
                                                          arguments: {
                                                            'id': widget
                                                                    .arguments[
                                                                'id'],
                                                            'rollid': selectroll[
                                                                'couponUserId']
                                                          });
                                                    } else {
                                                      Navigator.pushNamed(
                                                          context, '/usecoupon',
                                                          arguments: {
                                                            'id': widget
                                                                    .arguments[
                                                                'id'],
                                                            'rollid': 'noroll'
                                                          });
                                                    }
                                                  }
                                                },
                                                child: Container(
                                                  child: total > 0
                                                      ? selectroll == null
                                                          ? Container(
                                                              height:
                                                                  Ui.width(45),
                                                              width:
                                                                  Ui.width(100),
                                                              // color: Colors.red,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                  colors: [
                                                                    Color(
                                                                        0xFFEA4802),
                                                                    Color(
                                                                        0xFFD10123),
                                                                  ],
                                                                ),
                                                              ),
                                                              child: Text(
                                                                selectroll ==
                                                                        null
                                                                    ? '${total}个可用'
                                                                    : '-${selectroll['coupon']['discount']}',
                                                                style: TextStyle(
                                                                    color: selectroll ==
                                                                            null
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(
                                                                            0xFF111F37),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        'PingFangSC-Medium,PingFang SC',
                                                                    fontSize: selectroll ==
                                                                            null
                                                                        ? Ui.setFontSizeSetSp(
                                                                            20.0)
                                                                        : Ui.setFontSizeSetSp(
                                                                            24.0)),
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Text(
                                                                '-${selectroll['coupon']['discount']}',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF111F37),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        'PingFangSC-Medium,PingFang SC',
                                                                    fontSize: Ui
                                                                        .setFontSizeSetSp(
                                                                            32.0)),
                                                              ),
                                                            )
                                                      : Text(
                                                          selectroll == null
                                                              ? '暂无可用优惠券'
                                                              : '-${selectroll['coupon']['discount']}',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF111F37),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      24.0)),
                                                        ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: Ui.width(20),
                                              ),
                                              Image.asset('images/2.0x/btm.png',
                                                  width: Ui.width(27),
                                                  height: Ui.width(27))
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Container(child: getdom()),
                      borderwidth(16.0),
                      Container(
                        padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(50),
                            Ui.width(40), Ui.width(60)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin:
                                  EdgeInsets.fromLTRB(0, 0, 0, Ui.width(50)),
                              child: Text(
                                '预计提车时间',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(42.0)),
                              ),
                            ),
                            Container(
                              child: Wrap(
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(118),
                                    height: Ui.width(50),
                                    alignment: Alignment.center,
                                    color: Color(0xFFD10123),
                                    child: Text(
                                      '${this.pickupCycle}天',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      borderwidth(16.0),
                      Container(
                        padding: EdgeInsets.fromLTRB(Ui.width(0), Ui.width(40),
                            Ui.width(40), Ui.width(50)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(Ui.width(40), 0, 0, 0),
                              child: Text(
                                '回馈于您的价格为不包括任何附加条件的裸车价。',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(28.0)),
                              ),
                            ),
                            Container(
                              width: Ui.width(550),
                              padding: EdgeInsets.fromLTRB(
                                  Ui.width(10), Ui.width(40), 0, 0),
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                  runSpacing: Ui.width(40),
                                  children: checkbok.asMap().keys.map((index) {
                                    return Container(
                                      width: Ui.width(270),
                                      height: Ui.width(50),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Checkbox(
                                            value: index == 3
                                                ? true
                                                : checkbok[index]['value'],
                                            activeColor: Color(0xFFD10123),
                                            onChanged: (bool val) {
                                              // val 是布尔值
                                              if (index != 3) {
                                                var box = checkbok;
                                                box[index]['value'] = val;
                                                this.setState(() {
                                                  checkbok = box;
                                                });
                                                getcheckbox();
                                              }
                                            },
                                          ),
                                          // SizedBox(
                                          //   width: Ui.width(16),
                                          // ),
                                          Container(
                                            child: Text(
                                              '${checkbok[index]['name']}',
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      28.0)),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList()),
                            )
                          ],
                        ),
                      ),
                      borderwidth(16.0),
                      Container(
                        padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(50),
                            Ui.width(40), Ui.width(20)),
                        child: Text(
                          '补充说明',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(42.0)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), 0, Ui.width(40), Ui.width(60)),
                        child: TextField(
                          maxLines: 5,
                          controller: _initmessageController,
                          autofocus: false,
                          maxLength: 300,
                          // textInputAction: TextInputAction.none,
                          keyboardAppearance: Brightness.light,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Color(0XFF111F37),
                              fontWeight: FontWeight.w400,
                              fontSize: Ui.setFontSizeSetSp(30)),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  '全国拼价默认不包含任何选装及其他内饰，如果您有任何特殊需求，请在此详细说明。',
                              hintStyle: TextStyle(
                                  color: Color(0xFFC4C9D3),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Helvetica;',
                                  fontSize: Ui.setFontSizeSetSp(30.0))),
                          onChanged: (value) {
                            message = value;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    height: Ui.width(90),
                    width: Ui.width(750),
                    child: Row(
                      children: <Widget>[
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
                            width: Ui.width(220),
                            height: Ui.width(90),
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('images/2.0x/call.png',
                                    width: Ui.width(45), height: Ui.width(45)),
                                SizedBox(
                                  width: Ui.width(25),
                                ),
                                Text(
                                  '客服',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(26.0)),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: numbers == 0
                                ? InkWell(
                                    onTap: () async {
                                      await getyuyue();
                                      counter.increment({});
                                    },
                                    child: Container(
                                      height: Ui.width(90),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFF5BBEFF),
                                            Color(0xFF466EFF),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        '立即预约',
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(32.0)),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () async {
                                      await submit();
                                      counter.increment({});
                                    },
                                    child: Container(
                                      height: Ui.width(90),
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
                                        '立即支付',
                                        style: TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(32.0)),
                                      ),
                                    ),
                                  ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
