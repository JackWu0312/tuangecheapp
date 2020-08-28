import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import '../../common/Nofind.dart';
import 'dart:io';

class Mallseach extends StatefulWidget {
  final Map arguments;
  Mallseach({Key key, this.arguments}) : super(key: key);
  @override
  _MallseachState createState() => _MallseachState();
}

class _MallseachState extends State<Mallseach> {
  ScrollController _scrollController = new ScrollController();
  var _initKeywordsController = new TextEditingController();
  var listAll = [];
  bool nolist = true;
  bool isMore = true;
  bool isloading = false;

  int page = 1;
  int limit = 10;
  var style =1;
  var search;
  @override
  void initState() {
    super.initState();
    getstyle();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 60) {
        if (nolist) {
          getDatalist();
        }
        setState(() {
          isMore = false;
        });
      }
    });
  }
getstyle(){
    if(Platform.isIOS){
      setState(() {
        style=1;
      });
    }else if(Platform.isAndroid){
     setState(() {
        style=2;
      });
    }
  }
  getDatalist() {
    if (isMore) {
      print(widget.arguments['type']);
      HttpUtlis.get(
          'wx/goods/list?type=${widget.arguments['type']}&page=${page}&limit=${limit}&keyword=${search}',
          success: (value) {
        if (value['errno'] == 0) {
          if (value['data']['list'].length < limit) {
            setState(() {
              nolist = false;
              this.isMore = true;
              listAll.addAll(value['data']['list']);
            });
          } else {
            setState(() {
              page++;
              nolist = true;
              this.isMore = true;
              listAll.addAll(value['data']['list']);
            });
          }
          setState(() {
            isloading = true;
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
              width: Ui.width(750),
              height: double.infinity,
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  Container(
                      width: Ui.width(750),
              height: double.infinity,
                    // color: Colors.red,
                    margin: EdgeInsets.fromLTRB(0, Ui.width(110), 0, 0),
                    padding: EdgeInsets.fromLTRB(Ui.width(24), 0, Ui.width(24), 0),
                    child: listAll.length > 0
                        ? ListView(
                            children: <Widget>[
                              Container(
                                  child: Wrap(
                                      runSpacing: Ui.width(10),
                                      spacing: Ui.width(10),
                                      children: listAll.map((val) {
                                        return InkWell(
                                          onTap: () {
                                            if (widget.arguments['type'] ==
                                                '1') {
                                              Navigator.pushNamed(
                                                  context, '/goods',
                                                  arguments: {
                                                    "id": val['id'],
                                                  });
                                            } else {
                                              Navigator.pushNamed(
                                                  context, '/goodsdetail',
                                                  arguments: {
                                                    "id": val['id'],
                                                  });
                                            }
                                          },
                                          child: Container(
                                            width: Ui.width(346),
                                            height: Ui.width(480),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  width: Ui.width(346),
                                                  height: Ui.width(346),
                                                  // color: Colors.red,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        'images/2.0x/pointbg.png',
                                                      ),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  child: CachedNetworkImage(
                                                     width: Ui.width(346),
                                                  height: Ui.width(346),
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        '${val['picUrl']}')
                                                  
                                                  // AspectRatio(
                                                  //     aspectRatio: 1 / 1,
                                                  //     child: Image.network(
                                                  //         '${val['picUrl']}')),
                                                ),
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: Ui.width(20),
                                                      ),
                                                      Text(
                                                        '${val['name']}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF111F37),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    28.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(10),
                                                      ),
                                                      Text(
                                                        widget.arguments[
                                                                    'type'] ==
                                                                '1'
                                                            ? '${val['retailPrice']}${val['unit']}'
                                                            : '${val['points']}积分+${val['retailPrice']}${val['unit']}',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFFD10123),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    28.0)),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList())),
                            ],
                          )
                        : isloading
                            ? Nofind(
                                text: "暂无更多商品哦～",
                              )
                            : Text(''),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: Ui.width(750),
                      height: Ui.width(110),
                      padding: EdgeInsets.fromLTRB(Ui.width(30), Ui.width(20),
                          Ui.width(30), Ui.width(20)),
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
                                    contentPadding: EdgeInsets.fromLTRB(
                                        0, 0, 0, style==1?Ui.width(15):Ui.width(28)),
                                    border: InputBorder.none,
                                    hintText: '请输入搜索内容',
                                    hintStyle: TextStyle(
                                        color: Color(0xFFC4C9D3),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Helvetica;',
                                        fontSize: Ui.setFontSizeSetSp(28.0))),
                                onChanged: (value) {
                                  if (_initKeywordsController.text.length ==
                                      0) {
                                    setState(() {
                                      search = value;
                                      listAll = [];
                                      nolist = true;
                                      isMore = true;
                                      isloading = false;
                                    });
                                  } else {
                                    setState(() {
                                      search = value;
                                      listAll = [];
                                      nolist = true;
                                      isMore = true;
                                    });
                                    getDatalist();
                                  }

                                 
                                  // if (_initKeywordsController.text.length != 0) {
                                  //   getdata(value);
                                  // } else {
                                  //   setState(() {
                                  //     list = [];
                                  //     isShow = false;
                                  //   });
                                  // }
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
            )
            // : Container(
            //     child: LoadingDialog(
            //       text: "加载中...",
            //     ),
            //   ),
            ));
  }
}
