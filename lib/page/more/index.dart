import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../common/LoadingDialog.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';

class MorePage extends StatefulWidget {
  MorePage({Key key}) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  ScrollController _scrollController = new ScrollController();
  EasyRefreshController _controller;
  bool isloading = false;
  int page = 1;
  int size = 8;
  List _list = [];
  // bool isMore = true;
  bool isNolist = false;
  @override
  void initState() {
    super.initState();
    _getData();

    // _scrollController.addListener(() {
    //   print(_scrollController.position.pixels); //获取滚动条下拉的距离
    //   print(_scrollController.position.maxScrollExtent); //获取整个页面的高度
    //   if (_scrollController.position.pixels >
    //       _scrollController.position.maxScrollExtent - 40) {
    //     if (!isNolist) {
    //       _getData();
    //     }
    //     setState(() {
    //       isMore = false;
    //     });
    //   }
    // });
    _controller = EasyRefreshController();
  }

  _getData() async {
    if (this.page == 1) {
      setState(() {
        this._list = []; //拼接
      });
    }
    await HttpUtlis.get('wx/home/notice?page=${this.page}&limit=${this.size}',
        success: (value) {
      var newlist = value['data'].map((value) {
        value["avatar"] = value["avatar"] != null
            ? value["avatar"]
            : 'https://litecarmall.oss-cn-beijing.aliyuncs.com/a9aweabmhhggjkjiwqq7.jpg';
        return value;
      }).toList();
      if (this.size > newlist.length) {
        setState(() {
          isNolist = true;
          this._list.addAll(newlist); //拼接
        });
      } else {
        setState(() {
          this.page++;
          this.isNolist = false;
          this._list.addAll(newlist); //拼接
        });
      }
      // setState(() {
      //   this.isloading = true;
      //   // this.isMore = true;
      // });
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    setState(() {
      this.isloading = true;
      // this.isMore = true;
    });
    // if (isMore) {
    // try {
    //   var url =
    //       "https://test.api.tuangeche.com.cn/wx/home/notice?page=${this.page}&limit=${this.size}";
    //   var response = await Dio().get(url);
    //   var newlist = response.data['data'].map((value) {
    //     value["avatar"] = value["avatar"] != null
    //         ? value["avatar"]
    //         : 'https://litecarmall.oss-cn-beijing.aliyuncs.com/a9aweabmhhggjkjiwqq7.jpg';
    //     return value;
    //   }).toList();

    //   if (this.size > newlist.length) {
    //     setState(() {
    //       isNolist = true;
    //       this._list.addAll(newlist); //拼接
    //     });
    //   } else {
    //     setState(() {
    //       this.page++;
    //       this.isNolist = false;
    //       this._list.addAll(newlist); //拼接
    //     });
    //   }
    //   setState(() {
    //     this.isloading = true;
    //     // this.isMore = true;
    //   });
    // } catch (e) {
    //   print(e);
    // }
    // }
  }

  // Widget _getMoreWidget() {
  //   return Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(10.0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           CircularProgressIndicator(
  //             strokeWidth: 1.0,
  //             backgroundColor: Color(0xFF9398A5),
  //             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFb5b0ab)),
  //           ),
  //           SizedBox(
  //             width: 20.0,
  //           ),
  //           Text(
  //             '加载中...',
  //             style: TextStyle(fontSize: 16.0),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget getList(index) {
    return Container(
      height: Ui.height(170),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Color(0xffEAEAEA))),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: Ui.height(110),
            height: Ui.height(110),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: NetworkImage('${this._list[index]["avatar"]}?x-oss-process=image/resize,p_70'),
                  fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.fromLTRB(Ui.width(20), 0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          this._list[index]['name'],
                          style: TextStyle(
                              color: Color(0XFF111F37),
                              fontSize: Ui.setFontSizeSetSp(32),
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          this._list[index]['date'],
                          style: TextStyle(
                              color: Color(0XFFC4C9D3),
                              fontSize: Ui.setFontSizeSetSp(26),
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(top: Ui.width(20)),
                    child: Text(
                      '恭喜${this._list[index]["name"]}喜提${this._list[index]["goods"][0]}一台',
                      textDirection: TextDirection.ltr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0XFF9398A5),
                          fontSize: Ui.setFontSizeSetSp(28),
                          fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void dispose() {
    super.dispose();
    // _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '提车榜单',
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
      body: EasyRefresh(
        // enableControlFinishRefresh: true,
        // enableControlFinishLoad: true,
        controller: _controller,
        header: ClassicalHeader(
          // enableInfiniteRefresh: false,
          refreshText: '下拉刷新哦～',
          refreshReadyText: '下拉刷新哦～',
          refreshingText: '加载中～',
          refreshedText: '加载完成',
          infoText: "更新时间 %T",
          infoColor: Color(0XFF111F37),
          textColor: Color(0XFF111F37),
        ),
        footer: ClassicalFooter(
          // enableInfiniteLoad: false,
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
          // enableHapticFeedback: true,
        ),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2), () {
            setState(() {
              page = 1;
            });
            _getData();
            _controller.resetLoadState();
          });
        },
        onLoad: () async {
          await Future.delayed(Duration(seconds: 2), () {
            if (!isNolist) {
              this._getData();
            }

            _controller.finishLoad(noMore: this.isNolist);
          });
        },
        child: isloading
            ? Container(
                padding: EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
                color: Color(0XFFFFFFFF),
                child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: this._list.length,
                    itemBuilder: (context, index) {
                      return getList(index);
                      // }
                    }),
              )
            : Container(
                margin: EdgeInsets.fromLTRB(0, 300, 0, 0),
                child: LoadingDialog(
                  text: "加载中…",
                ),
              ),
      ),
    );
  }
}
