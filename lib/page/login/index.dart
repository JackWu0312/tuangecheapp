import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import '../../ui/ui.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import '../../http/index.dart';
import '../../common/Storage.dart';
import 'dart:convert';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'dart:io';
// import 'dart:async';
import 'package:dio/dio.dart';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';
import '../../provider/Successlogin.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _text = '获取验证码';
  Timer _countdownTimer;
  int _countdownNum = 180;
  bool check = false;
  String mobile = '';
  String code = '';
  // 不要忘记在这里释放掉Timer
  bool result = false;
  Timer timer;
  var counter;
  bool iswecat=true;
  StreamSubscription<WeChatAuthResponse> _wxlogin;
  // var isfalge = true;
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    timer?.cancel();
    timer = null;
    _wxlogin.cancel();
    // contexts=null;
    super.dispose();
    // contexts.dispose();
    // _result = null;
  }

  void initState() {
    // _initFluwx();
    // fluwx.register(appId:"wxd930ea5d5a258f4f");
// fluwx.sendAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
    super.initState();
    // _initFluwx();
    getwecat();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");

    _wxlogin = fluwx.responseFromAuth.listen((data) {
      // print(data.errCode);
      if (data.errCode != 0) {
        Toast.show("登陆失败～", context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      } else {
        // Future.delayed(Duration(seconds: 2)).then((e) {
        getwechatCode(data.code);
        // });
      }

      // print(json.encode(data.code));
      // print(data.code);
      // print(data.errCode != 0);
      //  print(data[]);
      //do something.
    });
    // fluwx.responseFromAuth.listen((data) {
    //   print('object');
    //   print(data);

    //   setState(() {
    //     _result = "${data.errCode}";
    //   });
    // });
  }

  getwecat() async {
    if (Platform.isIOS) {
      final url = "wechat://";
      if (await canLaunch(url)) {
       setState(() {
         iswecat=true;
       });
      }else{
         setState(() {
         iswecat=false;
       });
      }
    }
  }

  getInfo() async {
    try {
      String token = await Storage.getString('info');
      return token;
    } catch (e) {
      return '';
    }
  }

  getwechatCode(code) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
        "https://api.weixin.qq.com/sns/oauth2/access_token",
        queryParameters: {
          "appid": 'wx234a903f1faba1f9',
          "secret": "17c23c31c06fb622c16c546ddf427657",
          "code": code,
          'grant_type': 'authorization_code'
        });

    // wechatlogin(response.data);
    await getuserinfo(json.decode(response.data));
  }

  getuserinfo(data) async {
    Response response;
    Dio dio = new Dio();
    response = await dio
        .get("https://api.weixin.qq.com/sns/userinfo", queryParameters: {
      "access_token": data['access_token'],
      "openid": data['openid'],
      "lang": 'zh_CN',
    });
    // print('sssssssss');
    // print(json.decode(response.data)['errcode'] != 41001);
//  if(await getInfo()=='login'){
    // await Storage.setString("info", "info");
    if (json.decode(response.data)['errcode'] != 41001) {
      // await Storage.setString("info", "info");
      await wechatlogin(response.data);
    }
  }

  wechatlogin(data) async {
    int platform = 2;
    if (Platform.isIOS) {
      //ios相关代码
      platform = 3;
    } else if (Platform.isAndroid) {
      //android相关代码
      platform = 2;
    }
    data = json.decode(data);
    // print(data);
    await HttpUtlis.post("wx/auth/loginByweixin", params: {
      // 'mobile': mobile,
      // 'code': code,
      'platform': {'value': platform},
      'userInfo': {
        "openid": data['openid'],
        "unionid": data['unionid'],
        "nickName": data['nickname'],
        "avatarUrl": data['headimgurl'],
        "country": data['country'],
        "province": data['province'],
        "city": data['city'],
        "language": "zh_CN ",
        "gender": data['sex']
      }
    }, success: (value) async {
      if (value['errno'] == 0) {
        // setState(() {
        //   isfalge = true;
        // });
        await Storage.setString('userInfo', json.encode(value['data']['user']));
        await Storage.setString('token', value['data']['token']);
        await Storage.setString("info", "login");
        // print(context);
        if (context != null) {
          Toast.show('登陆成功～', context,
              backgroundColor: Color(0xff5b5956),
              backgroundRadius: Ui.width(16),
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.CENTER);
        }
        Future.delayed(Duration(milliseconds: 100)).then((e) {
          counter.increment(true);
        });
        timer = new Timer(new Duration(seconds: 1), () {
          if (context != null) {
            Navigator.pop(context);
          }
        });
      }
    }, failure: (error) {
      // print('objectsss');
      // print(error);
      if (context != null) {
        Toast.show('${error}', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      }
    });
    //  setState(() {
    //   isfalge=true;
    // });
  }

  getCode() async {
    Toast.show("发送成功～", context,
        backgroundColor: Color(0xff5b5956),
        backgroundRadius: Ui.width(16),
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.CENTER);
    HttpUtlis.post("wx/auth/captcha", params: {'mobile': mobile},
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          if (_countdownTimer != null) {
            return;
          }
          // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
          _text = '${_countdownNum--}S 重新获取';
          _countdownTimer =
              new Timer.periodic(new Duration(seconds: 1), (timer) {
            setState(() {
              if (_countdownNum > 0) {
                _text = '${_countdownNum--}S 重新获取';
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

  submit() {
    if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
        .hasMatch(mobile)) {
      Toast.show("请输入正确的手机号码", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    if (this.code == '') {
      Toast.show("请输入验证码", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    if (!check) {
      Toast.show("请勾注册协议", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    var platform = 2;
    if (Platform.isIOS) {
      //ios相关代码
      platform = 3;
    } else if (Platform.isAndroid) {
      //android相关代码
      platform = 2;
    }
    HttpUtlis.post("wx/auth/loginByMobile", params: {
      'mobile': mobile,
      'code': code,
      'platform': {'value': platform}
    }, success: (value) async {
      if (value['errno'] == 0) {
        await Storage.setString('userInfo', json.encode(value['data']['user']));
        Storage.setString('token', value['data']['token']);
        Toast.show('登陆成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        // final counter = Provider.of<Successlogin>(context);
        counter.increment(true);
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

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    counter = Provider.of<Successlogin>(context);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
                title: Text(
                  '登陆',
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
            body: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                height: Ui.height(1200.0),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.fromLTRB(0, Ui.width(120.0), 0, 0),
                        child: Center(
                          child: Image.asset('images/2.0x/loginnew.png',
                              width: Ui.width(190.0), height: Ui.height(190.0)),
                        )),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          Ui.width(65.0), Ui.height(100.0), Ui.width(65.0), 0),
                      // padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(15.0)),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0XFFF1F1F1), width: 1.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('images/2.0x/phone.png',
                              width: Ui.width(26.0), height: Ui.height(40.0)),
                          SizedBox(
                            width: Ui.width(20.0),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              autofocus: false,
                              // textInputAction: TextInputAction.none,
                              keyboardAppearance: Brightness.light,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(32)),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '手机号',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Helvetica;',
                                      fontSize: Ui.setFontSizeSetSp(28.0))),
                              onChanged: (value) {
                                mobile = value;
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          Ui.width(65.0), Ui.height(50.0), Ui.width(65.0), 0),
                      // padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(15.0)),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0XFFF1F1F1), width: 1.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('images/2.0x/mobile.png',
                              width: Ui.width(26.0), height: Ui.height(40.0)),
                          SizedBox(
                            width: Ui.width(20.0),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              autofocus: false,
                              // textInputAction: TextInputAction.none,
                              keyboardAppearance: Brightness.light,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(32)),
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '验证码',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Helvetica;',
                                      fontSize: Ui.setFontSizeSetSp(28.0))),
                              onChanged: (value) {
                                setState(() {
                                  code = value;
                                });
                              },
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (!RegExp(
                                      r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
                                  .hasMatch(mobile)) {
                                Toast.show("请输入正确的手机号码", context,
                                    backgroundColor: Color(0xff5b5956),
                                    backgroundRadius: Ui.width(16),
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.CENTER);
                                return;
                              }
                              getCode();
                            },
                            child: Container(
                              // padding: EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                              child: Text('${_text}',
                                  style: TextStyle(
                                      color: Color(0xFFD10123),
                                      fontSize: Ui.setFontSizeSetSp(32),
                                      fontFamily:
                                          'PingFangSC-Regular,PingFang SC')),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          Ui.width(100), Ui.width(100), 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                check = !check;
                              });
                            },
                            child: Container(
                              width: Ui.width(30),
                              height: Ui.width(30),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 1, color: Color(0XFFC4C9D3))),
                              child: check
                                  ? Icon(
                                      Icons.check,
                                      size: Ui.setFontSizeSetSp(24),
                                      color: Color(0xFFD10123),
                                    )
                                  : Icon(
                                      Icons.check_box_outline_blank,
                                      size: Ui.setFontSizeSetSp(24),
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: Ui.width(15),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/easywebview',
                                  arguments: {'url': 'apprlue'});
                            },
                            child: Text(
                              '我已阅读《注册协议》',
                              style: TextStyle(
                                  color: Color(0XFFC4C9D3),
                                  fontSize: Ui.setFontSizeSetSp(26),
                                  fontWeight: FontWeight.w400,
                                  fontFamily:
                                      'PingFangSC-Regular,PingFang SC;'),
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          // counter.increment(true);
                          submit();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                margin:
                                    EdgeInsets.fromLTRB(0, Ui.width(16), 0, 0),
                                width: Ui.width(630),
                                height: Ui.height(90),
                                decoration: BoxDecoration(
                                  color: Color(0XFFD10123),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Ui.width(90.0))),
                                ),
                                child: Center(
                                  child: Text(
                                    '登陆',
                                    style: TextStyle(
                                        color: Color(0XFFFFFFFF),
                                        fontSize: Ui.setFontSizeSetSp(32),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Regular,PingFang SC'),
                                  ),
                                )),
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, Ui.width(80), 0, 0),
                        child:iswecat? Center(
                          child: Text(
                            '—— 使用第三方登录 ——',
                            style: TextStyle(
                                color: Color(0XFF111F37),
                                fontSize: Ui.setFontSizeSetSp(26),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Regular,PingFang SC'),
                          ),
                        ):Text('')),
                    Container(
                        width: double.infinity,
                        margin: EdgeInsets.fromLTRB(0, Ui.width(40), 0, 0),
                        child: iswecat?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                Future.delayed(Duration(milliseconds: 100))
                                    .then((e) {
                                  fluwx.sendWeChatAuth(
                                      scope: "snsapi_userinfo",
                                      state: "wechat_sdk_demo_test");
                                });
                               
                              },
                              child: Container(
                                width: Ui.width(100.0),
                                height: Ui.height(100.0),
                                child: Image.asset('images/2.0x/wechat.png',
                                    width: Ui.width(100.0),
                                    height: Ui.height(100.0)),
                              ),
                            )
                          ],
                        ):Text(''))
                  ],
                ),
              ),
            )));
  }
}
