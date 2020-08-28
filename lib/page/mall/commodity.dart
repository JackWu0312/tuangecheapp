import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import 'dart:io';

class Commodity extends StatefulWidget {
  final Map arguments;
  Commodity({Key key, this.arguments}) : super(key: key);

  @override
  _CommodityState createState() => _CommodityState();
}

class _CommodityState extends State<Commodity> {
  var _initKeywordsController = new TextEditingController();
  bool isloading = false;
  var obj = {};
  String nums = '1';
  int style = 1; //1 ios 2安卓
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._initKeywordsController.text = nums;
    // print(widget.arguments['id']);
    getBanner();
    getstyle();
  }

  getstyle() {
    if (Platform.isIOS) {
      setState(() {
        style = 1;
      });
    } else if (Platform.isAndroid) {
      setState(() {
        style = 2;
      });
    }
  }

  getBanner() async {
    await HttpUtlis.get('wx/points/lottery/prize/${widget.arguments['id']}',
        success: (value) {
      if (value['errno'] == 0) {
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
    setState(() {
      this.isloading = true;
    });
  }

  submit(showtosh) async {
    HttpUtlis.post("wx/points/lottery/submit", params: {
      'dataId': widget.arguments['id'],
      'number': nums,
    }, success: (value) async {
      // print(value);
      if (value['errno'] == 0) {
        Navigator.pushNamed(context, '/payment',
            arguments: {'data': value['data']});
      } else if (value['errno'] == 401) {
        // print('请登录');
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
    // print(MediaQuery.of(context).viewInsets.bottom);
    //底部弹出框
    _attrBottomSheet(showtosh) {
      showModalBottomSheet(
          context: context,
          builder: (contex) {
            return StatefulBuilder(
              builder: (BuildContext context, setBottomState) {
                return GestureDetector(
                  //解决showModalBottomSheet点击消失的问题
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    return false;
                  },
                  child: Container(
                    height: Ui.width(330) +
                        MediaQuery.of(context).viewInsets.bottom,
                    color: Color(0xFFFFFFFF),
                    width: Ui.width(750),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: Ui.width(750),
                          margin: EdgeInsets.fromLTRB(0, Ui.width(40), 0, 0),
                          height: Ui.width(40),
                          alignment: Alignment.center,
                          child: Text(
                            '购买数量',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(28.0)),
                          ),
                        ),
                        Container(
                          width: Ui.width(750),
                          height: Ui.width(85),
                          margin: EdgeInsets.fromLTRB(0, Ui.width(110), 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  if (int.parse(nums) > 1) {
                                    setBottomState(() {
                                      nums = (int.parse(nums) - 1).toString();
                                    });
                                  } else {
                                    setBottomState(() {
                                      nums = '1';
                                    });
                                  }
                                  setBottomState(() {
                                    _initKeywordsController.text = nums;
                                  });
                                },
                                child: Container(
                                  width: Ui.width(35),
                                  height: Ui.width(35),
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: Ui.width(35),
                                    height: Ui.width(3),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                                'images/2.0x/reduce.png'))),
                                  ),
                                ),
                              ),
                              Container(
                                  width: Ui.width(125),
                                  height: Ui.width(70),
                                  color: Color(0xFFFFF5F5),
                                  // alignment: Alignment.center,
                                  margin: EdgeInsets.fromLTRB(
                                      Ui.width(47), 0, Ui.width(47), 0),
                                  child: TextField(
                                    controller: TextEditingController.fromValue(
                                      TextEditingValue(
                                          // 设置内容
                                          text: _initKeywordsController.text,
                                          // 保持光标在最后
                                          selection: TextSelection.fromPosition(
                                              TextPosition(
                                                  affinity:
                                                      TextAffinity.downstream,
                                                  offset:
                                                      _initKeywordsController
                                                          .text.length))),
                                    ),
                                    // cotroller: this._initKeywordsController,
                                    autofocus: false,
                                    textAlign: TextAlign.center,
                                    keyboardAppearance: Brightness.light,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        textBaseline: TextBaseline.alphabetic,
                                        color: Color(0XFFD10123),
                                        fontWeight: FontWeight.w400,
                                        fontSize: Ui.setFontSizeSetSp(32)),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.fromLTRB(
                                          Ui.width(6),
                                          0,
                                          0,
                                          style == 1
                                              ? Ui.width(20)
                                              : Ui.width(28)),
                                    ),
                                    onChanged: (value) {
                                      // print("onChanged的监听方法：$value");
                                      // print(1<int.parse('$value'));
                                      if (1 <= int.parse(value)) {
                                        setBottomState(() {
                                          nums = value;
                                        });
                                      } else if (value == '') {
                                        setBottomState(() {
                                          nums = '';
                                        });
                                      } else {
                                        setBottomState(() {
                                          nums = '1';
                                        });
                                      }
                                      setBottomState(() {
                                        _initKeywordsController.text = nums;
                                      });
                                    },
                                  )),
                              InkWell(
                                onTap: () {
                                  // print(nums);
                                  //  nums=nums+1;
                                  setBottomState(() {
                                    nums = (int.parse(nums) + 1).toString();
                                    // nums++;
                                  });
                                  setBottomState(() {
                                    _initKeywordsController.text = nums;
                                  });
                                  // print(nums);
                                },
                                child: Container(
                                  width: Ui.width(35),
                                  height: Ui.width(35),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              'images/2.0x/add.png'))),
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                            right: Ui.width(20),
                            top: Ui.width(20),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: Ui.width(30),
                                height: Ui.width(30),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'images/2.0x/clonse.png'))),
                              ),
                            )),
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
                                  '去抽奖',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              },
            );
          });
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
                                        Navigator.popAndPushNamed(
                                            context, '/login');
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

    Ui.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '商品详情',
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
                  // height: double.infinity,
                  // color: Colors.red,
                  color: Color(0xFFFFFFFF),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        width: Ui.width(750),
                        alignment: Alignment.center,
                        child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) {
                                return CachedNetworkImage(
                                  width: Ui.width(750),
                                  fit: BoxFit.fill,
                                  imageUrl: '${obj["gallery"][index]}',
                                );
                                // new Image.network(
                                //   '${obj["gallery"][index]}',
                                //   fit: BoxFit.fill,
                                // );
                              },
                              itemCount: obj["gallery"].length,
                              autoplay:
                                  obj["gallery"].length > 1 ? true : false,
                            )),
                      ),
                      Container(
                        width: Ui.width(750),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(Ui.width(40), Ui.width(30),
                            Ui.width(40), Ui.width(30)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${obj["goodsName"]}',
                              style: TextStyle(
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(36.0)),
                            ),
                            SizedBox(height: Ui.width(30)),
                            RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                text: '${obj["points"]}',
                                style: TextStyle(
                                    color: Color(0xFFD10123),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(42.0)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' 积分',
                                    style: TextStyle(
                                        color: Color(0xFFD10123),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(24.0)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: Ui.width(25)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '市场参考价：${obj["price"]}元',
                                  style: TextStyle(
                                      color: Color(0xFF9398A5),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(24.0)),
                                ),
                                Text(
                                  '兑换编码：${obj["goodsSn"]}',
                                  style: TextStyle(
                                      color: Color(0xFF9398A5),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(24.0)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: Ui.width(750),
                        alignment: Alignment.centerLeft,
                        height: Ui.width(60),
                        color: Color(0xFFF8F9FB),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), 0, Ui.width(40), 0),
                        child: Text(
                          '商品描述',
                          style: TextStyle(
                              color: Color(0xFF9398A5),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ),
                      Container(
                        width: Ui.width(750),
                        alignment: Alignment.centerLeft,
                        height: Ui.width(176),
                        color: Color(0xFFFFFFFF),
                        padding: EdgeInsets.fromLTRB(
                            Ui.width(40), 0, Ui.width(40), Ui.width(90)),
                        child: Text(
                          '奖品数量：1',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(28.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    child: InkWell(
                      onTap: () {
                        _attrBottomSheet(showtosh);
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
                          '去抽奖',
                          style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(32.0)),
                        ),
                      ),
                    ))
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
