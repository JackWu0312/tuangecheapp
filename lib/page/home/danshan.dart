import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/Nofind.dart';

class Danshan extends StatefulWidget {
  Danshan({Key key}) : super(key: key);

  @override
  _DanshanState createState() => _DanshanState();
}

class _DanshanState extends State<Danshan> {
  ScrollController _scrollController = new ScrollController();
  List list = [];
  bool nolist = true;
  bool isMore = true;
  int page = 1;
  int limit = 10;
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 60) {
        if (nolist) {
          getData();
        }
        setState(() {
          isMore = false;
        });
      }
    });
    getData();
  }

  getData() async {
    if (isMore) {
      await HttpUtlis.get(
          'wx/promote/shows?page=${this.page}&limit=${this.limit}',
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
          '车主晒单',
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
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/danshandtail',
                          arguments: {'id': list[index]['id']});
                    },
                    child: Container(
                      width: Ui.width(690),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: Ui.width(690),
                            height: Ui.width(517),
                            margin: EdgeInsets.fromLTRB(0, Ui.width(30), 0, 0),
                            // decoration: BoxDecoration(
                            //   image: DecorationImage(
                            //     image: NetworkImage(
                            //         '${list[index]['picUrl']}?x-oss-process=image/resize,p_70'),
                            //     fit: BoxFit.fill,
                            //   ),
                            //   borderRadius: BorderRadius.vertical(
                            //       top: Radius.circular(Ui.width(10))),
                            // ),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(Ui.width(10))),
                                    child: CachedNetworkImage(
                                        width: Ui.width(690),
                                        height: Ui.width(517),
                                        fit: BoxFit.fill,
                                        imageUrl: '${list[index]['picUrl']}'),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: Container(
                                    width: Ui.width(690),
                                    padding: EdgeInsets.fromLTRB(Ui.width(20),
                                        0, Ui.width(20), Ui.width(27)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          width: Ui.width(690),
                                          child: Text(
                                            '${list[index]['title']}',
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(32.0)),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              0, Ui.width(10), 0, 0),
                                          child: Text(
                                            '${list[index]['subtitle']}',
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(24.0)),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: Ui.width(690),
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), Ui.width(30), Ui.width(30), 0),
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            constraints: BoxConstraints(
                              minHeight: Ui.width(270),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0XFFDFE3EC),
                                  offset: Offset(1, 1),
                                  blurRadius: Ui.width(20.0),
                                ),
                              ],
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(Ui.width(10))),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                          left: 0,
                                          top: Ui.width(3),
                                          child: Container(
                                            width: Ui.width(116),
                                            height: Ui.width(36),
                                            padding: EdgeInsets.fromLTRB(
                                                Ui.width(5), 0, 0, 0),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              image: AssetImage(
                                                  'images/2.0x/paragraph.png'),
                                              // fit: BoxFit.cover,
                                            )),
                                            child: Text(
                                              '车主同款',
                                              style: TextStyle(
                                                  color: Color(0xFF7F3A1C),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      24.0)),
                                            ),
                                          )),
                                      Container(
                                        child: Text(
                                          '              ${list[index]['goods']['name']}',
                                          style: TextStyle(
                                              color: Color(0xFF111F37),
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(32.0)),
                                        ),
                                      ),
                                    ],
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
                                                            '${list[index]['goods']['retailPrice']}${list[index]['goods']['unit']}',
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
                                                            '${list[index]['goods']['counterPrice']}${list[index]['goods']['unit']}',
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
                                                        '${list[index]['goods']['picUrl']}',),
                                                
                                                // AspectRatio(
                                                //   aspectRatio: 4 / 3,
                                                //   child: Image.network(
                                                //     '${list[index]['goods']['picUrl']}',
                                                //   ),
                                                // ),
                                              ),
                                              // Positioned(
                                              //   right: 0,
                                              //   top: 0,
                                              //   child: Image.asset(
                                              //     'images/2.0x/sepbg.png',
                                              //     width: Ui.width(65),
                                              //     height: Ui.width(56),
                                              //   ),
                                              // ),
                                            ],
                                          ))
                                    ],
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
              ))
          : Nofind(
              text: "暂无更多数据哦～",
            ),
    );
  }
}
