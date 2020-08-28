import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/Nofind.dart';

class Dried extends StatefulWidget {
  Dried({Key key}) : super(key: key);

  @override
  _DriedState createState() => _DriedState();
}

class _DriedState extends State<Dried> {
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
          'wx/promote/articles?page=${this.page}&limit=${this.limit}',
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
            '汽车干货',
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
                padding: EdgeInsets.fromLTRB(
                    Ui.width(30), Ui.width(10), Ui.width(30), Ui.width(30)),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/driedwebview',
                            arguments: {'id': list[index]['id']});
                      },
                      child: Container(
                        height: Ui.width(246),
                        width: Ui.width(690),
                        padding: EdgeInsets.fromLTRB(
                            0, Ui.width(20), 0, Ui.width(20)),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1, color: Color(0xffEAEAEA)))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: Ui.width(270),
                              height: Ui.width(207),
                              margin:
                                  EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
                              // decoration: BoxDecoration(
                              //     borderRadius: new BorderRadius.all(
                              //         new Radius.circular(Ui.width(10.0))),
                              //     image: DecorationImage(
                              //       image:
                              //           NetworkImage('${list[index]['picUrl']}?x-oss-process=image/resize,p_70'),
                              //       fit: BoxFit.fill,
                              //     )),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(Ui.width(10.0))),
                                      child: CachedNetworkImage(
                                          width: Ui.width(270),
                                          height: Ui.width(207),
                                          fit: BoxFit.fill,
                                          imageUrl: '${list[index]['picUrl']}'),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: list[index]['isHot']
                                        ? Container(
                                            alignment: Alignment.center,
                                            width: Ui.width(70),
                                            height: Ui.width(34),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              image: AssetImage(
                                                  'images/2.0x/hot.png'),
                                              // fit: BoxFit.cover,
                                            )),
                                            child: Text(
                                              '最热',
                                              style: TextStyle(
                                                  color: Color(0XFFFFFFFF),
                                                  fontSize:
                                                      Ui.setFontSizeSetSp(22),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Regular,PingFang SC;'),
                                            ),
                                          )
                                        : Text(''),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      '${list[index]['title']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Color(0xFF111F37),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(30.0)),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      '${list[index]['content']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(24.0)),
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'images/2.0x/loginnew.png',
                                          width: Ui.width(26),
                                          height: Ui.width(26),
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              Ui.width(5), 0, 0, 0),
                                          child: Text(
                                            '来自团个车',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color(0xFF9398A5),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(24.0)),
                                          ),
                                        ),
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
                ),
              )
            : Nofind(
                text: "暂无更多数据哦～",
              ));
  }
}
