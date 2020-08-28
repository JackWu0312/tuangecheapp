import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluwx/fluwx.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:provider/provider.dart';
import '../../provider/IsInfo.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../common/Storage.dart';
import '../../provider/Successlogin.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/config.dart';
import '../../provider/Adopts.dart';
import 'package:url_launcher/url_launcher.dart';

class Info extends StatefulWidget {
  Info({Key key}) : super(key: key);

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  bool isloading = false;
  File _image;
  StreamSubscription<WeChatAuthResponse> _wxlogin;
   var flag = false;
  Timer timer;
  // var isfalge =true;
  @override
  void dispose() {
    timer = null;
     timers.cancel();
    _wxlogin.cancel();
    super.dispose();
  }
  var timers;
  var item;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");

    _wxlogin = fluwx.responseFromAuth.listen((data) {
      if (data.errCode != 0) {
        Toast.show("登陆失败～", context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      } else {
        getwechatCodes(data.code);
        // }
      }
    });
    timers = Timer.periodic(Duration(milliseconds: 3000), (timer) {
      // timers = timer;
      if (flag) {
        getdata();
      }
    });
  }

  getInfo() async {
    try {
      String token = await Storage.getString('info');
      return token;
    } catch (e) {
      return '';
    }
  }

  getwechatCodes(code) async {
    if (await getInfo() == 'info') {
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
      getuserinfo(json.decode(response.data));
    }
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
    // print('info');
    if (json.decode(response.data)['errcode'] != 41001) {
      wechatlogins(response.data);
    }
  }

  wechatlogins(data) async {
    int platform = 2;
    if (Platform.isIOS) {
      //ios相关代码
      platform = 3;
    } else if (Platform.isAndroid) {
      //android相关代码
      platform = 2;
    }
    data = json.decode(data);
    HttpUtlis.post("wx/auth/loginByweixin", params: {
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
        // await Storage.setString('userInfo', json.encode(value['data']['user']));
        // await Storage.setString('token', value['data']['token']);
        getdata();
        Toast.show('绑定成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        // timer = new Timer(new Duration(seconds: 1), () {
        //   Navigator.pop(context);
        // });
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
    await HttpUtlis.get('wx/user/detail', success: (value) {
      // print(value['data']);
      if (value['errno'] == 0) {
        setState(() {
          item = value['data'];
        });
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      setState(() {
        this.isloading = true;
      });
    });
  }

  getremove() async {
    await HttpUtlis.get('wx/user/remove', success: (value) async {
      if (value['errno'] == 0) {
        Toast.show('注销成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);

        await Storage.remove('token');
        await Storage.remove('userInfo');

        final counterss = Provider.of<Successlogin>(context);
        counterss.increment(true);
        Navigator.pop(context);
        Future.delayed(Duration(milliseconds: 200)).then((e) {
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

  uploadData(imageFile) async {
    // print(imageFile.path is String);
    String path = imageFile.path;
    // print(path);
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
    });
    var options =
        new BaseOptions(headers: {"Content-Type": "multipart/form-data"});
    Dio dio = Dio(options);
    // print(formData is FormData);
    var response =
        await dio.post("${Config.url}wx/file/upload", data: formData);
    // print(response);
    if (response.data['errno'] == 0) {
      upImage(response.data['data']['url']);
    } else {
      Toast.show('${response.data['errmsg']}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    }
  }

  upImage(image) async {
    await HttpUtlis.post("wx/user/update", params: {'avatar': image},
        success: (value) async {
      if (value['errno'] == 0) {
        getdata();
        Toast.show('修改成功～', context,
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

  getauthentication() async {
    await HttpUtlis.post("fdd/econtract/verify_url", params: {},
        success: (value) async {
      if (value['errno'] == 0) {
        var url = value['data']['registerUrl'];
        setState(() {
          flag=true;
        });
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          Toast.show('认证失败，请重试～', context,
              backgroundColor: Color(0xff5b5956),
              backgroundRadius: Ui.width(16),
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.CENTER);
        }
        // Navigator.pushNamed(context, '/authentication',
        //     arguments: {'url': value['data']['registerUrl']});
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  Future _openModalBottomSheet() async {
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200.0,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text('拍照', textAlign: TextAlign.center),
                  onTap: () async {
                    var image =
                        await ImagePicker.pickImage(source: ImageSource.camera);
                    uploadData(image);
                    Navigator.pop(context, '拍照');
                  },
                ),
                ListTile(
                  title: Text('从相册选择', textAlign: TextAlign.center),
                  onTap: () async {
                    var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    uploadData(image);
                    Navigator.pop(context, '从相册选择');
                  },
                ),
                ListTile(
                  title: Text('取消', textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.pop(context, '取消');
                  },
                ),
              ],
            ),
          );
        });
  }

  // Future getImage() async {

  //   setState(() {
  //     _image = image;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<IsInfo>(context);
    final counterAdopts = Provider.of<Adopts>(context);
    if (counter.count) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        counter.increment(false);
      });
      getdata();
    }
    if (counterAdopts.count) {
      print('counterAdopts');
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        counterAdopts.increment(false);
      });
      getdata();
    }
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
                              height: Ui.width(20),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(
                                  Ui.width(30), 0, Ui.width(30), 0),
                              child: Text('注销账户，账户相关联的信息将会删除且不可逆',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0))),
                            )
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
                                      onTap: () async {
                                        getremove();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text('确定',
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
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '个人信息',
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
      body: isloading
          ? Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Container(
                    child: ListView(
                      children: <Widget>[
                        Container(
                          height: Ui.width(160),
                          width: Ui.width(670),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '头像',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _openModalBottomSheet();
                                },
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          width: Ui.width(120),
                                          height: Ui.width(120),
                                          decoration: BoxDecoration(
                                            // shape: BoxShape.circle,
                                            // image: DecorationImage(
                                            //   image: AssetImage(
                                            //         'images/2.0x/loginnew.png')
                                            // ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    Ui.width(90.0))),
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 1 / 1,
                                            child: item['avatar'] == null
                                                ? Image.asset(
                                                    'images/2.0x/loginnew.png')
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            120.0),
                                                    child: CachedNetworkImage(
                                                      width: Ui.width(120),
                                                      height: Ui.width(120),
                                                      fit: BoxFit.fill,
                                                      imageUrl:
                                                          '${item['avatar']}',
                                                    ),
                                                    // Image.network(
                                                    //   '${item['avatar']}',
                                                    //   fit: BoxFit.cover,
                                                    //   width: Ui.width(120),
                                                    //   height: Ui.width(120),
                                                    // ),
                                                  ),
                                          )),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Image.asset(
                                            'images/2.0x/rightmy.png',
                                            width: Ui.width(13),
                                            height: Ui.height(26)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: Ui.width(120),
                          width: Ui.width(670),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '昵称',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (item['nickname'] != null) {
                                    Toast.show('昵称不允许修改～', context,
                                        backgroundColor: Color(0xff5b5956),
                                        backgroundRadius: Ui.width(16),
                                        duration: Toast.LENGTH_SHORT,
                                        gravity: Toast.CENTER);
                                  } else {
                                    Navigator.pushNamed(context, '/modifyname');
                                  }
                                },
                                child: Container(
                                  width: Ui.width(500),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(Ui.width(90.0))),
                                        ),
                                        child: Text(
                                          item['nickname'] != null
                                              ? '${item['nickname']}'
                                              : '',
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
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Image.asset(
                                            'images/2.0x/rightmy.png',
                                            width: Ui.width(13),
                                            height: Ui.height(26)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: Ui.width(120),
                          width: Ui.width(670),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '手机号',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/modifyphone');
                                },
                                child: Container(
                                  width: Ui.width(300),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(Ui.width(90.0))),
                                        ),
                                        child: Text(
                                          item['mobile'] != null
                                              ? '${item['mobile']}'
                                              : '',
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
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Image.asset(
                                            'images/2.0x/rightmy.png',
                                            width: Ui.width(13),
                                            height: Ui.height(26)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: Ui.width(120),
                          width: Ui.width(670),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '微信号',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (!item['bindWechat']) {
                                    fluwx.sendWeChatAuth(
                                        scope: "snsapi_userinfo",
                                        state: "wechat_sdk_demo_test");
                                  }
                                },
                                child: Container(
                                  width: Ui.width(300),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(Ui.width(90.0))),
                                        ),
                                        child: Text(
                                          !item['bindWechat'] ? '未绑定' : '已绑定',
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
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Image.asset(
                                            'images/2.0x/rightmy.png',
                                            width: Ui.width(13),
                                            height: Ui.height(26)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: Ui.width(120),
                          width: Ui.width(670),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '实名认证',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: Ui.width(300),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    Ui.width(90.0))),
                                          ),
                                          child: item['realname'] != null &&
                                                  item['idcard'] != null
                                              ? InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context, '/adopt',
                                                        arguments: {
                                                          'realname':
                                                              item['realname'],
                                                          'idcard':
                                                              item['idcard']
                                                        });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            Ui.width(5),
                                                            Ui.width(3),
                                                            Ui.width(5),
                                                            Ui.width(3)),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF347AFF),
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              Ui.width(10.0))),
                                                    ),
                                                    child: Text(
                                                      '已验证',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  26.0)),
                                                    ),
                                                  ),
                                                )
                                              : InkWell(
                                                  onTap: () {
                                                    if (item['mobile'] !=
                                                        null) {
                                                      getauthentication();
                                                    } else {
                                                      Toast.show(
                                                          '请先绑定手机号～', context,
                                                          backgroundColor:
                                                              Color(0xff5b5956),
                                                          backgroundRadius:
                                                              Ui.width(16),
                                                          duration: Toast
                                                              .LENGTH_SHORT,
                                                          gravity:
                                                              Toast.CENTER);
                                                    }
                                                  },
                                                  child: Text(
                                                    '点击实名认证',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF347AFF),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                30.0)),
                                                  ),
                                                )),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Image.asset(
                                            'images/2.0x/rightmy.png',
                                            width: Ui.width(13),
                                            height: Ui.height(26)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: Ui.width(120),
                          width: Ui.width(670),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(40), 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  '收货地址',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/addresslist');
                                },
                                child: Container(
                                  width: Ui.width(300),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(Ui.width(90.0))),
                                        ),
                                        child: Text(
                                          '',
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
                                        margin: EdgeInsets.fromLTRB(
                                            Ui.width(30), 0, 0, 0),
                                        child: Image.asset(
                                            'images/2.0x/rightmy.png',
                                            width: Ui.width(13),
                                            height: Ui.height(26)),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: Ui.width(140),
                      left: Ui.width(40),
                      child: InkWell(
                        onTap: () async {
                          await Storage.remove('token');
                          await Storage.remove('userInfo');
                          final counterss = Provider.of<Successlogin>(context);
                          counterss.increment(true);
                          Future.delayed(Duration(milliseconds: 200)).then((e) {
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          width: Ui.width(670),
                          height: Ui.width(80),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // color: Color(0xFFD10123),
                            border: Border.all(
                                width: Ui.width(1), color: Color(0xFFD10123)),
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(Ui.width(6.0))),
                          ),
                          child: Text(
                            '退出登陆',
                            style: TextStyle(
                                color: Color(0xFFD10123),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(28.0)),
                          ),
                        ),
                      )),
                  Positioned(
                      bottom: Ui.width(40),
                      left: Ui.width(40),
                      child: InkWell(
                        onTap: () async {
                          showtosh();
                          // await Storage.remove('token');
                          // await Storage.remove('userInfo');
                          // final counterss = Provider.of<Successlogin>(context);
                          // counterss.increment(true);
                          // Future.delayed(Duration(milliseconds: 200)).then((e) {
                          //   Navigator.pop(context);
                          // });
                        },
                        child: Container(
                          width: Ui.width(670),
                          height: Ui.width(80),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFD10123),
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(Ui.width(6.0))),
                          ),
                          child: Text(
                            '注销账户',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(28.0)),
                          ),
                        ),
                      ))
                ],
              ),
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
