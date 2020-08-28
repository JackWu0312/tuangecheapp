import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/ui.dart';
import 'package:city_pickers/city_pickers.dart';
import '../../common/Storage.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:provider/provider.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../config/config.dart';
import '../../common/CommonBottomSheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Secondhand extends StatefulWidget {
  final Map arguments;
  Secondhand({Key key, this.arguments}) : super(key: key);
  @override
  _SecondhandState createState() => _SecondhandState();
}

class _SecondhandState extends State<Secondhand> {
  var _initVehicleController = new TextEditingController();
  var _initphoneController = new TextEditingController();
  var _initnameController = new TextEditingController();
  var _initkilometreController = new TextEditingController();
  var _initcolorController = new TextEditingController();
  var _inittransferCountController = new TextEditingController();
  var _initcodeController = new TextEditingController();

  StreamSubscription<WeChatShareResponse> _wxlogin;
  String _text = '获取验证码';
  Timer _countdownTimer;
  int _countdownNum = 180;
  String citynew = '';
  DateTime _dateTime;
  bool checkboxValue = false;
  var name = '';
  var recordDate = '';
  var kms = '';
  var province = '';
  var city = '';
  var seller = '';
  var phone = '';
  var url;
  var count;
  var color = '';
  var outDate = '';
  var insuranceExpireDate = '';
  var checkDate = '';
  var transferCount = '';
  var code = '';
  @override
  void initState() {
    super.initState();
    getCity();
    // getnow();
    getdata();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxlogin = fluwx.responseFromShare.listen((data) {
      if (data.errCode == 0) {
        print('分享成功！');
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _wxlogin.cancel();
    super.dispose();
  }

  getnow() {
    var now = new DateTime.now().toString();
    now = now.substring(0, 11);
    setState(() {
      recordDate = now;
    });
  }

  _showDatePicker(str) {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('确定', style: TextStyle(color: Color(0xFF5BBEFF))),
        cancel: Text('取消', style: TextStyle(color: Color(0xFF6A7182))),
      ),
      minDateTime: DateTime.parse('2005-00-00'),
      maxDateTime: DateTime.parse('${new DateTime.now().toString()}'),
      initialDateTime: _dateTime,
      dateFormat: 'yyyy年-MMMM月-dd日',
      locale: DateTimePickerLocale.zh_cn,
      onCancel: () => print('onCancel'),
      onConfirm: (dateTime, List<int> index) {
        if (str == 'recordDate') {
          setState(() {
            recordDate = dateTime.toString().substring(0, 11);
          });
        } else if (str == 'outDate') {
          setState(() {
            outDate = dateTime.toString().substring(0, 11);
          });
        } else if (str == 'insuranceExpireDate') {
          setState(() {
            insuranceExpireDate = dateTime.toString().substring(0, 11);
          });
        } else if (str == 'checkDate') {
          setState(() {
            checkDate = dateTime.toString().substring(0, 11);
          });
        }
      },
    );
  }

  getdata() async {
    await HttpUtlis.get('wx/used/car/banner', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          url = value['data']['url'];
          count = value['data']['count'];
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

  getCity() async {
    var citys = await Storage.getString('city');
    var province = await Storage.getString('province');
    setState(() {
      city = citys;
      province = province;
      citynew = province + '  ' + citys;
    });
  }

  submit() async {
    // if (name == "") {
    //   Toast.show('请填写车型名称', context,
    //       backgroundColor: Color(0xff5b5956),
    //       backgroundRadius: Ui.width(16),
    //       duration: Toast.LENGTH_SHORT,
    //       gravity: Toast.CENTER);
    //   return;
    // }
    // if (kms == "") {
    //   Toast.show('请填写公里数', context,
    //       backgroundColor: Color(0xff5b5956),
    //       backgroundRadius: Ui.width(16),
    //       duration: Toast.LENGTH_SHORT,
    //       gravity: Toast.CENTER);
    //   return;
    // }
    // if (seller == "") {
    //   Toast.show('请填写姓名', context,
    //       backgroundColor: Color(0xff5b5956),
    //       backgroundRadius: Ui.width(16),
    //       duration: Toast.LENGTH_SHORT,
    //       gravity: Toast.CENTER);
    //   return;
    // }
    if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
        .hasMatch(phone)) {
      Toast.show("请输入正确的手机号码", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }

    if (!checkboxValue) {
      Toast.show('请阅读并勾选协议', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }

    await HttpUtlis.post("wx/used/car/save", params: {
      'name': name,
      'color': color,
      'outDate': outDate,
      'insuranceExpireDate': insuranceExpireDate,
      'checkDate': checkDate,
      'recordDate': recordDate,
      'transferCount': transferCount,
      'code': code,
      'kms': kms,
      'province': province,
      'city': city,
      'seller': seller,
      'phone': phone
    }, success: (value) {
      if (value['errno'] == 0) {
        Toast.show('''恭喜您已成功预约 
       卖车服务''', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER);
        Future.delayed(Duration(seconds: 2)).then((e) {
          Navigator.pop(context);
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

  getCode() async {
    if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
        .hasMatch(phone)) {
      Toast.show("请输入正确的手机号码", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    Toast.show("发送成功～", context,
        backgroundColor: Color(0xff5b5956),
        backgroundRadius: Ui.width(16),
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.CENTER);
    HttpUtlis.post("wx/auth/captcha", params: {'mobile': phone},
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          if (_countdownTimer != null) {
            return;
          }
          // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
          _text = '${_countdownNum--}S';
          _countdownTimer =
              new Timer.periodic(new Duration(seconds: 1), (timer) {
            setState(() {
              if (_countdownNum > 0) {
                _text = '${_countdownNum--}S';
              } else {
                _text = '获取验证码';
                _countdownNum = 180;
                _countdownTimer.cancel();
                _countdownTimer = null;
              }
            });
          });
        });
      } else {
        Navigator.pushNamed(context, '/login');
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              appBar: PreferredSize(
                  child: Container(
                    height: Ui.height(0),
                  ),
                  preferredSize: Size(0, 0)),
              body: Container(
                color: Color(0xFFF8F9FB),
                child: ListView(
                  children: <Widget>[
                    //secondbg
                    Container(
                      width: Ui.width(750),
                      height:
                          Ui.width(1800) + MediaQuery.of(context).padding.top,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: Ui.width(750),
                                height: Ui.width(566) +
                                    MediaQuery.of(context).padding.top,
                                // decoration: BoxDecoration(
                                //   image: DecorationImage(
                                //     image: NetworkImage(url != null
                                //         ? '${this.url}'
                                //         : 'https://tuangeche.oss-cn-qingdao.aliyuncs.com/sf21mcq0r6o3paipekvm.png'),
                                //     fit: BoxFit.fill,
                                //   ),
                                // ),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      child: CachedNetworkImage(
                                          width: Ui.width(750),
                                          height: Ui.width(566) +
                                              MediaQuery.of(context)
                                                  .padding
                                                  .top,
                                          fit: BoxFit.fill,
                                          imageUrl: url != null
                                              ? '${this.url}'
                                              : 'https://tuangeche.oss-cn-qingdao.aliyuncs.com/sf21mcq0r6o3paipekvm.png'),
                                    ),
                                    Positioned(
                                        left: Ui.width(30),
                                        top: Ui.width(30) +
                                            MediaQuery.of(context).padding.top,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Image.asset(
                                            'images/2.0x/backnew.png',
                                            width: Ui.width(21),
                                            height: Ui.width(37),
                                          ),
                                        )),
                                    Positioned(
                                      right: Ui.width(30),
                                      top: Ui.width(30) +
                                          MediaQuery.of(context).padding.top,
                                      child: InkWell(
                                        onTap: () async {
                                          showDialog(
                                              barrierDismissible:
                                                  true, //是否点击空白区域关闭对话框,默认为true，可以关闭
                                              context: context,
                                              builder: (BuildContext context) {
                                                var list = List();
                                                list.add('发送给微信好友');
                                                list.add('分享到微信朋友圈');
                                                return CommonBottomSheet(
                                                  list: list,
                                                  onItemClickListener:
                                                      (index) async {
                                                    var model = fluwx
                                                        .WeChatShareWebPageModel(
                                                            webPage:
                                                                '${Config.weblink}appusercar',
                                                            title: '高价卖车，全程服务',
                                                            description:
                                                                '省跑腿免费检测,快速卖当天成交,卖高价包你满意',
                                                            thumbnail:
                                                                "assets://images/loginnew.png",
                                                            scene: index == 0
                                                                ? fluwx
                                                                    .WeChatScene
                                                                    .SESSION
                                                                : fluwx
                                                                    .WeChatScene
                                                                    .TIMELINE,
                                                            transaction: "hh");
                                                    fluwx.shareToWeChat(model);

                                                    Navigator.pop(context);
                                                  },
                                                );
                                              });
                                        },
                                        child: Image.asset(
                                            'images/2.0x/shares.png',
                                            width: Ui.width(42),
                                            height: Ui.width(42)),
                                      ),
                                    ),
                                    Positioned(
                                      left: Ui.width(30),
                                      top: Ui.width(95) +
                                          MediaQuery.of(context).padding.top,
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              '高价卖车，全程服务',
                                              style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      44.0)),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, Ui.width(30), 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    count != null
                                                        ? '${this.count}'
                                                        : '0',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                46.0)),
                                                  ),
                                                  SizedBox(
                                                    width: Ui.width(20),
                                                  ),
                                                  Text(
                                                    '人成功申请卖车',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
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
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, Ui.width(25), 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'images/2.0x/dagou.png',
                                                    width: Ui.width(28),
                                                    height: Ui.width(28),
                                                  ),
                                                  SizedBox(
                                                    width: Ui.width(9),
                                                  ),
                                                  Text(
                                                    '省跑腿免费检测',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, Ui.width(25), 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'images/2.0x/dagou.png',
                                                    width: Ui.width(28),
                                                    height: Ui.width(28),
                                                  ),
                                                  SizedBox(
                                                    width: Ui.width(9),
                                                  ),
                                                  Text(
                                                    '快速卖当天成交',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, Ui.width(25), 0, 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Image.asset(
                                                    'images/2.0x/dagou.png',
                                                    width: Ui.width(28),
                                                    height: Ui.width(28),
                                                  ),
                                                  SizedBox(
                                                    width: Ui.width(9),
                                                  ),
                                                  Text(
                                                    '卖高价包你满意',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFFFFFFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          Positioned(
                            left: Ui.width(24),
                            bottom: 0,
                            child: Container(
                              width: Ui.width(702),
                              // height: Ui.width(660),
                              padding: EdgeInsets.fromLTRB(
                                  Ui.width(40), 0, Ui.width(40), 0),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(Ui.width(16.0))),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '车型',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller: _initVehicleController,
                                            // textInputAction: TextInputAction.none,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请输入车型',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                name = value;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '车身颜色',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller: _initcolorController,
                                            // textInputAction: TextInputAction.none,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请输入车身颜色',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                color = value;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '上户日期',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                _showDatePicker('recordDate');
                                              },
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      recordDate == ''
                                                          ? '请选择上户日期'
                                                          : '${this.recordDate}',
                                                      style: TextStyle(
                                                          color: recordDate ==
                                                                  ''
                                                              ? Color(
                                                                  0xFFC4C9D3)
                                                              : Color(
                                                                  0xFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'Helvetica;',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  30.0)),
                                                    ),
                                                    Image.asset(
                                                        'images/2.0x/btm.png',
                                                        width: Ui.width(27),
                                                        height: Ui.width(27))
                                                  ],
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '出厂日期',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                _showDatePicker('outDate');
                                              },
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      outDate == ''
                                                          ? '请选择出厂日期'
                                                          : '${this.outDate}',
                                                      style: TextStyle(
                                                          color: outDate == ''
                                                              ? Color(
                                                                  0xFFC4C9D3)
                                                              : Color(
                                                                  0xFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'Helvetica;',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  30.0)),
                                                    ),
                                                    Image.asset(
                                                        'images/2.0x/btm.png',
                                                        width: Ui.width(27),
                                                        height: Ui.width(27))
                                                  ],
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '公里数',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller:
                                                _initkilometreController,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请填写公里数',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                kms = value;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '保险到期日',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                _showDatePicker(
                                                    'insuranceExpireDate');
                                              },
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      insuranceExpireDate == ''
                                                          ? '请选择保险到期日'
                                                          : '${this.insuranceExpireDate}',
                                                      style: TextStyle(
                                                          color: insuranceExpireDate ==
                                                                  ''
                                                              ? Color(
                                                                  0xFFC4C9D3)
                                                              : Color(
                                                                  0xFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'Helvetica;',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  30.0)),
                                                    ),
                                                    Image.asset(
                                                        'images/2.0x/btm.png',
                                                        width: Ui.width(27),
                                                        height: Ui.width(27))
                                                  ],
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '审车日期',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                _showDatePicker('checkDate');
                                              },
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      checkDate == ''
                                                          ? '请选择保险到期日'
                                                          : '${this.checkDate}',
                                                      style: TextStyle(
                                                          color: checkDate == ''
                                                              ? Color(
                                                                  0xFFC4C9D3)
                                                              : Color(
                                                                  0xFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'Helvetica;',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  30.0)),
                                                    ),
                                                    Image.asset(
                                                        'images/2.0x/btm.png',
                                                        width: Ui.width(27),
                                                        height: Ui.width(27))
                                                  ],
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '过户次数',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller:
                                                _inittransferCountController,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请填写过户次数',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                transferCount = value;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '车辆所在地',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () async {
                                                Result result = await CityPickers.showCityPicker(
                                                    context: context,
                                                    height: Ui.width(500),
                                                    showType: ShowType.pc,
                                                    cancelWidget: Text('取消',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            color: Color(
                                                                0xFF3895FF),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize:
                                                                Ui.setFontSizeSetSp(
                                                                    30.0))),
                                                    confirmWidget: Text('确定',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .none,
                                                            color:
                                                                Color(0xFF3895FF),
                                                            fontWeight: FontWeight.w400,
                                                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui.setFontSizeSetSp(30.0))));
                                                if (result != null) {
                                                  setState(() {
                                                    city = result.cityName;
                                                    province =
                                                        result.provinceName;
                                                    citynew =
                                                        result.provinceName +
                                                            '  ' +
                                                            result.cityName;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        this.citynew != null
                                                            ? "${this.citynew}"
                                                            : '',
                                                        maxLines: 1,
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
                                                                    30.0)),
                                                      ),
                                                      Image.asset(
                                                          'images/2.0x/btm.png',
                                                          width: Ui.width(27),
                                                          height: Ui.width(27))
                                                    ],
                                                  )),
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '姓名',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller: _initnameController,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请填写姓名',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                seller = value;
                                              });
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '电话',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller: _initphoneController,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.phone,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请填写电话',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                phone = value;
                                              });
                                            },
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              getCode();
                                            },
                                            child: Container(
                                              width: Ui.width(160),
                                              height: Ui.width(40),
                                              child: Text(
                                                '${this._text}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Color(0xFFD10123),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0)),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //验证码
                                    width: Ui.width(622),
                                    height: Ui.width(109),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                width: 1,
                                                color: Color(0xFFEAEAEA)))),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(220),
                                          child: Text(
                                            '验证码',
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            controller: _initcodeController,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.phone,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30)),
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: '请填写验证码',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            30.0))),
                                            onChanged: (value) {
                                              setState(() {
                                                code = value;
                                              });
                                            },
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
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        submit();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                            Ui.width(24), Ui.width(30), Ui.width(24), 0),
                        width: Ui.width(702),
                        height: Ui.width(90),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(Ui.width(8.0))),
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
                          '预约卖车',
                          style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(30.0)),
                        ),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.fromLTRB(Ui.width(24), Ui.width(20), 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                checkboxValue = !checkboxValue;
                              });
                            },
                            child: Image.asset(
                              checkboxValue
                                  ? 'images/2.0x/selectxiyi.png'
                                  : 'images/2.0x/unselect.png',
                              width: Ui.width(30),
                              height: Ui.width(30),
                            ),
                          ),
                          SizedBox(
                            width: Ui.width(12),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/easywebview',
                                  arguments: {'url': 'apprlue'});
                            },
                            child: Container(
                              child: Text(
                                '我已阅读并同意《隐私协议》',
                                style: TextStyle(
                                    color: Color(0xFF9398A5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(26.0)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Ui.width(100),
                    )
                  ],
                ),
              ),
            )));
  }
}
