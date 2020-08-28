import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/Nofind.dart';
import 'package:toast/toast.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Vehicletype extends StatefulWidget {
  final Map arguments;
  Vehicletype({Key key, this.arguments}) : super(key: key);
  @override
  _VehicletypeState createState() => _VehicletypeState();
}

class _VehicletypeState extends State<Vehicletype> {
  List list = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    await HttpUtlis.get(
        'wx/goods/list?categoryId=${widget.arguments['item']['id']}&limit=1000',
        success: (value) {
      // print(value['data']);
      if (value['errno'] == 0) {
        setState(() {
          list = value['data']['list'];
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

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '款型选择',
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
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(0, Ui.width(90), 0, 0),
              child: list.length > 0
                  ? ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            TalkingDataAppAnalytics.onEvent(
                                eventID: 'cardetail',
                                eventLabel: '汽车详情',
                                params: {"goodsSn": list[index]['goodsSn']});
                            Navigator.pushNamed(context, '/cardetail',
                                arguments: {
                                  "id": list[index]['id'],
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, Ui.width(16), 0, 0),
                            color: Colors.white,
                            height: Ui.width(250),
                            padding: EdgeInsets.fromLTRB(Ui.width(40),
                                Ui.width(40), Ui.width(15), Ui.width(40)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: Ui.width(220),
                                  height: Ui.height(168),
                                  margin: EdgeInsets.fromLTRB(
                                      0, 0, Ui.width(30), 0),
                                  child: CachedNetworkImage(
                                    width: Ui.width(220),
                                    height: Ui.height(168),
                                    fit: BoxFit.cover,
                                    imageUrl: '${list[index]['picUrl']}',
                                  ),

                                  // AspectRatio(
                                  //   aspectRatio: 4 / 3,
                                  //   child: Image.network(
                                  //     '${list[index]['picUrl']}',
                                  //     fit: BoxFit.cover,
                                  //   ),
                                  // )
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            '${list[index]['name']}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Color(0xFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(34.0)),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            '官方指导价：${list[index]['counterPrice']}${list[index]['unit']}',
                                            style: TextStyle(
                                                color: Color(0xFF9398A5),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(26.0)),
                                          ),
                                        ),
                                        RichText(
                                          textAlign: TextAlign.end,
                                          text: TextSpan(
                                            text: '惊爆价：',
                                            style: TextStyle(
                                                color: Color(0xFF9398A5),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(28.0)),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text:
                                                      '${list[index]['retailPrice']}${list[index]['unit']}',
                                                  style: TextStyle(
                                                      color: Color(0xFFD10123),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              28.0))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Nofind(
                      text: "暂无更多车型哦～",
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: Ui.width(750),
                height: Ui.width(90),
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(30), 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${widget.arguments['item']['name']}',
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(30.0)),
                    ),
                    // RichText(
                    //   textAlign: TextAlign.end,
                    //   text: TextSpan(
                    //     text: '价格区间：',
                    //     style: TextStyle(
                    //         color: Color(0xFF9398A5),
                    //         fontWeight: FontWeight.w400,
                    //         fontFamily: 'PingFangSC-Medium,PingFang SC',
                    //         fontSize: Ui.setFontSizeSetSp(26.0)),
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //           text: '${widget.arguments['item']['priceRange']}',
                    //           style: TextStyle(
                    //               color: Color(0xFFD10123),
                    //               fontWeight: FontWeight.w400,
                    //               fontFamily: 'PingFangSC-Medium,PingFang SC',
                    //               fontSize: Ui.setFontSizeSetSp(26.0))),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
