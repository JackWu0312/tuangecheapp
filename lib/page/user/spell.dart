import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/Storage.dart';

class Spell extends StatefulWidget {
  final Map arguments;
  Spell({Key key, this.arguments}) : super(key: key);
  @override
  _SpellState createState() => _SpellState();
}

class _SpellState extends State<Spell> {
  var item = {};
  var obj = {};
  List list = [];
  bool isloading = false;
  Map pice = {
    "101": "订单未付款",
    "102": "订单已取消",
    "103": "订单已超时",
    "201": "已付款",
    "202": "订单取消，退款中",
    "203": "已退款",
    "301": "已回访，等待签约",
    "302": "已到账",
    "303": '取车码',
    "304": "已出库，待收货",
    "401": "已收货，订单完成",
    "402": "已收货，订单完成"
  };

  @override
  void initState() {
    super.initState();
    getlogs();
    getData();
  }

  getcontract() async {
    await HttpUtlis.get('wx/order/contract/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        // print(value['data']);
        setState(() {
          obj = value['data'];  
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
    await HttpUtlis.get('wx/order/detail/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        // print(value['data']['order']['type']['value']);
        setState(() {
          item = value['data'];
        });
        if (value['data']['order']['type']['value'] == 1) {
          if (value['data']['order']['status']['value'] == 303 
            ) {
            getcontract();
          }
        }
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

  getlogs() async {
    await HttpUtlis.get('wx/order/logs/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          list = value['data'];
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

  getitemlist() {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var i = 0, len = list.length; i < len; i++) {
      tiles.add(Container(
        width: Ui.width(750),
        height: Ui.width(230),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: Ui.width(42),
              top: 0,
              child: Container(
                width: Ui.width(1),
                height: Ui.width(220),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            width: Ui.width(1), color: Color(0xFFE9ECF1)))),
              ),
            ),
            Positioned(
                left: i != 0 ? Ui.width(34) : Ui.width(28),
                top: 0,
                child: i != 0
                    ? Container(
                        width: Ui.width(18),
                        height: Ui.width(18),
                        decoration: BoxDecoration(
                            color: Color(0xFFC4C9D3),
                            borderRadius: BorderRadius.all(
                              Radius.circular(18),
                            )),
                      )
                    : Container(
                        width: Ui.width(30),
                        height: Ui.width(30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            border: Border.all(
                                width: Ui.width(2), color: Color(0xFFD10123)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            )),
                        child: Container(
                          width: Ui.width(18),
                          height: Ui.width(18),
                          decoration: BoxDecoration(
                              color: Color(0xFFD10123),
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              )),
                        ))),
            Positioned(
              left: Ui.width(70),
              top: Ui.width(-8),
              child: Container(
                width: Ui.width(645),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${list[i]['status']['label']}',
                        style: TextStyle(
                            color:
                                i == 0 ? Color(0xFFD10123) : Color(0xFF111F37),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(30.0)),
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.fromLTRB(0, Ui.width(23), 0, Ui.width(15)),
                      child: Text(
                        '${list[i]['addTime']}',
                        style: TextStyle(
                            color:
                                i == 0 ? Color(0xFF111F37) : Color(0xFFC4C9D3),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0)),
                      ),
                    ),
                    Container(
                      child: Text(
                        '${list[i]['status']['remark']}',
                        style: TextStyle(
                            color:
                                i == 0 ? Color(0xFF111F37) : Color(0xFFC4C9D3),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ));
    }
    content = new Column(
      children: tiles,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的订单',
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
              child: ListView(
                children: <Widget>[
                  Container(
                    height: Ui.width(150),
                    width: Ui.width(750),
                    padding:
                        EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFD92818),
                          Color(0xFFEE6C35),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text(
                            item['order']['orderSn'] != null
                                ? '订单单号：${item['order']['orderSn']}'
                                : '订单单号：',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(30.0)),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            var tel = await Storage.getString('phone');
                            var url = 'tel:${tel.replaceAll(' ', '')}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw '拨打失败';
                            }
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('images/2.0x/callspell.png',
                                    width: Ui.width(62), height: Ui.width(62)),
                                SizedBox(
                                  height: Ui.width(10),
                                ),
                                Text(
                                  '客服电话',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(24.0)),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: Ui.width(750),
                    height: Ui.width(375),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(0, Ui.width(60), 0, 0),
                          child: Text(
                            item['agent'] != null
                                ? '${item['agent']['name']}'
                                : '',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(30.0)),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, item['order']['status']['value'] == 303 ?Ui.width(30):Ui.width(70), 0, 0),
                          child: Text(
                            "${pice['${item['order']['status']['value']}']}",
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(32.0)),
                          ),
                        ),
                        Container(
                          child: item['order']['type']['value'] == 1
                              ? item['order']['status']['value'] == 303 
                                  ? Container(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                           SizedBox(height: Ui.width(20),),
                                         item['order']['status']['value'] == 303 ?  Text(
                                           '${item['order']['takeSn']}',
                                            style: TextStyle(
                                                color: Color(0xFFD10123),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(50.0)),
                                          ):Text(''),
                                          SizedBox(height: Ui.width(20),),
                                          InkWell(
                                            onTap: () async {
                                              var url = '${obj['viewPdfUrl']}';
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                Toast.show('查看失败～', context,
                                                    backgroundColor:
                                                        Color(0xff5b5956),
                                                    backgroundRadius:
                                                        Ui.width(16),
                                                    duration:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: Toast.CENTER);
                                              }
                                            },
                                            child: Container(
                                              width: Ui.width(150),
                                              height: Ui.width(60),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFD92818),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        Ui.width(6.0))),
                                              ),
                                              child: Text(
                                                '查看合同',
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            28.0)),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Text('')
                              : Text(''),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: Ui.width(750),
                    height: Ui.width(100),
                    padding: EdgeInsets.fromLTRB(Ui.width(40), 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        border: Border(
                      top: BorderSide(
                          width: Ui.width(16), color: Color(0xFFF8F9FB)),
                      bottom: BorderSide(
                          width: Ui.width(1), color: Color(0xFFF8F9FB)),
                    )),
                    child: Text(
                      '订单进度',
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(32.0)),
                    ),
                  ),
                  Container(
                      width: Ui.width(750),
                      margin:
                          EdgeInsets.fromLTRB(0, Ui.width(30), 0, Ui.width(30)),
                      child: getitemlist())
                ],
              ),
            )
          : Container(
              child: LoadingDialog(
                text: "加载中…",
              ),
            ),
    );
  }
}
