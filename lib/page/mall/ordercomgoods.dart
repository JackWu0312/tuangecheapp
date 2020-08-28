import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';
import '../../provider/Addressselect.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class Ordercomgoods extends StatefulWidget {
  final Map arguments;
  Ordercomgoods({Key key, this.arguments}) : super(key: key);
  @override
  _OrdercomgoodsState createState() => _OrdercomgoodsState();
}

class _OrdercomgoodsState extends State<Ordercomgoods> {
  var _initKeywordsController = new TextEditingController();
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
    await HttpUtlis.get('wx/goods/${widget.arguments['id']}', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          item = value['data'];
        });
        calculate(widget.arguments['goodIds']);
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

    await HttpUtlis.post('wx/order/submit', params: {
      'productId': widget.arguments['goodIds'],
      'addressId': adress['id'],
      'number': int.parse(widget.arguments['num']),
      'message': message
    }, success: (value) async {
      if (value['errno'] == 0) {
        await HttpUtlis.post("wx/order/prepay",
            params: {'orderId': value['data']['id']}, success: (value) {
          // print(value['data']);
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
    widget.arguments['objkey'].forEach((key, value) {
      tiles.add(Container(
        width: Ui.width(150),
        height: Ui.width(50),
        // margin: EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFFFF4F6),
          border: Border.all(width: Ui.width(1), color: Color(0xFFD10123)),
        ),
        child: Text(
          '${value}',
          style: TextStyle(
              color: Color(0xFFD10123),
              fontWeight: FontWeight.w400,
              fontFamily: 'PingFangSC-Medium,PingFang SC',
              fontSize: Ui.setFontSizeSetSp(24.0)),
        ),
      ));
    });
    content = new Wrap(
      children: tiles,
      spacing: Ui.width(20),
      runSpacing: Ui.width(30),
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
    couponBottomSheet() {
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
                    height: Ui.width(600) +
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
                                    0, Ui.width(35), 0, Ui.width(30)),
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
                                width: Ui.width(750),
                                height: Ui.width(380),
                                padding: EdgeInsets.fromLTRB(
                                    Ui.width(24), 0, Ui.width(24), 0),
                                child: ListView(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, 0, Ui.width(40)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              '满300-20  ￥20',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      30.0)),
                                            ),
                                          ),
                                          Container(
                                            child: Image.asset(
                                              'images/2.0x/unselect.png',
                                              width: Ui.width(38),
                                              height: Ui.width(38),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, 0, Ui.width(40)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              '不使用优惠',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      30.0)),
                                            ),
                                          ),
                                          Container(
                                            child: Image.asset(
                                              'images/2.0x/select.png',
                                              width: Ui.width(38),
                                              height: Ui.width(38),
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
          child: Stack(
            children: <Widget>[
              Container(
                width: Ui.width(750),
                color: Color(0xFFF8F9FB),
                child: isloading
                    ? ListView(
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
                                    child: json.encode(counter.count) != '{}' &&
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
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
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
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
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
                                                    fontWeight: FontWeight.w500,
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
                            width: Ui.width(702),
                            constraints: BoxConstraints(
                              // minHeight: Ui.width(572),
                              minHeight: Ui.width(460),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(Ui.width(8.0))),
                            ),
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(24), 0, Ui.width(24), 0),
                            padding: EdgeInsets.fromLTRB(Ui.width(20),
                                Ui.width(30), Ui.width(20), Ui.width(30)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: Ui.width(180),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: Ui.width(180),
                                        height: Ui.width(180),
                                        margin: EdgeInsets.fromLTRB(
                                            0, 0, Ui.width(30), 0),
                                        child: CachedNetworkImage(
                                            width: Ui.width(180),
                                            height: Ui.width(180),
                                            fit: BoxFit.fill,
                                            imageUrl:
                                                '${item['goods']['picUrl']}'),
                                        // decoration: BoxDecoration(
                                        //     image: DecorationImage(
                                        //         fit: BoxFit.fill,
                                        //         image: NetworkImage(
                                        //             '${item['goods']['picUrl']}'))),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: Ui.width(180),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Text(
                                                        "[ ${item['brand']['name']} ] ${item['goods']['name']}",
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF111F37),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    28.0)),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: Ui.width(16),
                                                    ),
                                                    Text(
                                                      '${widget.arguments['stringnum']}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF9398A5),
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
                                                child: Text(
                                                  '￥${widget.arguments['price']}',
                                                  style: TextStyle(
                                                      color: Color(0xFF111F37),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              26.0)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Text(
                                          'x${widget.arguments['num']}',
                                          style: TextStyle(
                                              color: Color(0xFF9398A5),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(
                                      Ui.width(80), Ui.width(40), 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        margin: EdgeInsets.fromLTRB(
                                            0, 0, 0, Ui.width(30)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 0, Ui.width(30), 0),
                                              child: Text(
                                                '订单备注',
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
                                            Expanded(
                                              flex: 1,
                                              child: TextField(
                                                controller: this
                                                    ._initKeywordsController,
                                                style: TextStyle(
                                                    color: Color(0XFF111F37),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            26)),
                                                textAlign: TextAlign.left,
                                                keyboardAppearance:
                                                    Brightness.light,
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: InputDecoration(
                                                  hintText: '选填，可以告知商家您的需求',
                                                  hintStyle: TextStyle(
                                                    color: Color(0xFF9398A5),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            26.0),
                                                  ),
                                                  border: InputBorder.none,
                                                  // filled: true,
                                                  // fillColor: Color(0xFFF8F9FB),
                                                  // // contentPadding: EdgeInsets.fromLTRB(
                                                  // //     0, 0, 0, style==1?Ui.width(26):Ui.width(30)),
                                                  // focusedBorder: OutlineInputBorder(
                                                  //   borderSide: BorderSide(
                                                  //       color: Color(0xFFF8F9FB)),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(Ui.width(7)),
                                                  // ),
                                                  // enabledBorder: UnderlineInputBorder(
                                                  //   borderSide: BorderSide(
                                                  //       color: Color(0xFFF8F9FB)),
                                                  //   borderRadius:
                                                  //       BorderRadius.circular(Ui.width(7)),
                                                  // ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    message = value;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '共${widget.arguments['num']}件',
                                        style: TextStyle(
                                            color: Color(0xFF9398A5),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                      SizedBox(
                                        width: Ui.width(20),
                                      ),
                                      Text(
                                        '小计：',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                      SizedBox(
                                        width: Ui.width(10),
                                      ),
                                      Text(
                                        '￥${retailPrice}',
                                        style: TextStyle(
                                            color: Color(0xFFD10123),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          // Container(
                          //   width: Ui.width(750),
                          //   height: Ui.width(240),
                          //   padding: EdgeInsets.fromLTRB(Ui.width(30), Ui.width(30),
                          //       Ui.width(30), Ui.width(30)),
                          //   color: Colors.white,
                          //   margin: EdgeInsets.fromLTRB(0, Ui.width(16), 0, 0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: <Widget>[
                          //       Container(
                          //         width: Ui.width(180),
                          //         height: Ui.width(180),
                          //         margin:
                          //             EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                          //         // color: Colors.red,
                          //         child: AspectRatio(
                          //           aspectRatio: 1 / 1,
                          //           child: Image.network(
                          //             '${item['goods']['picUrl']}',
                          //             fit: BoxFit.cover,
                          //           ),
                          //         ),
                          //       ),
                          //       Expanded(
                          //         flex: 1,
                          //         child: Container(
                          //           child: Column(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: <Widget>[
                          //               Text(
                          //                 '${item['brand']['name']}',
                          //                 style: TextStyle(
                          //                     color: Color(0xFF111F37),
                          //                     fontWeight: FontWeight.w400,
                          //                     fontFamily:
                          //                         'PingFangSC-Medium,PingFang SC',
                          //                     fontSize: Ui.setFontSizeSetSp(30.0)),
                          //               ),
                          //               Container(
                          //                 child: Text(
                          //                   '${item['goods']['name']}',
                          //                   maxLines: 2,
                          //                   overflow: TextOverflow.ellipsis,
                          //                   style: TextStyle(
                          //                       color: Color(0xFF111F37),
                          //                       fontWeight: FontWeight.w400,
                          //                       fontFamily:
                          //                           'PingFangSC-Medium,PingFang SC',
                          //                       fontSize:
                          //                           Ui.setFontSizeSetSp(28.0)),
                          //                 ),
                          //               ),
                          //               Container(
                          //                 child: Row(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.spaceBetween,
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.end,
                          //                   children: <Widget>[
                          //                     Container(
                          //                       child: RichText(
                          //                         text: TextSpan(
                          //                           text:
                          //                               '${widget.arguments['price']}',
                          //                           style: TextStyle(
                          //                               color: Color(0xFFD10123),
                          //                               fontWeight: FontWeight.w400,
                          //                               fontFamily:
                          //                                   'PingFangSC-Medium,PingFang SC',
                          //                               fontSize:
                          //                                   Ui.setFontSizeSetSp(
                          //                                       34.0)),
                          //                           children: <TextSpan>[
                          //                             TextSpan(
                          //                                 text: '元',
                          //                                 style: TextStyle(
                          //                                     color:
                          //                                         Color(0xFFD10123),
                          //                                     fontWeight:
                          //                                         FontWeight.w400,
                          //                                     fontFamily:
                          //                                         'PingFangSC-Medium,PingFang SC',
                          //                                     fontSize: Ui
                          //                                         .setFontSizeSetSp(
                          //                                             24.0))),
                          //                           ],
                          //                         ),
                          //                       ),
                          //                     ),
                          //                     // getchilddome(),
                          //                     Text(
                          //                       '${widget.arguments['stringnum']}',
                          //                       style: TextStyle(
                          //                           color: Color(0xFF9398A5),
                          //                           fontWeight: FontWeight.w400,
                          //                           fontFamily:
                          //                               'PingFangSC-Medium,PingFang SC',
                          //                           fontSize:
                          //                               Ui.setFontSizeSetSp(30.0)),
                          //                     ),
                          //                   ],
                          //                 ),
                          //               )
                          //             ],
                          //           ),
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                        ],
                      )
                    : Container(
                        margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: LoadingDialog(
                          text: "加载中…",
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: Ui.width(750),
                  height: Ui.width(110),
                  padding:
                      EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(24), 0),
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
                          '共${widget.arguments['num']}件',
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
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(26.0)),
                            ),
                            SizedBox(
                              width: Ui.width(5),
                            ),
                            Text(
                              '￥${retailPrice}',
                              style: TextStyle(
                                  color: Color(0xFFD10123),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
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
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      // Expanded(
                      //     flex: 1,
                      //     child: InkWell(
                      //       onTap: () {
                      //         submit();
                      //       },
                      //       child: Container(
                      //         height: Ui.width(90),
                      //         alignment: Alignment.center,
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
                      //           '立即支付',
                      //           style: TextStyle(
                      //               color: Color(0xFFFFFFFF),
                      //               fontWeight: FontWeight.w400,
                      //               fontFamily: 'PingFangSC-Medium,PingFang SC',
                      //               fontSize: Ui.setFontSizeSetSp(32.0)),
                      //         ),
                      //       ),
                      //     ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
