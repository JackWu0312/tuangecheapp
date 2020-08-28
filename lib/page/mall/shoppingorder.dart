import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tuangeche/common/LoadingDialog.dart';
import 'package:flutter_tuangeche/http/index.dart';
import 'package:flutter_tuangeche/provider/Addressselect.dart';
import 'package:flutter_tuangeche/ui/ui.dart';
// import '../../ui/ui.dart';
// import '../../http/index.dart';
// import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';
// import '../../provider/Addressselect.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class Shoppingorder extends StatefulWidget {
  final Map arguments;
  Shoppingorder({Key key, this.arguments}) : super(key: key);
  @override
  _ShoppingorderState createState() => _ShoppingorderState();
}

class _ShoppingorderState extends State<Shoppingorder> {
  var _wxlogin;
  bool isloading = false;
  int points = 0;
  double retailPrice = 0;
  var item;
  var adress;
  var counter;
  Timer timer;
  double price = 0;
  var message = '';
  var datas;
  var list = [];

  @override
  void initState() {
    super.initState();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");

    _wxlogin = fluwx.responseFromPayment.listen((data) {
      if (data.errCode == 0) {
        Toast.show('支付成功', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        timer = new Timer(new Duration(seconds: 2), () {
          // Navigator.pushNamed(context, '/paymentcar',);
          Navigator.pushNamed(context, '/paysuccessgood',
              arguments: {'goods': 'goods'});
        });
      } else {
        Toast.show('支付失败', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      }
    });

    print(widget.arguments['id']);

    getData();
    getAdress();
  }

  calculate(id) async {
    await HttpUtlis.post('wx/goods/calculate',
        params: {'id': id, 'number': int.parse(widget.arguments['num'])},
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          // points = value['data']['points'];
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
    await HttpUtlis.get('wx/cart/list/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        //  print(value['data']);
        var listall = value['data']['list'];
        for (var i = 0, len = listall.length; i < len; i++) {
          listall[i]['stringnum'] = '';
          listall[i]['message'] = '';
          var keylist = [];
          for (var key in listall[i]['cart']['specifications'].keys) {
            keylist.add(key);
          }
          listall[i]['cart']['specifications'].forEach((key, value) {
            if (keylist.length > 1) {
              listall[i]['stringnum'] = value + '/${listall[i]['stringnum']}';
            } else {
              listall[i]['stringnum'] = value + '${listall[i]['stringnum']}';
            }
          });
          if (keylist.length > 1) {
            listall[i]['stringnum'] = listall[i]['stringnum']
                .substring(0, listall[i]['stringnum'].length - 1);
          }
        }
        setState(() {
          list = listall;
          datas = value['data'];
        });

        // calculate(widget.arguments['goodIds']);
        // print(data['attributes']);
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

  getAdress() async {
    await HttpUtlis.get('wx/address/default', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          adress = value['data'];
        });
        if (adress != null) {
          counter.increment(adress);
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

  submit() async {
    if (adress == null || json.encode(counter.count) == '{}') {
      Toast.show('请添加收货地址～', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    var data = {"addressId": adress['id'], "array": []};
    var arr = [];
    for (var i = 0, len = list.length; i < len; i++) {
      var obj = {
        "cartId": list[i]['cart']['id'],
        "message": list[i]['message']
      };
      arr.add(obj);
    }
    data['array'] = arr;
    // print(data);
    await HttpUtlis.post('wx/cart/checkout', params: data,
        success: (value) async {
      if (value['errno'] == 0) {
        fluwx.payWithWeChat(
          appId: value['data']['appId'],
          partnerId: value['data']['partnerId'],
          prepayId: value['data']['prepayId'],
          packageValue: value['data']['packageValue'],
          nonceStr: value['data']['nonceStr'],
          timeStamp: int.parse(value['data']['timeStamp']),
          sign: value['data']['sign'],
        );
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

  getchilddome() {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (int i = 0, len = list.length; i < len; i++) {
      // var initKeywordsController = new TextEditingController();
      //  initKeywordsController.text =list[i]['message'];
      tiles.add(
        Container(
          width: Ui.width(702),
          constraints: BoxConstraints(
            // minHeight: Ui.width(572),
            minHeight: Ui.width(460),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                new BorderRadius.all(new Radius.circular(Ui.width(8.0))),
          ),
          margin:
              EdgeInsets.fromLTRB(Ui.width(24), 0, Ui.width(24), Ui.width(20)),
          padding: EdgeInsets.fromLTRB(
              Ui.width(20), Ui.width(30), Ui.width(20), Ui.width(30)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: Ui.width(180),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: Ui.width(180),
                      height: Ui.width(180),
                      margin: EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                      child: CachedNetworkImage(
                          width: Ui.width(180),
                          height: Ui.width(180),
                          fit: BoxFit.fill,
                          imageUrl: '${list[i]['cart']['picUrl']}'),
                      // decoration: BoxDecoration(
                      //     image: DecorationImage(
                      //         fit: BoxFit.fill,
                      //         image: NetworkImage(
                      //             '${list[i]['cart']['picUrl']}'))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: Ui.width(180),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      "${list[i]['cart']['goodsName']}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: Ui.width(16),
                                  ),
                                  Text(
                                    '${list[i]['stringnum']}',
                                    style: TextStyle(
                                        color: Color(0xFF9398A5),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(24.0)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Text(
                                '￥${list[i]['cart']['price']}',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(26.0)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                      child: Text(
                        '${list[i]['cart']['number']}X',
                        style: TextStyle(
                            color: Color(0xFF9398A5),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0)),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(Ui.width(80), Ui.width(40), 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Container(
                    //   margin: EdgeInsets.fromLTRB(
                    //       0, 0, 0, Ui.width(40)),
                    //   child: Row(
                    //     mainAxisAlignment:
                    //         MainAxisAlignment.start,
                    //     crossAxisAlignment:
                    //         CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       Container(
                    //         margin: EdgeInsets.fromLTRB(
                    //             0, 0, Ui.width(30), 0),
                    //         child: Text(
                    //           '优惠减免',
                    //           style: TextStyle(
                    //               color: Color(0xFF111F37),
                    //               fontWeight: FontWeight.w400,
                    //               fontFamily:
                    //                   'PingFangSC-Medium,PingFang SC',
                    //               fontSize:
                    //                   Ui.setFontSizeSetSp(
                    //                       26.0)),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         flex: 1,
                    //         child: Row(
                    //           mainAxisAlignment:
                    //               MainAxisAlignment
                    //                   .spaceBetween,
                    //           crossAxisAlignment:
                    //               CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Container(
                    //               child: Text(
                    //                 '满300-20',
                    //                 style: TextStyle(
                    //                     color:
                    //                         Color(0xFF9398A5),
                    //                     fontWeight:
                    //                         FontWeight.w400,
                    //                     fontFamily:
                    //                         'PingFangSC-Medium,PingFang SC',
                    //                     fontSize: Ui
                    //                         .setFontSizeSetSp(
                    //                             26.0)),
                    //               ),
                    //             ),
                    //             InkWell(
                    //                 onTap: () {
                    //                   couponBottomSheet();
                    //                 },
                    //                 child: Container(
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment
                    //                             .start,
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment
                    //                             .center,
                    //                     children: <Widget>[
                    //                       Container(
                    //                         child: Text(
                    //                           '-￥20.0',
                    //                           style: TextStyle(
                    //                               color: Color(
                    //                                   0xFFD10123),
                    //                               fontWeight:
                    //                                   FontWeight
                    //                                       .w400,
                    //                               fontFamily:
                    //                                   'PingFangSC-Medium,PingFang SC',
                    //                               fontSize: Ui
                    //                                   .setFontSizeSetSp(
                    //                                       26.0)),
                    //                         ),
                    //                       ),
                    //                       SizedBox(
                    //                         width:
                    //                             Ui.width(19),
                    //                       ),
                    //                       Container(
                    //                         child:
                    //                             Image.asset(
                    //                           'images/2.0x/rightmore.png',
                    //                           width: Ui.width(
                    //                               12),
                    //                           height:
                    //                               Ui.width(
                    //                                   22),
                    //                         ),
                    //                       )
                    //                     ],
                    //                   ),
                    //                 ))
                    //           ],
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   margin: EdgeInsets.fromLTRB(
                    //       0, 0, 0, Ui.width(30)),
                    //   child: Row(
                    //     mainAxisAlignment:
                    //         MainAxisAlignment.start,
                    //     crossAxisAlignment:
                    //         CrossAxisAlignment.center,
                    //     children: <Widget>[
                    //       Container(
                    //         margin: EdgeInsets.fromLTRB(
                    //             0, 0, Ui.width(30), 0),
                    //         child: Text(
                    //           '积分抵扣',
                    //           style: TextStyle(
                    //               color: Color(0xFF111F37),
                    //               fontWeight: FontWeight.w400,
                    //               fontFamily:
                    //                   'PingFangSC-Medium,PingFang SC',
                    //               fontSize:
                    //                   Ui.setFontSizeSetSp(
                    //                       26.0)),
                    //         ),
                    //       ),
                    //       Expanded(
                    //         flex: 1,
                    //         child: Row(
                    //           mainAxisAlignment:
                    //               MainAxisAlignment
                    //                   .spaceBetween,
                    //           crossAxisAlignment:
                    //               CrossAxisAlignment.center,
                    //           children: <Widget>[
                    //             Container(
                    //               child: Text(
                    //                 '可用2000积分抵扣20元',
                    //                 style: TextStyle(
                    //                     color:
                    //                         Color(0xFF9398A5),
                    //                     fontWeight:
                    //                         FontWeight.w400,
                    //                     fontFamily:
                    //                         'PingFangSC-Medium,PingFang SC',
                    //                     fontSize: Ui
                    //                         .setFontSizeSetSp(
                    //                             26.0)),
                    //               ),
                    //             ),
                    //             Container(
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment
                    //                         .start,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment
                    //                         .center,
                    //                 children: <Widget>[
                    //                   Container(
                    //                     child: Text(
                    //                       '-￥20.0',
                    //                       style: TextStyle(
                    //                           color: Color(
                    //                               0xFFD10123),
                    //                           fontWeight:
                    //                               FontWeight
                    //                                   .w400,
                    //                           fontFamily:
                    //                               'PingFangSC-Medium,PingFang SC',
                    //                           fontSize: Ui
                    //                               .setFontSizeSetSp(
                    //                                   26.0)),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                            child: Text(
                              '订单备注',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(26.0)),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              // controller: initKeywordsController,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(26)),
                              textAlign: TextAlign.left,
                              keyboardAppearance: Brightness.light,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: '选填，可以告知商家您的需求',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9398A5),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(26.0),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  // initKeywordsController.text=value;
                                  list[i]['message'] = value;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '共${list[i]['cart']['number']}件',
                      style: TextStyle(
                          color: Color(0xFF9398A5),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(26.0)),
                    ),
                    SizedBox(
                      width: Ui.width(20),
                    ),
                    Text(
                      '小计：',
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(26.0)),
                    ),
                    SizedBox(
                      width: Ui.width(10),
                    ),
                    Text(
                      '￥${list[i]['price']['actualPrice']}',
                      style: TextStyle(
                          color: Color(0xFFD10123),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(26.0)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
    content = new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tiles,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    counter = Provider.of<Addressselect>(context);
    if (json.encode(counter.count) != '{}') {
      setState(() {
        adress = counter.count;
      });
    } else {
      if (adress != null) {
        getAdress();
      }
    }
    Ui.init(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            '订单填写',
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
          child: isloading
              ? Stack(
                  children: <Widget>[
                    Container(
                        width: Ui.width(750),
                        color: Color(0xFFF8F9FB),
                        child: ListView(
                          children: <Widget>[
                            Container(
                              width: Ui.width(702),
                              margin: EdgeInsets.fromLTRB(Ui.width(24),
                                  Ui.width(20), Ui.width(24), Ui.width(20)),
                              padding: EdgeInsets.fromLTRB(Ui.width(30),
                                  Ui.width(40), Ui.width(0), Ui.width(30)),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(Ui.width(8.0))),
                              ),
                              constraints: BoxConstraints(
                                minHeight: Ui.width(186),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(48),
                                    margin: EdgeInsets.fromLTRB(
                                        0, 0, Ui.width(30), 0),
                                    child: Image.asset('images/2.0x/adress.png',
                                        width: Ui.width(48),
                                        height: Ui.width(48)),
                                  ),
                                  Expanded(
                                      flex: 1,
                                      child: json.encode(counter.count) !=
                                                  '{}' &&
                                              adress != null
                                          ? InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/addresslistnew');
                                              },
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${adress['name']}  ${adress['tel']}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF111F37),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  32.0)),
                                                    ),
                                                    SizedBox(
                                                      height: Ui.width(20),
                                                    ),
                                                    Text(
                                                      '${adress['fullAddress']}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF6A7182),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  28.0)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/addresslistnew');
                                              },
                                              child: Container(
                                                child: Text(
                                                  '暂无收货地址，请点击添加哦～',
                                                  style: TextStyle(
                                                      color: Color(0xFF111F37),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              32.0)),
                                                ),
                                              ),
                                            )),
                                  Container(
                                    // width: Ui.width(48),
                                    margin: EdgeInsets.fromLTRB(
                                        Ui.width(10), 0, Ui.width(20), 0),
                                    child: Image.asset(
                                        'images/2.0x/rightmore.png',
                                        width: Ui.width(12),
                                        height: Ui.width(22)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: getchilddome(),
                            ),
                            SizedBox(
                              height: Ui.width(120),
                            )
                          ],
                        )),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: Ui.width(750),
                        height: Ui.width(110),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(30), 0, Ui.width(24), 0),
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
                        // alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '共${datas['count']}件',
                                style: TextStyle(
                                    color: Color(0xFF5E6578),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(26.0)),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '合计：',
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                  SizedBox(
                                    width: Ui.width(5),
                                  ),
                                  Text(
                                    '￥${datas['total']}',
                                    style: TextStyle(
                                        color: Color(0xFFD10123),
                                        fontWeight: FontWeight.w600,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(34.0)),
                                  ),
                                  SizedBox(
                                    width: Ui.width(30),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      submit();
                                    },
                                    child: Container(
                                      height: Ui.width(74),
                                      width: Ui.width(230),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: new BorderRadius.all(
                                            new Radius.circular(Ui.width(8.0))),
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
                                                Ui.setFontSizeSetSp(28.0)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : Container(
                  margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: LoadingDialog(
                    text: "加载中…",
                  ),
                ),
        ));
  }
}
