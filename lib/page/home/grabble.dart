import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Grabble extends StatefulWidget {
  Grabble({Key key}) : super(key: key);

  @override
  _GrabbleState createState() => _GrabbleState();
}

class _GrabbleState extends State<Grabble> {
  var _initKeywordsController = new TextEditingController();
  List list = [];
  bool isShow = false;
  var style = 1;
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

  @override
  void initState() {
    super.initState();
    getstyle();
  }

  getdata(search) async {
    await HttpUtlis.get('wx/goods/list?limit=1000&type=2&keyword=${search}',
        success: (value) {
      if (value['errno'] == 0) {
        if (value['data']['total'] == 0) {
          setState(() {
            isShow = true;
          });
        } else {
          setState(() {
            isShow = false;
            list = [];
          });
        }
        if (search == '') {
          setState(() {
            isShow = false;
            list = [];
          });
        } else {
          setState(() {
            list = value['data']['list'];
          });
        }
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
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '搜索',
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
          body: Container(
            color: Color(0xFFF8F9FB),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(
                      Ui.width(30), Ui.width(130), Ui.width(30), Ui.width(20)),
                  child: isShow
                      ? Text(
                          '推荐车型:',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(32.0)),
                        )
                      : Text(''),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(
                        Ui.width(30),
                        isShow ? Ui.width(180) : Ui.width(110),
                        Ui.width(30),
                        Ui.width(30)),
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            TalkingDataAppAnalytics.onEvent(
                                eventID: 'cardetail',
                                eventLabel: '汽车详情',
                                params: {
                                  "goodsSn": list[index]['goodsSn']
                                });
                            Navigator.pushNamed(context, '/cardetail',
                                arguments: {
                                  "id": list[index]['id'],
                                });
                          },
                          child: Container(
                            width: Ui.width(690),
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), Ui.width(30), Ui.width(30), 0),
                            margin: EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                            constraints: BoxConstraints(
                              minHeight: Ui.width(270),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(Ui.width(15.0))),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '${list[index]['name']}',
                                    style: TextStyle(
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(32.0)),
                                  ),
                                ),
                                Container(
                                  height: Ui.width(188),
                                  // width: Ui.width(690),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, Ui.width(28), 0, 0),
                                                child: RichText(
                                                  textAlign: TextAlign.end,
                                                  text: TextSpan(
                                                    text: '惊爆价:',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFED3221),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text:
                                                            '${list[index]['retailPrice']}${list[index]['unit']}',
                                                        style: TextStyle(
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, Ui.width(10), 0, 0),
                                                child: RichText(
                                                  textAlign: TextAlign.end,
                                                  text: TextSpan(
                                                    text: '官方指导价:',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF9398A5),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                24.0)),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text:
                                                            '${list[index]['counterPrice']}${list[index]['unit']}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: Ui.width(250),
                                        height: Ui.width(188),
                                        child: CachedNetworkImage(
                                          width: Ui.width(250),
                                          height: Ui.width(188),
                                          fit: BoxFit.fill,
                                          imageUrl: '${list[index]['picUrl']}',

                                          // AspectRatio(
                                          //   aspectRatio: 4 / 3,
                                          //   child: Image.network(
                                          //     '${list[index]['picUrl']}',
                                          //   ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: Ui.width(750),
                    height: Ui.width(110),
                    padding: EdgeInsets.fromLTRB(
                        Ui.width(30), Ui.width(20), Ui.width(30), Ui.width(20)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(Ui.width(14.0))),
                    ),
                    child: Container(
                      width: Ui.width(690),
                      height: Ui.width(70),
                      color: Color(0xFFf5f6fa),
                      padding: EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('images/2.0x/searchnew.png',
                              width: Ui.width(28), height: Ui.width(28)),
                          SizedBox(
                            width: Ui.width(20),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              autofocus: false,
                              // textInputAction: TextInputAction.none,
                              keyboardAppearance: Brightness.light,
                              keyboardType: TextInputType.text,
                              controller: _initKeywordsController,
                              style: TextStyle(
                                  color: Color(0XFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontSize: Ui.setFontSizeSetSp(32)),
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0,
                                      style == 1 ? Ui.width(15) : Ui.width(28)),
                                  border: InputBorder.none,
                                  hintText: '请输入搜索内容',
                                  hintStyle: TextStyle(
                                      color: Color(0xFFC4C9D3),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Helvetica;',
                                      fontSize: Ui.setFontSizeSetSp(28.0))),
                              onChanged: (value) {
                                if (_initKeywordsController.text.length != 0) {
                                  getdata(value);
                                } else {
                                  setState(() {
                                    list = [];
                                    isShow = false;
                                  });
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
