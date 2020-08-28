import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tuangeche/common/Nofind.dart';
import 'package:flutter_tuangeche/http/index.dart';
import 'package:flutter_tuangeche/ui/ui.dart';
import 'package:toast/toast.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Volume extends StatefulWidget {
  Volume({Key key}) : super(key: key);

  @override
  _VolumeState createState() => _VolumeState();
}

class _VolumeState extends State<Volume> {
  List list = [];
  void initState() {
    super.initState();
    getdata();
  }

  getdata() async {
    await HttpUtlis.get('wx/goods/topSales', success: (value) {
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

  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '销量排行',
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
      body: list.length > 0
          ? Container(
              color: Color(0xFFF8F9FB),
              padding: EdgeInsets.fromLTRB(
                  Ui.width(30), 0, Ui.width(30), Ui.width(30)),
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      TalkingDataAppAnalytics.onEvent(
                          eventID: 'cardetail',
                          eventLabel: '汽车详情',
                          params: {"goodsSn": list[index]['goodsSn']});
                      Navigator.pushNamed(context, '/cardetail', arguments: {
                        "id": list[index]['id'],
                      });
                    },
                    child: Container(
                        width: Ui.width(690),
                        margin: EdgeInsets.fromLTRB(0, Ui.width(20), 0, 0),
                        height: Ui.width(230),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(Ui.width(15.0))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              // color: Colors.red,
                              width: Ui.width(245),
                              height: Ui.width(210),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(10), Ui.width(10), Ui.width(30), 0),
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: Ui.width(225),
                                      height: Ui.width(170),
                                      child: CachedNetworkImage(
                                        width: Ui.width(225),
                                        height: Ui.width(170),
                                        fit: BoxFit.fill,
                                        imageUrl: '${list[index]['picUrl']}',
                                      ),

                                      // Image.network(
                                      //   '${list[index]['picUrl']}',
                                      //   width: Ui.width(225),
                                      //   height: Ui.width(170),
                                      //   fit: BoxFit.fill,
                                      // )
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: Ui.width(69),
                                      height: Ui.width(75),
                                      alignment: Alignment.center,
                                      child: index == 0
                                          ? Image.asset(
                                              'images/2.0x/one.png',
                                              width: Ui.width(69),
                                              height: Ui.width(75),
                                            )
                                          : index == 1
                                              ? Image.asset(
                                                  'images/2.0x/two.png',
                                                  width: Ui.width(69),
                                                  height: Ui.width(75),
                                                )
                                              : index == 2
                                                  ? Image.asset(
                                                      'images/2.0x/three.png',
                                                      width: Ui.width(69),
                                                      height: Ui.width(75),
                                                    )
                                                  : Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFF6A7182),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  44.0)),
                                                    ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(
                                    0, Ui.width(25), Ui.width(30), 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        '${list[index]['name']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w500,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(30.0)),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0, Ui.width(18), 0, 0),
                                      child: RichText(
                                        textAlign: TextAlign.end,
                                        text: TextSpan(
                                          text: '惊爆价:',
                                          style: TextStyle(
                                              color: Color(0xFFED3221),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(26.0)),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  '${list[index]['retailPrice']}${list[index]['unit']}',
                                              style: TextStyle(
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      32.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(
                                          0, Ui.width(8), 0, 0),
                                      child: RichText(
                                        textAlign: TextAlign.end,
                                        text: TextSpan(
                                          text: '官方指导价:',
                                          style: TextStyle(
                                              color: Color(0xFF9398A5),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(24.0)),
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
                            )
                          ],
                        )),
                  );
                },
              ))
          : Nofind(
              text: "暂无更多数据哦～",
            ),
    );
  }
}
