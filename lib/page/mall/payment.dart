import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../common/LoadingDialog.dart';
import '../../http/index.dart';
import 'dart:async';
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';
import '../../provider/Integral.dart';

class Payment extends StatefulWidget {
  final Map arguments;
  Payment({Key key, this.arguments}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool isloading = true;
  Timer _timer;
  int seconds;
  String endtime = '2019-12-04 16:36:00';
  Timer timer;
//时间格式化，根据总秒数转换为对应的 hh:mm:ss 格式
  String constructTime(int seconds) {
    int hour = seconds ~/ 3600;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    return formatTime(hour) +
        ":" +
        formatTime(minute) +
        ":" +
        formatTime(second);
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  @override
  void initState() {
    super.initState();

// var now_timestamp = time.time();
// print(time.ctime(now_timestamp));
    //获取当期时间
    var now = DateTime.now();
    // print(now.millisecondsSinceEpoch);
    // print(DateTime.parse(endtime).millisecondsSinceEpoch);
    //获取 2 分钟的时间间隔
    // var twoHours = now.add(Duration(minutes: 10)).difference(now);
    //获取总秒数，2 分钟为 120 秒
    // seconds = twoHours.inSeconds;
    // widget.arguments['data']
    // print(DateTime.parse(widget.arguments['data']["addTime"]).millisecondsSinceEpoch+900000);
    var endtime = DateTime.parse(widget.arguments['data']["addTime"])
            .millisecondsSinceEpoch +
        900000;
    if (endtime - now.millisecondsSinceEpoch > 0) {
      seconds = (endtime - now.millisecondsSinceEpoch) ~/ 1000;
    } else {
      seconds = 0;
    }
    // print(seconds);
    startTimer();
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
    timer?.cancel();
    timer = null;
  }
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   // print(widget.arguments['data']);
  //   // getData();
  // }

  // getData() async {
  //   await HttpUtlis.get('wx/points/order/${widget.arguments['id']}',
  //       success: (value) {
  //     print(value);
  //     if (value['errno'] == 0) {
  //       setState(() {
  //         // obj = value['data'];
  //       });
  //     }
  //   }, failure: (error) {
  //     print(error);
  //   });
  //   setState(() {
  //     this.isloading = true;
  //   });
  // }

  sunmit() async {
    await HttpUtlis.post(
        'wx/points/lottery/pay/${widget.arguments['data']['id']}',
        success: (value) {
      // print(value);
      if (value['errno'] == 0) {
        // print(value['data']['points']);
        Toast.show('支付成功', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
        timer = new Timer(new Duration(seconds: 1), () {
          Navigator.pushNamed(context, '/paysuccess',
              arguments: {'data': value['data']});
        });

        // setState(() {
        //   // obj = value['data'];
        // });
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

  @override
  Widget build(BuildContext context) {
    final integrals = Provider.of<Integral>(context);

    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '付款记录',
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
          ? Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(200)),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        width: Ui.width(750),
                        height: Ui.width(110),
                        color: Color(0xFFFFF6F7),
                        // alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('images/2.0x/time.png',
                                width: Ui.width(42), height: Ui.width(44)),
                            SizedBox(
                              width: Ui.width(26),
                            ),
                            Text(
                              '支付剩余时间：${constructTime(seconds)}',
                              style: TextStyle(
                                  color: Color(0xFFD10123),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(28.0)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: Ui.width(750),
                        height: Ui.width(80),
                        padding: EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '订单号：${widget.arguments['data']['id']}',
                          style: TextStyle(
                              color: Color(0xFF9398A5),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(26.0)),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffEAEAEA)))),
                      ),
                      Container(
                        width: Ui.width(750),
                        height: Ui.width(240),
                        padding: EdgeInsets.fromLTRB(Ui.width(30), Ui.width(30),
                            Ui.width(30), Ui.width(30)),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                width: Ui.width(180),
                                height: Ui.width(180),
                                margin:
                                    EdgeInsets.fromLTRB(0, 0, Ui.width(30), 0),
                                // color: Colors.red,
                                child: CachedNetworkImage(
                                    width: Ui.width(180),
                                    height: Ui.width(180),
                                    fit: BoxFit.fill,
                                    imageUrl:
                                        '${widget.arguments['data']["picUrl"]}')

                                // AspectRatio(
                                //   aspectRatio: 1 / 1,
                                //   child: Image.network(
                                //     '${widget.arguments['data']["picUrl"]}',
                                //     // fit: BoxFit.cover,
                                //   ),
                                // ),
                                ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      '${widget.arguments['data']["prize"]}',
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(30.0)),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0, Ui.width(32), 0, 0),
                                      alignment: Alignment.centerLeft,
                                      child: RichText(
                                        text: TextSpan(
                                          text:
                                              '${widget.arguments['data']["points"]}',
                                          style: TextStyle(
                                              color: Color(0xFFD10123),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(34.0)),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' 积分',
                                              style: TextStyle(
                                                  color: Color(0xFFD10123),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      24.0)),
                                            ),
                                          ],
                                        ),
                                      ),

                                      //  Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //   children: <Widget>[
                                      //     Text(
                                      //       '${widget.arguments['data']["points"]}',
                                      //       style: TextStyle(
                                      //           color: Color(0xFFD10123),
                                      //           fontWeight: FontWeight.w400,
                                      //           fontFamily:
                                      //               'PingFangSC-Medium,PingFang SC',
                                      //           fontSize:
                                      //               Ui.setFontSizeSetSp(34.0)),
                                      //     ),
                                      //     SizedBox(
                                      //       width: Ui.width(2),
                                      //     ),
                                      //     Text(
                                      //       '积分',
                                      //       style: TextStyle(
                                      //           color: Color(0xFFD10123),
                                      //           fontWeight: FontWeight.w400,
                                      //           fontFamily:
                                      //               'PingFangSC-Medium,PingFang SC',
                                      //           fontSize:
                                      //               Ui.setFontSizeSetSp(24.0)),
                                      //     ),
                                      //   ],
                                      // ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: Ui.width(750),
                        height: Ui.width(16),
                        color: Color(0xFFF8F9FB),
                      ),
                      Container(
                        width: Ui.width(750),
                        height: Ui.width(90),
                        color: Color(0xFFFFFFFF),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), 0, Ui.width(40), 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '积分支付',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(30.0)),
                            ),
                            Image.asset('images/2.0x/select.png',
                                width: Ui.width(38), height: Ui.width(38))
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
                        integrals.increment(true);
                        sunmit();
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
                          '确认支付',
                          style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(32.0)),
                        ),
                      ),
                    )),
                Positioned(
                    bottom: Ui.width(90),
                    left: 0,
                    child: Container(
                        width: Ui.width(750),
                        height: Ui.width(110),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), 0, Ui.width(40), 0),
                        color: Color(0xFFFFFFFF),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text('需支付',
                                style: TextStyle(
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(28.0))),
                            Text('${widget.arguments['data']["points"]}积分',
                                style: TextStyle(
                                    color: Color(0xFFD92818),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(32.0))),
                          ],
                        )))
              ],
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
