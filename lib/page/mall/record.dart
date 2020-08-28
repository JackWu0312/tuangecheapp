import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../common/LoadingDialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../../http/index.dart';
import '../../common/Nofind.dart';
import 'package:toast/toast.dart';

class Record extends StatefulWidget {
  Record({Key key}) : super(key: key);

  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  ScrollController _scrollController = new ScrollController();
  EasyRefreshController _controller;
  bool isloading = false;
  List list = [];
  int page = 1;
  int size = 10;
  bool isNolist = false;
  // List lists = [];
  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    getData();
  }

  getData() async {
    if (this.page == 1) {
      setState(() {
        this.list = []; //拼接
      });
    }
    await HttpUtlis.get(
        'wx/points/lottery/logs?type=2&page=${this.page}&limit=${this.size}',
        success: (value) {
      if (value['errno'] == 0) {
        List newlist = value['data']['list'];
        if (this.size > newlist.length) {
          setState(() {
            isNolist = true;
            list.addAll(newlist); //拼接
          });
        } else {
          setState(() {
            this.page++;
            this.isNolist = false;
            list.addAll(newlist); //拼接
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
    setState(() {
      this.isloading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '抽奖记录',
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
            onTap: (){
               Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.asset('images/2.0x/back.png',width: Ui.width(21),height: Ui.width(37),),
            ),
          ),
        ),
        body: isloading
            ? list.length > 0
                ? EasyRefresh(
                    controller: _controller,
                    header: ClassicalHeader(
                      refreshText: '下拉刷新哦～',
                      refreshReadyText: '下拉刷新哦～',
                      refreshingText: '加载中～',
                      refreshedText: '加载完成',
                      infoText: "更新时间 %T",
                      infoColor: Color(0XFF111F37),
                      textColor: Color(0XFF111F37),
                    ),
                    footer: ClassicalFooter(
                      loadText: '',
                      loadReadyText: '',
                      loadingText: '加载中～',
                      loadedText: '加载中完成～',
                      loadFailedText: '',
                      noMoreText: '我是有底线的哦～',
                      infoText: "更新时间 %T",
                      bgColor: Color(0xFFFFFFFF),
                      infoColor: Color(0XFF111F37),
                      textColor: Color(0XFF111F37),
                    ),
                    onRefresh: () async {
                      await Future.delayed(Duration(seconds: 2), () {
                        setState(() {
                          page = 1;
                        });
                        getData();
                        _controller.resetLoadState();
                      });
                    },
                    onLoad: () async {
                      await Future.delayed(Duration(seconds: 2), () {
                        if (!isNolist) {
                          getData();
                        }
                        _controller.finishLoad(noMore: this.isNolist);
                      });
                    },
                    child: ListView.builder(
                      itemCount: list.length,
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          constraints: BoxConstraints(
                            // minWidth: 180,
                            minHeight: Ui.width(160),
                          ),
                          width: Ui.width(750),
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(40), 0, Ui.width(33), Ui.width(25)),
                          // height: Ui.width(210),
                          decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0, Ui.width(20), 0, Ui.width(15)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '${list[index]['title']}',
                                      style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(24.0)),
                                    ),
                                    Text(
                                      '订单号：${list[index]['id']}',
                                      style: TextStyle(
                                          color: Color(0xFF9398A5),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(24.0)),
                                    )
                                  ],
                                ),
                              ),
                              // SizedBox(height: ,)
                              Container(
                                alignment: Alignment.centerLeft,
                                margin:
                                    EdgeInsets.fromLTRB(0, 0, 0, Ui.width(15)),
                                child: Text(
                                  '${list[index]["prize"]}',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              ),
                              Container(
                                padding:
                                    EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '${list[index]["points"]}积分',
                                      style: TextStyle(
                                          color: Color(0xFFD10123),
                                          fontWeight: FontWeight.w400,
                                          fontFamily:
                                              'PingFangSC-Medium,PingFang SC',
                                          fontSize: Ui.setFontSizeSetSp(26.0)),
                                    ),
                                    Container(
                                      width: Ui.width(125),
                                      height: Ui.width(40),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: list[index]["status"]["value"] ==
                                                    0 ||
                                                list[index]["status"]
                                                        ["value"] ==
                                                    1
                                            ? Color(0xffFFFFFF)
                                            : Color(0xffE8EAEF),
                                        border: Border.all(
                                            width: Ui.width(1),
                                            color: list[index]["status"]
                                                            ["value"] ==
                                                        0 ||
                                                    list[index]["status"]
                                                            ["value"] ==
                                                        1
                                                ? Color(0xffD10123)
                                                : Color(0xffE8EAEF)),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: list[index]["status"]["value"] ==
                                                  0 ||
                                              list[index]["status"]["value"] ==
                                                  1
                                          ? Text(
                                              '${list[index]["status"]["label"]}',
                                              style: TextStyle(
                                                  color: Color(0xFFD10123),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      26.0)),
                                            )
                                          : Text(
                                              '${list[index]["status"]["label"]}',
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      26.0)),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ))
                : Nofind(
                    text: "暂无抽奖记录哦～",
                  )
            : Container(
                // margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: LoadingDialog(
                  text: "加载中…",
                ),
              ));
  }
}
