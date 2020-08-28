import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:url_launcher/url_launcher.dart';
import '../../common/Storage.dart';

class Sure extends StatefulWidget {
  final Map arguments;
  Sure({Key key, this.arguments}) : super(key: key);
  @override
  _SureState createState() => _SureState();
}

class _SureState extends State<Sure> {
  Widget borderwidth(height) {
    return Container(
      width: double.infinity,
      height: Ui.height(height),
      color: Color(0XFFF8F9FB),
    );
  }

  var item;
  var orderId;
  var depositPrice;
  bool checkboxValue = false;
  Timer timer;
  StreamSubscription<WeChatPaymentResponse> _wxlogin;
  @override
  void initState() {
    // TODO: implement initState
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
          Navigator.pushNamed(
            context,
            '/paymentcar',
          );
        });
      } else {
        Toast.show('支付失败', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      }
    });
    // print(widget.arguments['id']);
    getData();
  }

  void dispose() {
    _wxlogin.cancel();
    super.dispose();
  }

  getData() async {
    await HttpUtlis.get('wx/order/detail/${widget.arguments['id']}',
        success: (value) {
      // print(value);
      if (value['errno'] == 0) {
        setState(() {
          item = value['data']['goods'][0];
          orderId = value['data']['order']['id'];
          depositPrice = value['data']['orderGoods'][0]['depositPrice'];
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

  submit() async {
    if (!checkboxValue) {
      Toast.show('请阅读并勾选协议', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }

    await HttpUtlis.post("wx/order/prepay", params: {'orderId': orderId},
        success: (value) {
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

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '确认支付',
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
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(100)),
              child: ListView(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: Ui.width(250),
                    padding: EdgeInsets.fromLTRB(
                        Ui.width(40), Ui.width(40), Ui.width(40), Ui.width(40)),
                    child: item != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width: Ui.width(220),
                                  height: Ui.height(168),
                                  margin: EdgeInsets.fromLTRB(
                                      0, 0, Ui.width(30), 0),
                                  child: AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: '${item['picUrl']}',
                                    ),
                                    // Image.network(
                                    //   '${item['picUrl']}',
                                    //   fit: BoxFit.cover,
                                    // ),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          '${item['name']}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Color(0xFF111F37),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(34.0)),
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.end,
                                        text: TextSpan(
                                          text: '款式：',
                                          style: TextStyle(
                                              color: Color(0xFF9398A5),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0)),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${item['category']['name']}',
                                                style: TextStyle(
                                                    color: Color(0xFFD10123),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            28.0))),
                                          ],
                                        ),
                                      ),
                                      RichText(
                                        textAlign: TextAlign.end,
                                        text: TextSpan(
                                          text: '小团集采价：',
                                          style: TextStyle(
                                              color: Color(0xFF9398A5),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0)),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${item['retailPrice']}${item['unit']}',
                                                style: TextStyle(
                                                    color: Color(0xFFD10123),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            28.0))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        : Text(''),
                  ),
                  borderwidth(16.0),
                  Container(
                    width: Ui.width(706),
                    height: Ui.width(324),
                    margin: EdgeInsets.fromLTRB(
                        Ui.width(22), Ui.width(30), Ui.width(22), 0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('images/2.0x/surebg.png'))),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: Ui.width(65),
                          top: Ui.width(20),
                          child: Container(
                            width: Ui.width(130),
                            alignment: Alignment.center,
                            height: Ui.width(80),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Color(0xffFFFFFF)))),
                            child: Text(
                              '保证金',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(42.0)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: Ui.width(50),
                          bottom: Ui.width(85),
                          child: Container(
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: '¥',
                                style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(38.0)),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: depositPrice!=null?'${depositPrice}':'',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(60.0))),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.fromLTRB(0, Ui.width(40), 0, Ui.width(50)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: Ui.width(95),
                          height: Ui.width(1),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xff111F37)))),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(25), 0, Ui.width(25), 0),
                          child: Text(
                            '支付保障',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(34.0)),
                          ),
                        ),
                        Container(
                          width: Ui.width(95),
                          height: Ui.width(1),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xff111F37)))),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(50), 0, 0, Ui.width(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: Ui.width(96),
                            height: Ui.width(48),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('images/2.0x/sepbg.png'))),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(10),
                                  left: Ui.width(22),
                                  child: Text(
                                    '01',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          width: Ui.width(30),
                        ),
                        Text(
                          '报价回复不超过7个工作日',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(50), 0, 0, Ui.width(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: Ui.width(96),
                            height: Ui.width(48),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('images/2.0x/sepbg.png'))),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(10),
                                  left: Ui.width(22),
                                  child: Text(
                                    '02',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          width: Ui.width(30),
                        ),
                        Text(
                          '拼着买价格不会高于预售价格',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(50), 0, 0, Ui.width(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: Ui.width(96),
                            height: Ui.width(48),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('images/2.0x/sepbg.png'))),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(10),
                                  left: Ui.width(22),
                                  child: Text(
                                    '03',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          width: Ui.width(30),
                        ),
                        Text(
                          '未达到拼车人数，保证金随时可退',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(50), 0, 0, Ui.width(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: Ui.width(96),
                            height: Ui.width(48),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('images/2.0x/sepbg.png'))),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(10),
                                  left: Ui.width(22),
                                  child: Text(
                                    '04',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          width: Ui.width(30),
                        ),
                        Text(
                          '报价回复不满意，保证金随时可退',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(50), 0, 0, Ui.width(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: Ui.width(96),
                            height: Ui.width(48),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('images/2.0x/sepbg.png'))),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(10),
                                  left: Ui.width(22),
                                  child: Text(
                                    '05',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          width: Ui.width(30),
                        ),
                        Text(
                          '卖家违约随时退款，可获赔偿',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(50), 0, 0, Ui.width(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: Ui.width(96),
                            height: Ui.width(48),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('images/2.0x/sepbg.png'))),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: Ui.width(10),
                                  left: Ui.width(22),
                                  child: Text(
                                    '06',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(26.0)),
                                  ),
                                )
                              ],
                            )),
                        SizedBox(
                          width: Ui.width(30),
                        ),
                        Text(
                          '保证金可抵用购车车款',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: Ui.width(20),
                  ),
                  Container(
                    color: Color(0xFFF8F9FB),
                    padding:
                        EdgeInsets.fromLTRB(0, Ui.width(20), 0, Ui.width(60)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Checkbox(
                          value: checkboxValue,
                          activeColor: Color(0xFFD10123),
                          onChanged: (bool val) {
                            setState(() {
                              checkboxValue = val;
                            });
                          },
                        ),
                        Text(
                          '我已阅读以上条款并遵守相关《协议》',
                          style: TextStyle(
                              color: Color(0xFFC4C9D3),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(22.0)),
                        ),
                      ],
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
                // color: Colors.red,
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
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(26.0)),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            submit();
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
                              '微信支付',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(32.0)),
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
    );
  }
}
