import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import '../../ui/ui.dart';
// import 'package:toast/toast.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../common/Storage.dart';

class Paymentcar extends StatefulWidget {
  Paymentcar({Key key}) : super(key: key);

  @override
  _PaymentcarState createState() => _PaymentcarState();
}

class _PaymentcarState extends State<Paymentcar> {

   StreamSubscription<WeChatShareResponse> _wxlogin; 
    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
   _wxlogin= fluwx.responseFromShare.listen((data) {
      print(data);
    });
  }
  void dispose() {
   _wxlogin.cancel();
    super.dispose();
  }
  getUserInfo() async {
    try {
      String userInfo = await Storage.getString('userInfo');
      return userInfo;
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            '支付订单',
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
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(0, Ui.width(105), 0, Ui.width(65)),
              child: Image.asset(
                'images/2.0x/payuccess.png',
                width: Ui.width(280),
                height: Ui.width(280),
              ),
            ),
            Text(
              '恭喜您',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xFF111F37),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                  fontSize: Ui.setFontSizeSetSp(40.0)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, Ui.width(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '订单支付成功',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF111F37),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'PingFangSC-Medium,PingFang SC',
                        fontSize: Ui.setFontSizeSetSp(32.0)),
                  ),
                  Text(
                    '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFFD10123),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'PingFangSC-Medium,PingFang SC',
                        fontSize: Ui.setFontSizeSetSp(32.0)),
                  ),
                ],
              ),
            ),
            Container(
              width: Ui.width(510),
              margin: EdgeInsets.fromLTRB(Ui.width(60), 0, Ui.width(60), 0),
              child: Text(
                '24小时内商家会致电您签署购车合同事宜，请您手机保持畅通！',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF9398A5),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                    fontSize: Ui.setFontSizeSetSp(26.0)),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                  Ui.width(80), Ui.width(90), Ui.width(80), 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/listorder');
                    },
                    child: Container(
                    width: Ui.width(280),
                    height: Ui.width(84),
                    alignment: Alignment.center,
                    child: Text(
                      '查看订单',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(32.0)),
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Ui.width(10)),
                        border: Border.all(
                            color: Color(0xFF111F37), width: Ui.width(1))),
                  ),
                  ),
                  InkWell(
                    onTap: () async{
                      var inviteCode =  json.decode(await getUserInfo());
                      var model = fluwx.WeChatShareMiniProgramModel(
                          webPageUrl: "https://wx.qq.com/",
                          miniProgramType: fluwx.WXMiniProgramType.RELEASE,
                          userName: 'gh_368f695b400b',
                          title: '我正在团个车，赶快帮我助力买车吧!',
                          path: '/pages/index/index?inviteCode=${inviteCode['inviteCode']}',
                          description: "分享",
                          thumbnail:'https://litecarmall.oss-cn-beijing.aliyuncs.com/s76yp88qwelr2g6346p2.png');
                      fluwx.shareToWeChat(model);
                    },
                    child: Container(
                      width: Ui.width(280),
                      height: Ui.width(84),
                      alignment: Alignment.center,
                      child: Text(
                        '分享积分',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color(0xFFD10123),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(32.0)),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Ui.width(10)),
                          border: Border.all(
                              color: Color(0xFFD10123), width: Ui.width(1))),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
