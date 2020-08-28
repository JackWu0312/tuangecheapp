import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:city_pickers/city_pickers.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/Storage.dart';
import '../../common/LoadingDialog.dart';

class Appointment extends StatefulWidget {
  final Map arguments;
  Appointment({Key key, this.arguments}) : super(key: key);
  @override
  _AppointmentState createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  String goodsId = '';
  bool isloading = false;
  String name = '';
  String phone = '';
  String city = '';
  String remark = '';
  Timer timer;
  var item;
  var _initnameController = new TextEditingController();
  var _initphoneController =new TextEditingController();
  var _initremarkController =new TextEditingController();
  void initState() {
    super.initState();
    getdata();
    getCity();
  }

  getdata() async {
    await HttpUtlis.get('wx/topic/detail/goods/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          goodsId = value['data']['id'];
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
    setState(() {
      this.isloading = true;
    });
  }

  getCity() async {
    var citys = await Storage.getString('city');
    setState(() {
      city = citys;
    });
  }

  submit(showtosh) async {
    if (this.name == '') {
      Toast.show("请输入姓名", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    if (!RegExp(r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$")
        .hasMatch(phone)) {
      Toast.show("请输入正确的手机号码", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }
    if (this.city == '') {
      Toast.show("请选择城市", context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
      return;
    }

    await HttpUtlis.post("wx/book/submit", params: {
      "goodsId": goodsId,
      'name': name,
      'phone': phone,
      'city': city,
      'remark': remark
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
      } else if (value['errno'] == 401) {
        showtosh();
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
                                              borderRadius:
                                                  BorderRadius.vertical(
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
                                              borderRadius:
                                                  BorderRadius.vertical(
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

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '预约抢购',
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
                        padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(130)),
                        child: ListView(
                          children: <Widget>[
                            Container(
                              width: Ui.width(750),
                              height: Ui.width(631),
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                          color: Colors.red,
                                          height: Ui.height(563.0),
                                          width: Ui.width(750.0),
                                          child: Swiper(
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, '/easywebview',
                                                      arguments: {
                                                        'url':
                                                            'appimage/${item['goods']['id']}'
                                                      });
                                                },
                                                child: CachedNetworkImage(
                                                    height: Ui.height(563.0),
                                                     width: Ui.width(750.0),
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        '${item['goods']['picUrl']}',),
                                                
                                                // Image.network(
                                                //   '${item['goods']['picUrl']}',
                                                //   fit: BoxFit.fill,
                                                // ),
                                              );
                                            },
                                            itemCount: 1,
                                            autoplay: false,
                                          ))),
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: Ui.height(95.0),
                                      width: Ui.width(750.0),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image: AssetImage(
                                            'images/2.0x/assemble.png'),
                                        // fit: BoxFit.cover,
                                      )),
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.fromLTRB(
                                              Ui.width(220), 0, 0, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                '预告价：',
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            26.0)),
                                              ),
                                              Text(
                                                '${item['price']}${item['goods']['unit']}',
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            36.0)),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: Ui.width(196),
                                      height: Ui.width(107),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                        image:
                                            AssetImage('images/2.0x/expl.png'),
                                      )),
                                      child: Container(
                                        padding: EdgeInsets.fromLTRB(
                                            0, Ui.width(10), 0, 0),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '爆款推荐',
                                          style: TextStyle(
                                              color: Color(0xFF7F3A1C),
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(34.0)),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: Ui.width(750),
                              constraints: BoxConstraints(
                                minHeight: Ui.width(115),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.fromLTRB(Ui.width(30),
                                  Ui.width(30), Ui.width(30), Ui.width(30)),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: Ui.width(16),
                                          color: Color(0xFFF8F9FB)))),
                              child: Text(
                                '${item['goods']['name']}',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(36.0)),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(30), Ui.width(40), 0, Ui.width(10)),
                              child: Text(
                                '个人信息填写',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(32.0)),
                              ),
                            ),
                            Container(
                              width: Ui.width(690),
                              height: Ui.width(109),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(30), 0, Ui.width(30), 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: Ui.width(1),
                                          color: Color(0xFFEEEFF2)))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(190),
                                    height: Ui.width(109),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '购车人姓名',
                                      style: TextStyle(
                                          color: Color(0xFF6A7182),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      autofocus: false,
                                      controller: _initnameController,
                                      // textInputAction: TextInputAction.none,
                                      keyboardAppearance: Brightness.light,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: Color(0XFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontSize: Ui.setFontSizeSetSp(28)),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '请输入您的姓名',
                                          hintStyle: TextStyle(
                                              color: Color(0xFFC4C9D3),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Helvetica;',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0))),
                                      onChanged: (value) {
                                        name = value;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: Ui.width(690),
                              height: Ui.width(109),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(30), 0, Ui.width(30), 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: Ui.width(1),
                                          color: Color(0xFFEEEFF2)))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(190),
                                    height: Ui.width(109),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '购车者电话',
                                      style: TextStyle(
                                          color: Color(0xFF6A7182),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      autofocus: false,
                                      controller: _initphoneController,
                                      // textInputAction: TextInputAction.none,
                                      keyboardAppearance: Brightness.light,
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(
                                          color: Color(0XFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontSize: Ui.setFontSizeSetSp(28)),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '请输入您的手机号码',
                                          hintStyle: TextStyle(
                                              color: Color(0xFFC4C9D3),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Helvetica;',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0))),
                                      onChanged: (value) {
                                        phone = value;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: Ui.width(690),
                              height: Ui.width(109),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(30), 0, Ui.width(30), 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: Ui.width(1),
                                          color: Color(0xFFEEEFF2)))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(190),
                                    height: Ui.width(109),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '所在城市',
                                      style: TextStyle(
                                          color: Color(0xFF6A7182),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
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
                                                          TextDecoration.none,
                                                      color: Color(0xFF3895FF),
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
                                                          TextDecoration.none,
                                                      color: Color(0xFF3895FF),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              28.0))));
                                          if (result != null) {
                                            setState(() {
                                              // province = result.provinceName;
                                              city = result.cityName;
                                              // county = result.areaName;
                                            });
                                          }
                                        },
                                        child: Container(
                                            // height: Ui.width(60),
                                            width: Ui.width(400),
                                            alignment: Alignment.centerLeft,
                                            // color: Colors.white,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  this.city != null
                                                      ? "${this.city}"
                                                      : '',
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
                                                // SizedBox(
                                                //   width: Ui.width(20),
                                                // ),
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
                              width: Ui.width(690),
                              height: Ui.width(109),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(30), 0, Ui.width(30), 0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: Ui.width(1),
                                          color: Color(0xFFEEEFF2)))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(190),
                                    height: Ui.width(109),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '备注',
                                      style: TextStyle(
                                          color: Color(0xFF6A7182),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(28.0)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      autofocus: false,
                                       controller: _initremarkController,
                                      // textInputAction: TextInputAction.none,
                                      keyboardAppearance: Brightness.light,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: Color(0XFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontSize: Ui.setFontSizeSetSp(28)),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: '请输入您的备注',
                                          hintStyle: TextStyle(
                                              color: Color(0xFFC4C9D3),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Helvetica;',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(28.0))),
                                      onChanged: (value) {
                                        remark = value;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          child: InkWell(
                            onTap: () {
                              submit(showtosh);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: Ui.width(750),
                              height: Ui.width(90),
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
                                '立即预约',
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
                )
              : Container(
                  child: LoadingDialog(
                    text: "加载中…",
                  ),
                ),
        ));
  }
}
