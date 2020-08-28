import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/Nofind.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Ification extends StatefulWidget {
  final Map arguments;
  Ification({Key key, this.arguments}) : super(key: key);
  @override
  _IficationState createState() => _IficationState();
}

class _IficationState extends State<Ification> {
  ScrollController _scrollController = new ScrollController();
  List list = [];
  int page = 1;
  int limit = 10;
  bool nolist = true;
  bool isMore = true;

  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 100) {
        if (nolist) {
          getdata();
        }
        setState(() {
          isMore = false;
        });
      }
    });
    getdata();
  }

  getdata() async {
    var str = '';
    var obj = widget.arguments['query'];
    obj.forEach((key, value) {
      str = str + '${key}=${value}&';
    });
    if (isMore) {
      await HttpUtlis.get(
          'wx/goods/list?page=${this.page}&limit=${this.limit}&${str.substring(0, str.length - 1)}',
          success: (value) {
        if (value['errno'] == 0) {
          if (value['data']['list'].length < limit) {
            setState(() {
              nolist = false;
              this.isMore = true;
              list.addAll(value['data']['list']);
            });
          } else {
            setState(() {
              page++;
              nolist = true;
              this.isMore = true;
              list.addAll(value['data']['list']);
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
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.arguments['title']}',
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
                controller: _scrollController,
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
                                                  color: Color(0xFFED3221),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      26.0)),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${list[index]['retailPrice']}${list[index]['unit']}',
                                                  style: TextStyle(
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
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
                                                  color: Color(0xFF9398A5),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
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
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(250),
                                          height: Ui.width(188),
                                          child: CachedNetworkImage(
                                                    width: Ui.width(250),
                                                    height: Ui.width(188),
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                       '${list[index]['picUrl']}',),
                                          
                                          // AspectRatio(
                                          //   aspectRatio: 4 / 3,
                                          //   child: Image.network(
                                          //     '${list[index]['picUrl']}',
                                          //   ),
                                          // ),
                                        ),
                                      ],
                                    ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ))
          : Nofind(
              text: "暂无更多数据哦～",
            ),
    );
  }
}
