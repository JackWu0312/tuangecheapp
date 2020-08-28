import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/Storage.dart';

class Stage extends StatefulWidget {
  final Map arguments;
  Stage({Key key, this.arguments}) : super(key: key);
  @override
  _StageState createState() => _StageState();
}

class _StageState extends State<Stage> {
  int active = 0;
  bool isloading = false;
  List list = [];
  List goodlist = [];
  Timer _timer;
  int seconds;
  var item;
  Timer timer;
  var data;
//时间格式化，根据总秒数转换为对应的 hh:mm:ss 格式
  constructTime(int seconds) {
    int day = (seconds ~/ 3600) ~/ 24;
    int hour = (seconds ~/ 3600) % 24;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    var data = {
      'day': formatTime(day),
      'hour': formatTime(hour),
      'minute': formatTime(minute),
      'second': formatTime(second)
    };
    return data;
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  @override
  void initState() {
    super.initState();
    getdata();
  }

  void startTimer() {
    //设置 1 秒回调一次
    const period = const Duration(seconds: 1);
    _timer = Timer.periodic(period, (timer) {
      //更新界面
      if (seconds != 0) {
        setState(() {
          //秒数减一，因为一秒回调一次
          seconds--;
        });
      }

      if (seconds == 0) {
        //倒计时秒数为0，取消定时器
        cancelTimer();
      }
    });
  }

  void cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelTimer();
  }

  getdata() async {
    await HttpUtlis.get('wx/topic/next', success: (value) {
      if (value['errno'] == 0) {
        //获取当期时间
        var now = DateTime.now();
        // print(now.millisecondsSinceEpoch);
        // print(DateTime.parse(endtime).millisecondsSinceEpoch);
        //获取 2 分钟的时间间隔
        // var twoHours = now.add(Duration(minutes: 10)).difference(now);
        //获取总秒数，2 分钟为 120 秒
        // seconds = twoHours.inSeconds;

        if (DateTime.parse(value['data'][0]['startTime'])
                    .millisecondsSinceEpoch -
                now.millisecondsSinceEpoch >
            0) {
          seconds = (DateTime.parse(value['data'][0]['startTime'])
                      .millisecondsSinceEpoch -
                  now.millisecondsSinceEpoch) ~/
              1000;
        } else {
          seconds = 0;
        }
        startTimer();

        setState(() {
          list = value['data'];
        });
        gettopic(value['data'][0]['id']);
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

  gettopic(id) async {
    await HttpUtlis.get('wx/topic/detail/${id}', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          goodlist = value['data']['topicGoods'];
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
    for (var item in goodlist) {
      tiles.add(Container(
        width: Ui.width(690),
        padding:
            EdgeInsets.fromLTRB(Ui.width(30), Ui.width(30), Ui.width(30), 0),
        margin: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(20)),
        constraints: BoxConstraints(
          minHeight: Ui.width(270),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              new BorderRadius.all(new Radius.circular(Ui.width(15.0))),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '${item['goods']['name']}',
                style: TextStyle(
                    color: Color(0xFF111F37),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                    fontSize: Ui.setFontSizeSetSp(32.0)),
              ),
            ),
            Container(
              height: Ui.width(188),
              // width: Ui.width(690),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, 0),
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: '预告价:',
                                style: TextStyle(
                                    color: Color(0xFFED3221),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(26.0)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '${item['price']}${item['goods']['unit']}',
                                    style: TextStyle(
                                        fontSize: Ui.setFontSizeSetSp(32.0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, 0),
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: '官方指导价:',
                                style: TextStyle(
                                    color: Color(0xFF9398A5),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(24.0)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text:
                                        '${item['goods']['counterPrice']}${item['goods']['unit']}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                    width: Ui.width(115),
                                    height: Ui.width(57),
                                    padding: EdgeInsets.fromLTRB(
                                        0, 0, Ui.width(10), 0),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image:
                                          AssetImage('images/2.0x/inquiry.png'),
                                    )),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '咨询',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/appointment',
                                        arguments: {'id': item['id']});
                                  },
                                  child: Container(
                                    width: Ui.width(153),
                                    height: Ui.width(57),
                                    padding: EdgeInsets.fromLTRB(
                                        Ui.width(10), 0, 0, 0),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      image: AssetImage('images/2.0x/make.png'),
                                    )),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '预约',
                                      style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: Ui.width(250),
                    height: Ui.width(188),
                    // color: Colors.red,
                    child: CachedNetworkImage(
                      width: Ui.width(250),
                      height: Ui.width(188),
                      fit: BoxFit.fill,
                      imageUrl: '${item['goods']['picUrl']}',
                    ),

                    // AspectRatio(
                    //   aspectRatio: 4 / 3,
                    //   child: Image.network(
                    //    '${item['goods']['picUrl']}',
                    //   ),
                    // ),
                  )
                ],
              ),
            )
          ],
        ),
      ));
    }
    content = new Column(children: tiles);
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '下期预告',
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
              color: Color(0xFF2C0B94),
              child: ListView(
                children: <Widget>[
                  Container(
                      width: Ui.width(750),
                      height: Ui.height(300.0),
                      alignment: Alignment.center,
                      child: Swiper(
                        itemBuilder: (BuildContext context, int index) {
                          return CachedNetworkImage(
                            width: Ui.width(750),
                            height: Ui.height(300.0),
                            fit: BoxFit.fill,
                            imageUrl: '${widget.arguments['url']}',
                          );

                          // new Image.network(
                          //   '${widget.arguments['url']}',
                          //   fit: BoxFit.fill,
                          // );
                        },
                        itemCount: 1,
                        autoplay: false,
                      )),
                  Container(
                    width: Ui.width(690),
                    height: Ui.width(125),
                    margin:
                        EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFF411EB0),
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(Ui.width(14.0))),
                    ),
                    child: Container(
                      width: Ui.width(690),
                      height: Ui.width(102),
                      decoration: BoxDecoration(
                          color: Color(0xFF6238E5),
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(Ui.width(14.0))),
                          border: Border.all(
                            width: Ui.width(1),
                            color: Color(0xFFFFFFFF),
                          )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '距离活动开始仅剩',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(24.0)),
                          ),
                          Container(
                            width: Ui.width(56),
                            height: Ui.width(56),
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(13), 0, Ui.width(13), 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFE32B1B),
                                  Color(0xFFF69053),
                                ],
                              ),
                            ),
                            child: Text(
                              '${constructTime(seconds)['day']}',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                          ),
                          Text(
                            '天',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(24.0)),
                          ),
                          Container(
                            width: Ui.width(56),
                            height: Ui.width(56),
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(13), 0, Ui.width(13), 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFE32B1B),
                                  Color(0xFFF69053),
                                ],
                              ),
                            ),
                            child: Text(
                              '${constructTime(seconds)['hour']}',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                          ),
                          Text(
                            '时',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(24.0)),
                          ),
                          Container(
                            width: Ui.width(56),
                            height: Ui.width(56),
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(13), 0, Ui.width(13), 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFE32B1B),
                                  Color(0xFFF69053),
                                ],
                              ),
                            ),
                            child: Text(
                              '${constructTime(seconds)['minute']}',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                          ),
                          Text(
                            '分',
                            style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(24.0)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    // width: Ui.width(570),
                    height: Ui.width(66),
                    margin: EdgeInsets.fromLTRB(
                        Ui.width(30),
                        Ui.width(45),
                        list.length == 1
                            ? Ui.width(530)
                            : list.length == 2 ? Ui.width(340) : Ui.width(150),
                        0),
                    decoration: BoxDecoration(
                      color: Color(0xFF4D27C2),
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(Ui.width(14.0))),
                    ),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: list.asMap().keys.map((index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                active = index;
                              });
                              gettopic(list[index]['id']);
                            },
                            child: Container(
                              width: Ui.width(190),
                              height: Ui.width(66),
                              decoration: BoxDecoration(
                                color: active == index
                                    ? Color(0xFF8E69FF)
                                    : Color(0xFF4D27C2),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(Ui.width(14.0))),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  CachedNetworkImage(
                                      width: Ui.width(22),
                                      height: Ui.width(23),
                                      fit: BoxFit.fill,
                                      imageUrl: '${list[index]['picUrl']}'),
                                  // Image.network('${list[index]['picUrl']}',
                                  //     width: Ui.width(22),
                                  //     height: Ui.width(23)),
                                  // Image.asset('images/2.0x/baokuan.png',
                                  //     width: Ui.width(22), height: Ui.width(23)),
                                  SizedBox(
                                    width: Ui.width(6),
                                  ),
                                  Text(
                                    '${list[index]['title']}',
                                    style: TextStyle(
                                        color: Color(0xFFFFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(28.0)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList()),
                  ),
                  Container(
                    child: getitemlist(),
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
