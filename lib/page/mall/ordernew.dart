import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/Storage.dart';

class Ordernew extends StatefulWidget {
  final Map arguments;
  Ordernew({Key key, this.arguments}) : super(key: key);
  @override
  @override
  _OrdernewState createState() => _OrdernewState();
}

class _OrdernewState extends State<Ordernew> {
  var item = {};
  var obj = {};
  List list = [];
  List listlog = [];
  bool isloading = false;
  var stringnums = '';
  var shipper;
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

    getData();
  }

  getData() async {
    await HttpUtlis.get('wx/order/detail/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        var stringnum = '';
        var keylist = [];
        for (var key in value['data']['orderGoods'][0]['specifications'].keys) {
          keylist.add(key);
        }
        value['data']['orderGoods'][0]['specifications'].forEach((key, value) {
          if (keylist.length > 1) {
            stringnum = value + '/${stringnum}';
          } else {
            stringnum = value + '${stringnum}';
          }
        });
        if (keylist.length > 1) {
          stringnum = stringnum.substring(0, stringnum.length - 1);
        }

        setState(() {
          stringnums = stringnum;
          item = value['data'];
        });
        if (item['order']['status']['value'] >= 304) {
          getlogs();
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

  takeover(id) {
    HttpUtlis.post("wx/order/confirm", params: {'id': id},
        success: (value) async {
      if (value['errno'] == 0) {
        Toast.show('确认成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        getData();
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getlogs() async {
    await HttpUtlis.get('/wx/order/express/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          shipper = value['data'];
          list = value['data']['Traces'];
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
        width: Ui.width(680),
        height: Ui.width(230),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: Ui.width(70),
              top: Ui.width(-8),
              child: Container(
                // width: Ui.width(690),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${list[i]['Action']['label']}',
                        style: TextStyle(
                            decoration: TextDecoration.none,
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
                        '${list[i]['AcceptTime'].substring(0, 10)}',
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color:
                                i == 0 ? Color(0xFF111F37) : Color(0xFFC4C9D3),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0)),
                      ),
                    ),
                    Container(
                      width: Ui.width(600),
                      child: Text(
                        '${list[i]['AcceptStation']}',
                        style: TextStyle(
                            decoration: TextDecoration.none,
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
            ),
            Positioned(
              left: Ui.width(42),
              top: 0,
              child: Container(
                width: Ui.width(1),
                height: Ui.width(230),
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
    showtosh() {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                  width: Ui.width(700),
                  height: Ui.width(1030),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: Ui.width(700),
                        height: Ui.width(917),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(Ui.width(16.0))),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(
                                  0, Ui.width(30), 0, Ui.width(40)),
                              alignment: Alignment.center,
                              child: Text(
                                '${shipper['State']['label']}',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(32.0)),
                              ),
                            ),
                            Container(
                              width: Ui.width(640),
                              height: Ui.width(210),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 1,
                                          color: item['order']['takeSn'] != null
                                              ? Color(0xffFFFFFF)
                                              : Color(0xffEAEAEA)))),
                              margin:
                                  EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                              padding:
                                  EdgeInsets.fromLTRB(0, 0, 0, Ui.width(30)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(180),
                                    height: Ui.width(180),
                                    child: CachedNetworkImage(
                                        width: Ui.width(180),
                                        height: Ui.width(180),
                                        fit: BoxFit.fill,
                                        imageUrl:
                                            '${item['orderGoods'][0]['picUrl']}'),
                                    // decoration: BoxDecoration(
                                    //     image: DecorationImage(
                                    //         fit: BoxFit.fill,
                                    //         image: NetworkImage(
                                    //             '${item['orderGoods'][0]['picUrl']}'))),
                                  ),
                                  SizedBox(
                                    width: Ui.width(30),
                                  ),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(426),
                                          child: Text(
                                            '${item['orderGoods'][0]['goodsName']}',
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(28.0)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: Ui.width(15),
                                        ),
                                        Container(
                                          width: Ui.width(425),
                                          child: Text(
                                            '${shipper['shipperName']}：${shipper['LogisticCode']}',
                                            // maxLines: 3,
                                            // overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Color(0xFF5E6578),
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
                                ],
                              ),
                            ),
                            item['order']['takeSn'] != null
                                ? Container(
                                    margin: EdgeInsets.fromLTRB(
                                        Ui.width(76), 0, 0, 0),
                                    width: Ui.width(509),
                                    height: Ui.width(78),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(Ui.width(39.0))),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('取货码：',
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30.0))),
                                        Text('${item['order']['takeSn']}',
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Color(0xFFD10123),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(34.0))),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0, Ui.width(30),
                                    Ui.width(30), Ui.width(10)),
                                child: ListView(
                                  children: <Widget>[getitemlist()],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: Ui.width(320),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: Ui.width(62),
                              height: Ui.width(62),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      AssetImage('images/2.0x/closesing.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
            );
          });
    }

    showtoshsure(id) {
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
                            Text('是否确认收货～',
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
                                          borderRadius: BorderRadius.vertical(
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
                                        takeover(id);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    Ui.width(20)))),
                                        child: Text('确认',
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
              color: Color(0xFFF8F9FB),
              child: Stack(
                children: <Widget>[
                  Container(
                      child: ListView(children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: Ui.width(750),
                          height: Ui.width(350),
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: Ui.width(170),
                                width: Ui.width(750),
                                padding: EdgeInsets.fromLTRB(Ui.width(40), 0,
                                    Ui.width(40), Ui.width(15)),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          '${item['order']['status']['label']}',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.w600,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(32.0)),
                                        ),
                                        SizedBox(
                                          height: Ui.width(6),
                                        ),
                                        Text(
                                          '${item['order']['status']['message']}',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(26.0)),
                                        ),
                                      ],
                                    )),
                                    InkWell(
                                      onTap: () async {
                                        var tel =
                                            await Storage.getString('phone');
                                        var url =
                                            'tel:${tel.replaceAll(' ', '')}';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw '拨打失败';
                                        }
                                      },
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                                'images/2.0x/callspell.png',
                                                width: Ui.width(62),
                                                height: Ui.width(62)),
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
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      24.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                left: Ui.width(24),
                                top: Ui.width(150),
                                child: Container(
                                  width: Ui.width(702),
                                  height: Ui.width(186),
                                  // margin: EdgeInsets.fromLTRB(Ui.width(24),
                                  //     Ui.width(20), Ui.width(24), Ui.width(20)),
                                  padding: EdgeInsets.fromLTRB(Ui.width(26),
                                      Ui.width(30), Ui.width(0), Ui.width(0)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(Ui.width(8.0))),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: Ui.width(48),
                                        margin: EdgeInsets.fromLTRB(
                                            0, 0, Ui.width(30), 0),
                                        child: Image.asset(
                                            'images/2.0x/adress.png',
                                            width: Ui.width(48),
                                            height: Ui.width(48)),
                                      ),
                                      Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    '${item['order']['consignee']}  ${item['order']['mobile']}',
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
                                                    height: Ui.width(10),
                                                  ),
                                                  Text(
                                                    '${item['order']['address']}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF6A7182),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )),
                                      // Container(
                                      //   // width: Ui.width(48),
                                      //   margin: EdgeInsets.fromLTRB(
                                      //       Ui.width(10), 0, Ui.width(20), 0),
                                      //   child: Image.asset(
                                      //       'images/2.0x/rightmore.png',
                                      //       width: Ui.width(12),
                                      //       height: Ui.width(22)),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: Ui.width(185),
                        // ),
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(24), 0, Ui.width(24), 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: Ui.width(702),
                                constraints: BoxConstraints(
                                  // minHeight: Ui.width(572),
                                  minHeight: Ui.width(390),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(Ui.width(8.0))),
                                ),
                                // margin: EdgeInsets.fromLTRB(
                                //     Ui.width(24), 0, Ui.width(24), 0),
                                padding: EdgeInsets.fromLTRB(Ui.width(20),
                                    Ui.width(30), Ui.width(20), Ui.width(30)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: Ui.width(180),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                                        '${item['orderGoods'][0]['picUrl']}'),
                                            // decoration: BoxDecoration(
                                            //     image: DecorationImage(
                                            //         fit: BoxFit.fill,
                                            //         image: NetworkImage(
                                            //             '${item['orderGoods'][0]['picUrl']}'))),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              height: Ui.width(180),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Container(
                                                          child: Text(
                                                            "${item['orderGoods'][0]['goodsName']}",
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                                        28.0)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: Ui.width(16),
                                                        ),
                                                        Text(
                                                          item['order']['type'][
                                                                      'value'] ==
                                                                  6
                                                              ? '${stringnums}'
                                                              : '',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF9398A5),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
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
                                                      item['order']['type']
                                                                  ['value'] ==
                                                              6
                                                          ? '￥${item['orderGoods'][0]['price']}'
                                                          : '${item['orderGoods'][0]['points']}+￥${item['orderGoods'][0]['price']}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
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
                                              '${item['orderGoods'][0]['number']}X',
                                              style: TextStyle(
                                                  color: Color(0xFF9398A5),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      28.0)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          Ui.width(80), Ui.width(40), 0, 0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                          //               color:
                                          //                   Color(0xFF111F37),
                                          //               fontWeight:
                                          //                   FontWeight.w400,
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
                                          //               CrossAxisAlignment
                                          //                   .center,
                                          //           children: <Widget>[
                                          //             Container(
                                          //               child: Text(
                                          //                 '满300-20',
                                          //                 style: TextStyle(
                                          //                     color: Color(
                                          //                         0xFF9398A5),
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .w400,
                                          //                     fontFamily:
                                          //                         'PingFangSC-Medium,PingFang SC',
                                          //                     fontSize: Ui
                                          //                         .setFontSizeSetSp(
                                          //                             26.0)),
                                          //               ),
                                          //             ),
                                          //             InkWell(
                                          //                 onTap: () {
                                          //                   // couponBottomSheet();
                                          //                 },
                                          //                 child: Container(
                                          //                   child: Row(
                                          //                     mainAxisAlignment:
                                          //                         MainAxisAlignment
                                          //                             .start,
                                          //                     crossAxisAlignment:
                                          //                         CrossAxisAlignment
                                          //                             .center,
                                          //                     children: <
                                          //                         Widget>[
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
                                          //                               fontSize:
                                          //                                   Ui.setFontSizeSetSp(26.0)),
                                          //                         ),
                                          //                       ),
                                          //                       // SizedBox(
                                          //                       //   width:
                                          //                       //       Ui.width(19),
                                          //                       // ),
                                          //                       // Container(
                                          //                       //   child:
                                          //                       //       Image.asset(
                                          //                       //     'images/2.0x/rightmore.png',
                                          //                       //     width: Ui.width(
                                          //                       //         12),
                                          //                       //     height:
                                          //                       //         Ui.width(
                                          //                       //             22),
                                          //                       //   ),
                                          //                       // )
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
                                          //               color:
                                          //                   Color(0xFF111F37),
                                          //               fontWeight:
                                          //                   FontWeight.w400,
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
                                          //               CrossAxisAlignment
                                          //                   .center,
                                          //           children: <Widget>[
                                          //             Container(
                                          //               child: Text(
                                          //                 '可用2000积分抵扣20元',
                                          //                 style: TextStyle(
                                          //                     color: Color(
                                          //                         0xFF9398A5),
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .w400,
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
                                                        color:
                                                            Color(0xFF111F37),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    '${item['order']['message']}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF9398A5),
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
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            '共${item['orderGoods'][0]['number']}件',
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
                                            item['order']['type']['value'] == 6
                                                ? '￥${item['order']['actualPrice']}'
                                                : '${item['order']['integralPrice']}+￥${item['order']['actualPrice']}',
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Ui.width(20),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(Ui.width(24),
                              Ui.width(20), Ui.width(24), Ui.width(0)),
                          width: Ui.width(702),
                          height: Ui.width(218),
                          padding: EdgeInsets.fromLTRB(Ui.width(30),
                              Ui.width(40), Ui.width(30), Ui.width(40)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(Ui.width(8.0))),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Container(
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     crossAxisAlignment: CrossAxisAlignment.center,
                              //     children: <Widget>[
                              //       Text(
                              //         '订单��道',
                              //         style: TextStyle(
                              //             color: Color(0xFF111F37),
                              //             fontWeight: FontWeight.w400,
                              //             fontFamily:
                              //                 'PingFangSC-Medium,PingFang SC',
                              //             fontSize: Ui.setFontSizeSetSp(26.0)),
                              //       ),
                              //       SizedBox(
                              //         width: Ui.width(30),
                              //       ),
                              //       Text(
                              //         '手机商城',
                              //         style: TextStyle(
                              //             color: Color(0xFF9398A5),
                              //             fontWeight: FontWeight.w400,
                              //             fontFamily:
                              //                 'PingFangSC-Medium,PingFang SC',
                              //             fontSize: Ui.setFontSizeSetSp(26.0)),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '订单编号',
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                    SizedBox(
                                      width: Ui.width(30),
                                    ),
                                    Text(
                                      '${item['order']['orderSn']}',
                                      style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '下单时间',
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                    SizedBox(
                                      width: Ui.width(30),
                                    ),
                                    Text(
                                      '${item['order']['addTime'].substring(0, 10)}',
                                      style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Ui.width(120),
                        )
                      ],
                    ),
                  ])),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: item['order']['status']['value'] >= 304
                        ? Container(
                            width: Ui.width(750),
                            height: Ui.width(110),
                            padding: EdgeInsets.fromLTRB(0, 0, Ui.width(24), 0),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                item['order']['status']['value'] >= 304
                                    ? InkWell(
                                        onTap: () {
                                          showtosh();
                                        },
                                        child: Container(
                                          width: Ui.width(180),
                                          height: Ui.width(64),
                                          margin: EdgeInsets.fromLTRB(
                                              Ui.width(20), 0, 0, 0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: Ui.width(1),
                                                color: Color(0xFF9398A5)),
                                            borderRadius: new BorderRadius.all(
                                                new Radius.circular(
                                                    Ui.width(5.0))),
                                          ),
                                          child: Text(
                                            '查看物流',
                                            style: TextStyle(
                                                color: Color(0xFF5E6578),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(28.0)),
                                          ),
                                        ),
                                      )
                                    : Text(''),
                                item['order']['status']['value'] == 304
                                    ? InkWell(
                                        onTap: () {
                                          showtoshsure(item['order']['id']);
                                        },
                                        child: Container(
                                          width: Ui.width(180),
                                          height: Ui.width(64),
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.fromLTRB(
                                              Ui.width(20), 0, 0, 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: Ui.width(1),
                                                color: Color(0xFFD10123)),
                                            borderRadius: new BorderRadius.all(
                                                new Radius.circular(
                                                    Ui.width(5.0))),
                                          ),
                                          child: Text(
                                            '确认收货',
                                            style: TextStyle(
                                                color: Color(0xFFD10123),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(28.0)),
                                          ),
                                        ),
                                      )
                                    : Text('')
                              ],
                            ),
                          )
                        : Text(''),
                  )
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
