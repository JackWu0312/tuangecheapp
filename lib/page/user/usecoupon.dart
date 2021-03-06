import 'dart:convert';

import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import '../../common/Nofind.dart';
import 'package:provider/provider.dart';
import '../../provider/Rollbag.dart';

class Usecoupon extends StatefulWidget {
  final Map arguments;
  Usecoupon({Key key, this.arguments}) : super(key: key);
  @override
  _UsecouponState createState() => _UsecouponState();
}

class _UsecouponState extends State<Usecoupon> {
  ScrollController _scrollController = new ScrollController();

  var islogin = false;
  void initState() {
    super.initState();
    getData();
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
  }

  List list = [];
  bool nolist = true;
  bool isMore = true;
  int page = 1;
  int limit = 10;
  getData() async {
    if (isMore) {
      await HttpUtlis.get(
          'wx/coupon/availableCoupon/${widget.arguments['id']}?page=${page}&limit=${limit}',
          success: (value) {
        if (value['errno'] == 0) {
          // print(widget.arguments['rollid']);
          var listdata = value['data']['list'];
          for (var i = 0, len = listdata.length; i < len; i++) {
            listdata[i]['select'] = false;
            if(widget.arguments['rollid']!='noroll'){
              if(listdata[i]['couponUserId']==widget.arguments['rollid'] ){
                listdata[i]['isselect'] = true;
              }else{
                listdata[i]['isselect'] = false;
              }
            }else{
               listdata[i]['isselect'] = false;
            }
            
          }
          if (value['data']['list'].length < limit) {
            setState(() {
              nolist = false;
              this.isMore = true;
              list.addAll(listdata);
            });
          } else {
            setState(() {
              page++;
              nolist = true;
              this.isMore = true;
              list.addAll(listdata);
            });
          }
          setState(() {
            islogin = true;
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
    final counter = Provider.of<Rollbag>(context);
    if (json.encode(counter.count) != '{}') {
      // setState(() {
      //   adress = counter.count;
      // });
    } else {
      // if (adress != null) {
      //   getAdress();
      // }
    }
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '使用红包',
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
        body: islogin
            ? Container(
                color: Color(0xFFF8F9FB),
                child: list.length > 0
                    ? ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                               setState(() {
                                  list[index]['isselect'] =!list[index]['isselect'];
                                });
                                Toast.show('选择成功～', context,
                                    backgroundColor: Color(0xff5b5956),
                                    backgroundRadius: Ui.width(16),
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.CENTER);
                              Future.delayed(Duration(seconds: 2), () {
                                counter.increment(list[index]);
                                Navigator.pop(context);
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.fromLTRB(Ui.width(24),
                                    Ui.width(20), Ui.width(24), 0),
                                width: Ui.width(690),
                                constraints:
                                    BoxConstraints(minHeight: Ui.width(230)),
                                decoration: BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(Ui.width(10.0)))),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.fromLTRB(
                                          0, Ui.width(20), 0, Ui.width(20)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(460),
                                            height: Ui.width(190),
                                            padding: EdgeInsets.fromLTRB(
                                                Ui.width(26), 0, 0, 0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '${list[index]['coupon']['name']}',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF111F37),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(12),
                                                      ),
                                                      Text(
                                                        '${list[index]['coupon']['tag']}',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '${list[index]['startTime']}-${list[index]['endTime']}',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF9398A5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24.0)),
                                                      ),
                                                      SizedBox(
                                                        width: Ui.width(30),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            list[index]
                                                                    ['select'] =
                                                                !list[index]
                                                                    ['select'];
                                                          });
                                                        },
                                                        child: Container(
                                                          width: Ui.width(105),
                                                          height: Ui.width(40),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                width:
                                                                    Ui.width(1),
                                                                color: Color(
                                                                    0xff8D551B)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                '详情',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8D551B),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        'PingFangSC-Medium,PingFang SC',
                                                                    fontSize: Ui
                                                                        .setFontSizeSetSp(
                                                                            24.0)),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    Ui.width(4),
                                                              ),
                                                              Image.asset(
                                                                list[index][
                                                                        'select']
                                                                    ? 'images/2.0x/upper.png'
                                                                    : 'images/2.0x/lower.png',
                                                                width: Ui.width(
                                                                    15),
                                                                height:
                                                                    Ui.width(
                                                                        15),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: Ui.width(230),
                                            height: Ui.width(190),
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                              image: AssetImage(
                                                  'images/2.0x/coupon.png'),
                                              fit: BoxFit.fill,
                                            )),
                                            child: Stack(
                                              children: <Widget>[
                                                Positioned(
                                                  top: Ui.width(40),
                                                  child: Container(
                                                    width: Ui.width(230),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          '¥ ',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF8F541B),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      36.0)),
                                                        ),
                                                        Text(
                                                          '${list[index]['coupon']['discount']}',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF8F541B),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      52.0)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Positioned(
                                                //   top: Ui.width(89),
                                                //   child: Container(
                                                //     width: Ui.width(230),
                                                //     alignment: Alignment.center,
                                                //     child: Text(
                                                //       '满${list[index]['min']}元使用',
                                                //       maxLines: 1,
                                                //       overflow: TextOverflow.ellipsis,
                                                //       style: TextStyle(
                                                //           color: Color(0xFF8E541C),
                                                //           fontWeight: FontWeight.w400,
                                                //           fontFamily:
                                                //               'PingFangSC-Medium,PingFang SC',
                                                //           fontSize: Ui.setFontSizeSetSp(
                                                //               22.0)),
                                                //     ),
                                                //   ),
                                                // ),
                                                // Positioned(
                                                //     top: Ui.width(135),
                                                //     left: Ui.width(45),
                                                //     child: InkWell(
                                                //       onTap: () {
                                                //           Navigator.popAndPushNamed(context, '/');
                                                //         // getreceive(list[index]['id']);
                                                //       },
                                                //       child: Container(
                                                //         width: Ui.width(140),
                                                //         height: Ui.width(45),
                                                //         color: Color(0xFF8D551B),
                                                //         alignment: Alignment.center,
                                                //         child: Text(
                                                //           '立即使用',
                                                //           maxLines: 1,
                                                //           overflow:
                                                //               TextOverflow.ellipsis,
                                                //           style: TextStyle(
                                                //               color: Color(0xFFF4CF71),
                                                //               fontWeight:
                                                //                   FontWeight.w400,
                                                //               fontFamily:
                                                //                   'PingFangSC-Medium,PingFang SC',
                                                //               fontSize:
                                                //                   Ui.setFontSizeSetSp(
                                                //                       22.0)),
                                                //         ),
                                                //       ),
                                                //     ))
                                                Positioned(
                                                  bottom: Ui.width(0),
                                                  right: Ui.width(0),
                                                  child: Container(
                                                    width: Ui.width(45),
                                                    height: Ui.width(45),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                      image: AssetImage(list[
                                                              index]['isselect']
                                                          ? 'images/2.0x/unselecttask.png'
                                                          : 'images/2.0x/selecttask.png'),
                                                      fit: BoxFit.fill,
                                                    )),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: list[index]['select']
                                          ? Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  Ui.width(24),
                                                  0,
                                                  Ui.width(24),
                                                  Ui.width(20)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    '${list[index]['coupon']['desc']}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF111F37),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                24.0)),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    )
                                  ],
                                )),
                          );
                        },
                      )
                    : Nofind(
                        text: "暂无优惠券哦～",
                      ))
            : Container(
                child: LoadingDialog(
                  text: "加载中...",
                ),
              ));
  }
}
