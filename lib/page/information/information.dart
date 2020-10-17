import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tuangeche/http/HttpHelper.dart';
import 'package:flutter_tuangeche/ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../mall/test.dart';
import 'package:rxdart/subjects.dart';
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import '../../common/Nofind.dart';
import '../../common/Storage.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../provider/Backshare.dart';
import 'package:fluwx/fluwx.dart';
import 'package:fluwx/fluwx.dart' as fluwx;
import '../../config/config.dart';
import '../../common/CommonBottomSheet.dart';
import '../../provider/JumpToPage.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../video/full_video_page.dart';
import 'package:flutter/cupertino.dart';

class Information extends StatefulWidget {
  Information({Key key}) : super(key: key);

  @override
  _InformationState createState() => _InformationState();
}

double ourMap(v, start1, stop1, start2, stop2) {
  return (v - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}

class _InformationState extends State<Information>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int initPage = 0;
  PageController _pageController;
  List<String> tabs = ['车主晒单', '汽车视频', '汽车资讯'];
  var _initKeywordsController = new TextEditingController();

  Stream<int> get currentPage$ => _currentPageSubject.stream;
  Sink<int> get currentPageSink => _currentPageSubject.sink;
  BehaviorSubject<int> _currentPageSubject;

  Alignment _dragAlignment;
  AnimationController _controller;
  Animation<Alignment> _animation;

  ScrollController _scrollControllerdanshan = new ScrollController();
  ScrollController _scrollControllervideo = new ScrollController();
  ScrollController _scrollControllerdried = new ScrollController();
  //  ScrollController _scrollController =
  List arr = [];
  List arr1 = [];
  int index = 0;

  List banners = [];
  bool isloading = false;

  bool nolistdanshan = true;
  bool isMoredanshan = true;
  int pagedanshan = 1;
  int limitdanshan = 10;
  List listdanshan = [];

  List listvideo = [];
  bool nolistvideo = true;
  bool isMorevideo = true;
  int pagevideo = 1;
  int limitvideo = 10;

  List listdried = [];
  bool nolistdried = true;
  bool isMoredried = true;
  int pagedried = 1;
  int limitdried = 10;

  bool isScoll = false;
  double isScolln = 0.0;
  // bool falge = true;
  String driedkeyword = '';
  String danshankeyword = '';
  String videokeyword = '';
  var city = '太原市';
  var style = 1;
  var dataId = '';
  StreamSubscription<WeChatShareResponse> _wxlogin;
  @override
  void initState() {
    super.initState();
    _currentPageSubject = BehaviorSubject<int>.seeded(initPage);
    _pageController = PageController(initialPage: initPage);
    _dragAlignment = Alignment(ourMap(initPage, 0, tabs.length - 1, -1, 1), 0);
    _controller = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
    )..addListener(() {
        setState(() {
          _dragAlignment = _animation.value;
        });
      });
    _scrollControllerdanshan.addListener(() {
      if (_scrollControllerdanshan.position.pixels >
          _scrollControllerdanshan.position.maxScrollExtent - 60) {
        if (nolistdanshan) {
          getdanshan();
        }
        setState(() {
          isMoredanshan = false;
        });
      }
      // print(_scrollControllerdanshan.position.pixels);
      setState(() {
        isScolln = _scrollControllerdanshan.position.pixels;
      });
    });
    _scrollControllervideo.addListener(() {
      if (_scrollControllervideo.position.pixels >
          _scrollControllervideo.position.maxScrollExtent - 60) {
        if (nolistvideo) {
          getvideodata();
        }
        setState(() {
          isMorevideo = false;
        });
      }
      setState(() {
        isScolln = _scrollControllervideo.position.pixels;
      });
    });

    _scrollControllerdried.addListener(() {
      if (_scrollControllerdried.position.pixels >
          _scrollControllerdried.position.maxScrollExtent - 60) {
        if (nolistdried) {
          getdriedData();
        }
        setState(() {
          isMoredried = false;
        });
      }
      setState(() {
        isScolln = _scrollControllerdried.position.pixels;
      });
    });
    currentPage$.listen((int page) {
      for (var i = 0, len = arr1.length; i < len; i++) {
        arr1[i].pause();
      }
      if (index == 0) {
        setState(() {
          // listdanshan = [];
          // isMoredanshan = true;
          // pagedanshan = 1;
          // limitdanshan = 10;
          danshankeyword = '';
        });
        // getdanshan();
      } else if (index == 1) {
        setState(() {
          // arr = [];
          // arr1 = [];
          // listvideo = [];
          // isMorevideo = true;
          videokeyword = '';
          // pagevideo = 1;
          // limitvideo = 10;
        });
        // getvideodata();
      } else if (index == 2) {
        setState(() {
          // listdried = [];
          // isMoredried = true;
          driedkeyword = '';
          // pagedried = 1;
          // limitdried = 10;
        });
        // getdriedData();
      }
      // if (index != page) {
      setState(() {
        isScolln = 0;
        index = page;
      });
      // }
      _initKeywordsController.text = '';

      _runAnimation(
        _dragAlignment,
        Alignment(ourMap(page, 0, tabs.length - 1, -1, 1), 0),
      );
    });
    getstyle();
    initData();
    fluwx.registerWxApi(
        appId: "wx234a903f1faba1f9",
        universalLink: "https://app.tuangeche.com.cn/");
    _wxlogin = fluwx.responseFromShare.listen((data) {
      if (data.errCode == 0) {
        getShare(dataId);
      }
    });
  }

  getShare(id) {
    HttpUtlis.post("wx/share/callback",
        params: {'dataId': id, 'type': 5, 'platform': 1},
        success: (value) async {
      if (value['errno'] == 0) {
        print('分享成功～');
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

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

  initData() async {
    await getbanner();
    await getdanshan();
    await getvideodata();
    await getdriedData();
    var citys = await Storage.getString('city');

    setState(() {
      isloading = true;
      city = citys;
    });
  }

  getdriedData() async {
    if (isMoredried) {
      await HttpUtlis.get(
          'wx/promote/articles?page=${this.pagedried}&limit=${this.limitdried}&keyword=${driedkeyword}',
          success: (value) {
        if (value['errno'] == 0) {
          if (mounted) {
            if (value['data']['list'].length < limitdried) {
              setState(() {
                nolistdried = false;
                this.isMoredried = true;
                listdried.addAll(value['data']['list']);
              });
            } else {
              setState(() {
                pagedried++;
                nolistdried = true;
                this.isMoredried = true;
                listdried.addAll(value['data']['list']);
              });
            }
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

  getdanshan() async {
    if (isMoredanshan) {
      await HttpUtlis.get(
          'wx/promote/shows?page=${this.pagedanshan}&limit=${this.limitdanshan}&keyword=${danshankeyword}',
          success: (value) {
        if (value['errno'] == 0) {
          if (mounted) {
            if (value['data']['list'].length < limitdanshan) {
              setState(() {
                nolistdanshan = false;
                this.isMoredanshan = true;
                listdanshan.addAll(value['data']['list']);
              });
            } else {
              setState(() {
                pagedanshan++;
                nolistdanshan = true;
                this.isMoredanshan = true;
                listdanshan.addAll(value['data']['list']);
              });
            }
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

  getbanner() async {
    await HttpUtlis.get('wx/promote/banners', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          banners = value['data'];
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

  getvideodata() async {
    if (isMorevideo) {
      await HttpUtlis.get(
          'wx/promote/vidoes?page=${this.pagevideo}&limit=${this.limitvideo}&keyword=${videokeyword}',
          success: (value) {
            print("list = $value['data']['list']");
        if (value['errno'] == 0) {
          if (mounted) {
            if (value['data']['list'].length < limitvideo) {
              setState(() {
                nolistvideo = false;
                this.isMorevideo = true;
                listvideo.addAll(value['data']['list']);
              });
            } else {
              setState(() {
                pagevideo++;
                nolistvideo = true;
                this.isMorevideo = true;
                listvideo.addAll(value['data']['list']);
              });
            }
            // getvideo();
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

  void _runAnimation(Alignment oldA, Alignment newA) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: oldA,
        end: newA,
      ),
    );
    _controller.reset();
    _controller.forward();
  }

  void dispose() {
    _currentPageSubject.close();
    _pageController.dispose();
    _controller.dispose();
    // disposevideo();
    _wxlogin.cancel();
    super.dispose();
  }

  disposevideo() {
    for (var i = 0, len = listvideo.length; i < len; i++) {
      arr1[i].dispose();
      arr[i].dispose();
    }
  }

  // getvideo() {
  //   setState(() {
  //     arr = [];
  //     arr1 = [];
  //   });
  //   for (var i = 0, len = listvideo.length; i < len; i++) {
  //     if (mounted) {
  //       VideoPlayerController videoPlayerController;
  //       videoPlayerController =
  //           VideoPlayerController.network('${listvideo[i]['url']}');
  //       arr.add(videoPlayerController);
  //       ChewieController chewieController;
  //       chewieController = ChewieController(
  //         videoPlayerController: videoPlayerController,
  //         aspectRatio: 5 / 3,
  //         autoPlay: false,
  //         looping: false,
  //         // placeholder: new Container(
  //         //   decoration: BoxDecoration(
  //         //     image: DecorationImage(
  //         //       image: NetworkImage('${listvideo[i]['pic']}'),
  //         //       fit: BoxFit.fill,
  //         //     ),
  //         //   ),
  //         // ),
  //         showControlsOnInitialize: false,
  //         // fullScreenByDefault: true,
  //         allowMuting: false,
  //         autoInitialize: true,
  //       );
  //       arr1.add(chewieController);
  //     }
  //   }
  // }

  reset() {
    // setState(() {
    isScolln = 0;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final countershare = Provider.of<Backshare>(context);
    final counters = Provider.of<JumpToPage>(context);
    if (countershare.count == 2) {
      _dragAlignment =
          Alignment(ourMap(countershare.count, 0, tabs.length - 1, -1, 1), 0);
      _pageController.jumpToPage(countershare.count);
      currentPageSink.add(countershare.count);
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        countershare.increment(0);
      });
    } else if (countershare.count == 1) {
      _dragAlignment =
          Alignment(ourMap(countershare.count, 0, tabs.length - 1, -1, 1), 0);
      _pageController.jumpToPage(countershare.count);
      currentPageSink.add(countershare.count);
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        countershare.increment(0);
      });
    }
    if (counters.count == 66) {
      currentPageSink.add(1);
      _pageController.jumpToPage(1);
      counters.increment(1);
      reset();
    }

    Ui.init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              appBar: PreferredSize(
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).padding.top,
                    child: SafeArea(child: Text("")),
                  ),
                  preferredSize: Size(0, 0)),
              body: isloading
                  ? Stack(
                      children: <Widget>[
                        Container(
                            color: Colors.white,
                            width: Ui.width(750),
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(24), 0, Ui.width(24), 0),
                            child: Stack(
                              children: <Widget>[
                                PageView(
                                  controller: _pageController,
                                  onPageChanged: (page) =>
                                      currentPageSink.add(page),
                                  children: <Widget>[
                                    Container(
                                      child: ListView(
                                        controller: _scrollControllerdanshan,
                                        children: <Widget>[
                                          SizedBox(
                                            height: Ui.width(531),
                                          ),
                                          Container(
                                            child: listdanshan.length > 0
                                                ? ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(), //禁用滑动事件
                                                    itemCount:
                                                        listdanshan.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return InkWell(
                                                        onTap: () {
                                                          TalkingDataAppAnalytics
                                                              .onEvent(
                                                                  eventID:
                                                                      'dryingSheet',
                                                                  eventLabel:
                                                                      '晒单',
                                                                  params: {
                                                                "title":
                                                                    listdanshan[
                                                                            index]
                                                                        [
                                                                        'title'],
                                                              });

                                                          Navigator.pushNamed(
                                                              context,
                                                              '/danshandtail',
                                                              arguments: {
                                                                'id': listdanshan[
                                                                    index]['id']
                                                              });
                                                        },
                                                        child: Container(
                                                          width: Ui.width(702),
                                                          padding: EdgeInsets
                                                              .fromLTRB(0, 0, 0,
                                                                  Ui.width(30)),
                                                          margin: EdgeInsets
                                                              .fromLTRB(0, 0, 0,
                                                                  Ui.width(35)),
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      width: Ui
                                                                          .width(
                                                                              1),
                                                                      color: Color(
                                                                          0xFFE9ECF1)))),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Container(
                                                                width: Ui.width(
                                                                    702),
                                                                height:
                                                                    Ui.width(
                                                                        90),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            width:
                                                                                Ui.width(90),
                                                                            height:
                                                                                Ui.width(90),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: new BorderRadius.all(new Radius.circular(Ui.width(90.0))),
                                                                              child: CachedNetworkImage(width: Ui.width(90), height: Ui.width(90), fit: BoxFit.fill, imageUrl: '${listdanshan[index]['avatar']}'),
                                                                            ),
                                                                            // decoration:
                                                                            //     BoxDecoration(
                                                                            //   image: DecorationImage(
                                                                            //     image: NetworkImage('${listdanshan[index]['avatar']}?x-oss-process=image/resize,p_70'),
                                                                            //     fit: BoxFit.fill,
                                                                            //   ),
                                                                            //   borderRadius: BorderRadius.all(Radius.circular(Ui.width(90.0))),
                                                                            // ),
                                                                          ),
                                                                          Container(
                                                                            margin: EdgeInsets.fromLTRB(
                                                                                Ui.width(20),
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  '${listdanshan[index]['nickname']}',
                                                                                  style: TextStyle(color: Color(0xFF111F37), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(32.0)),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: Ui.width(5),
                                                                                ),
                                                                                Text(
                                                                                  '${listdanshan[index]['addTime'].substring(0, 10)}',
                                                                                  style: TextStyle(color: Color(0xFF9398A5), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(24.0)),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    // Container(
                                                                    //   child: Column(
                                                                    //     mainAxisAlignment:
                                                                    //         MainAxisAlignment
                                                                    //             .center,
                                                                    //     crossAxisAlignment:
                                                                    //         CrossAxisAlignment
                                                                    //             .center,
                                                                    //     children: <
                                                                    //         Widget>[
                                                                    //       Image.asset(
                                                                    //           'images/2.0x/share.png',
                                                                    //           width: Ui
                                                                    //               .width(
                                                                    //                   36),
                                                                    //           height: Ui
                                                                    //               .width(
                                                                    //                   37)),
                                                                    //       SizedBox(
                                                                    //         height: Ui
                                                                    //             .width(
                                                                    //                 5),
                                                                    //       ),
                                                                    //       Text(
                                                                    //         '分享',
                                                                    //         style: TextStyle(
                                                                    //             color: Color(
                                                                    //                 0xFF111F37),
                                                                    //             fontWeight:
                                                                    //                 FontWeight
                                                                    //                     .w400,
                                                                    //             fontFamily:
                                                                    //                 'PingFangSC-Medium,PingFang SC',
                                                                    //             fontSize:
                                                                    //                 Ui.setFontSizeSetSp(22.0)),
                                                                    //       )
                                                                    //     ],
                                                                    //   ),
                                                                    // )
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        Ui.width(
                                                                            25),
                                                                        0,
                                                                        Ui.width(
                                                                            15)),
                                                                child: Text(
                                                                  '${listdanshan[index]['title']}',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFF111F37),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontFamily:
                                                                          'PingFangSC-Medium,PingFang SC',
                                                                      fontSize:
                                                                          Ui.setFontSizeSetSp(
                                                                              34.0)),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: Ui.width(
                                                                    702),
                                                                height:
                                                                    Ui.width(
                                                                        350),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      width: Ui
                                                                          .width(
                                                                              466),
                                                                      height: Ui
                                                                          .width(
                                                                              450),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius: new BorderRadius
                                                                            .all(new Radius
                                                                                .circular(
                                                                            Ui.width(4.0))),
                                                                        child: CachedNetworkImage(
                                                                            width:
                                                                                Ui.width(466),
                                                                            height: Ui.width(450),
                                                                            fit: BoxFit.fill,
                                                                            imageUrl: '${listdanshan[index]['gallery'][0]}'),
                                                                      ),
                                                                      // decoration:
                                                                      //     BoxDecoration(
                                                                      //   borderRadius:
                                                                      //       BorderRadius.circular(Ui.width(4)),
                                                                      //   image:
                                                                      //       DecorationImage(
                                                                      //     image:
                                                                      //         NetworkImage('${listdanshan[index]['gallery'][0]}?x-oss-process=image/resize,p_70'),
                                                                      //     fit: BoxFit
                                                                      //         .fill,
                                                                      //   ),
                                                                      // ),
                                                                    ),
                                                                    Container(
                                                                      width: Ui
                                                                          .width(
                                                                              226),
                                                                      height: Ui
                                                                          .width(
                                                                              350),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            width:
                                                                                Ui.width(226),
                                                                            height:
                                                                                Ui.width(170),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: new BorderRadius.all(new Radius.circular(Ui.width(4.0))),
                                                                              child: CachedNetworkImage(width: Ui.width(226), height: Ui.width(170), fit: BoxFit.fill, imageUrl: '${listdanshan[index]['gallery'][1]}'),
                                                                            ),
                                                                            // decoration:
                                                                            //     BoxDecoration(
                                                                            //   borderRadius: BorderRadius.circular(Ui.width(4)),
                                                                            //   image: DecorationImage(
                                                                            //     image: NetworkImage('${listdanshan[index]['gallery'][1]}?x-oss-process=image/resize,p_70'),
                                                                            //     fit: BoxFit.fill,
                                                                            //   ),
                                                                            // ),
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                Ui.width(226),
                                                                            height:
                                                                                Ui.width(170),
                                                                            // decoration:
                                                                            //     BoxDecoration(
                                                                            //   borderRadius: BorderRadius.circular(Ui.width(4)),
                                                                            //   image: DecorationImage(
                                                                            //     image: NetworkImage(listdanshan[index]['gallery'].length > 2 ? '${listdanshan[index]['gallery'][2]}?x-oss-process=image/resize,p_70' : '${listdanshan[index]['gallery'][1]}?x-oss-process=image/resize,p_70'),
                                                                            //     fit: BoxFit.fill,
                                                                            //   ),
                                                                            // ),
                                                                            child:
                                                                                Stack(
                                                                              children: <Widget>[
                                                                                Container(
                                                                                  child: ClipRRect(
                                                                                    borderRadius: new BorderRadius.all(new Radius.circular(Ui.width(4.0))),
                                                                                    child: CachedNetworkImage(width: Ui.width(226), height: Ui.width(170), fit: BoxFit.fill, imageUrl: listdanshan[index]['gallery'].length > 2 ? '${listdanshan[index]['gallery'][2]}' : '${listdanshan[index]['gallery'][1]}'),
                                                                                  ),
                                                                                ),
                                                                                Positioned(
                                                                                  left: 0,
                                                                                  top: 0,
                                                                                  child: Container(
                                                                                    width: Ui.width(226),
                                                                                    height: Ui.width(170),
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(Ui.width(4)),
                                                                                      image: DecorationImage(
                                                                                        image: AssetImage('images/2.0x/mask.png'),
                                                                                        fit: BoxFit.fill,
                                                                                      ),
                                                                                    ),
                                                                                    alignment: Alignment.center,
                                                                                    child: Text(
                                                                                      listdanshan[index]['moreImageText'] == null ? '剩余0张' : '${listdanshan[index]['moreImageText']}',
                                                                                      style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(26.0)),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
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
                                                    })
                                                : Container(
                                                    height: Ui.width(600),
                                                    child: Nofind(
                                                      text: "暂无更多数据哦～",
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        child: ListView(
                                            controller: _scrollControllervideo,
                                            children: <Widget>[
                                          SizedBox(
                                            height: Ui.width(531),
                                          ),
                                          Container(
                                              child: listvideo.length > 0
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(), //禁用滑动事件
                                                      itemCount:
                                                          listvideo.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          width: Ui.width(702),
                                                          margin: EdgeInsets
                                                              .fromLTRB(0, 0, 0,
                                                                  Ui.width(30)),
                                                          child: Column(
                                                            children: <Widget>[
                                                              InkWell(
                                                                onTap: () {
                                                                  HttpHelper.saveFootprint(listvideo[index]['title'],listvideo[index]['id'], '5', context);
                                                                  TalkingDataAppAnalytics.onEvent(
                                                                      eventID:
                                                                          'video',
                                                                      eventLabel: '视频',
                                                                      params: {
                                                                        "title":
                                                                            listvideo[index]['title']
                                                                      });
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(CupertinoPageRoute(
                                                                          builder: (_) => FullVideoPage(
                                                                                playType: PlayType.network,
                                                                                titles: '${listvideo[index]['title']}',
                                                                                dataSource: '${listvideo[index]['url']}',
                                                                              )));
                                                                },
                                                                child:
                                                                    Container(
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      // Chewie(
                                                                      //     controller:
                                                                      //         arr1[index]),
                                                                      Container(
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              new BorderRadius.all(new Radius.circular(Ui.width(4.0))),
                                                                          child: CachedNetworkImage(
                                                                              width: Ui.width(702),
                                                                              height: Ui.width(388),
                                                                              fit: BoxFit.fill,
                                                                              imageUrl: '${listvideo[index]['picUrl']}'),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                          left: Ui.width(
                                                                              280),
                                                                          top: Ui.width(
                                                                              130),
                                                                          child: Image.asset(
                                                                              'images/2.0x/bofang.png',
                                                                              width: Ui.width(120),
                                                                              height: Ui.width(120))

                                                                          // child: !arr[index].value.isPlaying
                                                                          //     ? Image.asset('images/2.0x/bofang.png',
                                                                          //         width: Ui.width(120),
                                                                          //         height: Ui.width(120))
                                                                          //     : Text(''),
                                                                          ),
                                                                      Positioned(
                                                                          right:
                                                                              0,
                                                                          top:
                                                                              0,
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              showDialog(
                                                                                  barrierDismissible: true, //是否点击空白区域关闭对话框,默认为true，可以关闭
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    var list = List();
                                                                                    list.add('发送给微信好友');
                                                                                    list.add('分享到微信朋友圈');
                                                                                    return CommonBottomSheet(
                                                                                      list: list,
                                                                                      onItemClickListener: (indexs) async {
                                                                                        var model = fluwx.WeChatShareWebPageModel(webPage: '${Config.weblink}appvideo/${listvideo[index]['id']}', title: '${listvideo[index]['title']}', description: listvideo[index]['goods']!=null?'${listvideo[index]['goods']['name']}':"", thumbnail: "assets://images/loginnew.png", scene: indexs == 0 ? fluwx.WeChatScene.SESSION : fluwx.WeChatScene.TIMELINE, transaction: "hh");
                                                                                        fluwx.shareToWeChat(model);

                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                    );
                                                                                  });
                                                                              setState(() {
                                                                                dataId = listvideo[index]['id'];
                                                                              });
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: Ui.width(70),
                                                                              height: Ui.width(70),
                                                                              child: Image.asset('images/2.0x/sharenew.png', width: Ui.width(70), height: Ui.width(70)),
                                                                            ),
                                                                          ))
                                                                      // Positioned(
                                                                      //     left: Ui.width(
                                                                      //         0),
                                                                      //     bottom: Ui.width(
                                                                      //         80),
                                                                      //     child:
                                                                      //         Container(
                                                                      //       padding: EdgeInsets.fromLTRB(
                                                                      //           Ui.width(30),
                                                                      //           0,
                                                                      //           0,
                                                                      //           0),
                                                                      //       child:
                                                                      //           Row(
                                                                      //         mainAxisAlignment: MainAxisAlignment.start,
                                                                      //         crossAxisAlignment: CrossAxisAlignment.center,
                                                                      //         children: <Widget>[
                                                                      //           Image.asset('images/2.0x/pay.png', width: Ui.width(19), height: Ui.width(24)),
                                                                      //           SizedBox(
                                                                      //             width: Ui.width(10),
                                                                      //           ),
                                                                      //           Text(
                                                                      //             '1308播放',
                                                                      //             style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(24.0)),
                                                                      //           ),
                                                                      //         ],
                                                                      //       ),
                                                                      //     )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .fromLTRB(
                                                                        0,
                                                                        Ui.width(
                                                                            20),
                                                                        0,
                                                                        Ui.width(
                                                                            20)),
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  '${listvideo[index]['title']}',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xFF111F37),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'PingFangSC-Medium,PingFang SC',
                                                                      fontSize:
                                                                          Ui.setFontSizeSetSp(
                                                                              32.0)),
                                                                ),
                                                              ),
                                                              Offstage(
                                                                offstage: listvideo[index]['goods'] == null,
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    TalkingDataAppAnalytics.onEvent(
                                                                        eventID:
                                                                        'cardetail',
                                                                        eventLabel: '汽车详情',
                                                                        params: {
                                                                          "goodSn":
                                                                          listvideo[index]['goods']!=null?listvideo[index]['goods']['goodSn']:""
                                                                        });
                                                                    for (var i =
                                                                    0,
                                                                        len =
                                                                            listvideo.length;
                                                                    i < len;
                                                                    i++) {
                                                                      arr1[i]
                                                                          .pause();
                                                                    }
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        '/cardetail',
                                                                        arguments: {
                                                                          "id": listvideo[index]['goods']!=null?listvideo[index]['goods']
                                                                          [
                                                                          'id']:"",
                                                                        });
                                                                  },
                                                                  child:
                                                                  Container(
                                                                    width:
                                                                    Ui.width(
                                                                        690),
                                                                    constraints:
                                                                    BoxConstraints(
                                                                      minHeight:
                                                                      Ui.width(
                                                                          270),
                                                                    ),
                                                                    decoration:
                                                                    BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      shape: BoxShape
                                                                          .rectangle,
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Color(
                                                                              0XFFDFE3EC),
                                                                          offset: Offset(
                                                                              1,
                                                                              1),
                                                                          blurRadius:
                                                                          Ui.width(10.0),
                                                                        ),
                                                                      ],
                                                                      borderRadius: new BorderRadius
                                                                          .all(new Radius
                                                                          .circular(
                                                                          Ui.width(
                                                                              15.0))),
                                                                    ),
                                                                    child: Stack(
                                                                      children: <
                                                                          Widget>[
                                                                        Positioned(
                                                                            right:
                                                                            0,
                                                                            top:
                                                                            0,
                                                                            child:
                                                                            Container(
                                                                              width:
                                                                              Ui.width(128),
                                                                              height:
                                                                              Ui.width(44),
                                                                              padding: EdgeInsets.fromLTRB(
                                                                                  Ui.width(16),
                                                                                  0,
                                                                                  0,
                                                                                  0),
                                                                              alignment:
                                                                              Alignment.center,
                                                                              decoration: BoxDecoration(
                                                                                  image: DecorationImage(
                                                                                    image: AssetImage('images/2.0x/paragraphnew.png'),
                                                                                    // fit: BoxFit.cover,
                                                                                  )),
                                                                              child:
                                                                              Text(
                                                                                '视频同款',
                                                                                style: TextStyle(color: Color(0xFF111F37), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(24.0)),
                                                                              ),
                                                                            )),
                                                                        Column(
                                                                          mainAxisAlignment:
                                                                          MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              margin: EdgeInsets.fromLTRB(
                                                                                  Ui.width(30),
                                                                                  Ui.width(50),
                                                                                  Ui.width(30),
                                                                                  0),
                                                                              child:
                                                                              Text(
                                                                                listvideo[index]['goods']!=null?'${listvideo[index]['goods']['name']}':"",
                                                                                style: TextStyle(color: Color(0xFF111F37), fontWeight: FontWeight.w500, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(32.0)),
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height:
                                                                              Ui.width(188),
                                                                              margin: EdgeInsets.fromLTRB(
                                                                                  0,
                                                                                  0,
                                                                                  Ui.width(30),
                                                                                  0),
                                                                              // width: Ui.width(690),
                                                                              child:
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Expanded(
                                                                                    flex: 1,
                                                                                    child: Container(
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: <Widget>[
                                                                                          Container(
                                                                                            margin: EdgeInsets.fromLTRB(Ui.width(32), Ui.width(28), 0, 0),
                                                                                            child: RichText(
                                                                                              textAlign: TextAlign.end,
                                                                                              text: TextSpan(
                                                                                                text: '惊爆价:',
                                                                                                style: TextStyle(color: Color(0xFFED3221), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(26.0)),
                                                                                                children: <TextSpan>[
                                                                                                  TextSpan(
                                                                                                    text: listvideo[index]['goods']!=null?'${listvideo[index]['goods']['retailPrice']}${listvideo[index]['goods']['unit']}':"",
                                                                                                    style: TextStyle(fontSize: Ui.setFontSizeSetSp(32.0)),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          Container(
                                                                                            margin: EdgeInsets.fromLTRB(Ui.width(32), Ui.width(10), 0, 0),
                                                                                            child: RichText(
                                                                                              textAlign: TextAlign.end,
                                                                                              text: TextSpan(
                                                                                                text: '官方指导价:',
                                                                                                style: TextStyle(color: Color(0xFF9398A5), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(24.0)),
                                                                                                children: <TextSpan>[
                                                                                                  TextSpan(
                                                                                                    text: listvideo[index]['goods']!=null?'${listvideo[index]['goods']['counterPrice']}${listvideo[index]['goods']['unit']}':"",
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
                                                                                            child: AspectRatio(
                                                                                              aspectRatio: 4 / 3,
                                                                                              child: CachedNetworkImage(
                                                                                                fit: BoxFit.fill,
                                                                                                imageUrl: listvideo[index]['goods']!=null?'${listvideo[index]['goods']['picUrl']}':"",
                                                                                              ),
                                                                                              // Image.network(
                                                                                              //   '${listvideo[index]['goods']['picUrl']}',
                                                                                              // ),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        );
                                                      })
                                                  : Container(
                                                      height: Ui.width(600),
                                                      child: Nofind(
                                                        text: "暂无更多数据哦～",
                                                      ),
                                                    )),
                                        ])),
                                    Container(
                                        child: ListView(
                                            controller: _scrollControllerdried,
                                            children: <Widget>[
                                          SizedBox(
                                            height: Ui.width(531),
                                          ),
                                          Container(
                                              child: listdried.length > 0
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(), //禁用滑动事件
                                                      itemCount:
                                                          listdried.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            //浏览资讯足迹
                                                            HttpHelper.saveFootprint(listdried[index]['title'],listdried[index]['id'], '4', context);
                                                            TalkingDataAppAnalytics
                                                                .onEvent(
                                                                    eventID:
                                                                        'realTimeInfo',
                                                                    eventLabel:
                                                                        '资讯',
                                                                    params: {
                                                                  "title": listdried[
                                                                          index]
                                                                      ['title'],
                                                                });
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/driedwebview',
                                                                arguments: {
                                                                  'id': listdried[
                                                                          index]
                                                                      ['id']
                                                                });
                                                          },
                                                          child: Container(
                                                            height:
                                                                Ui.width(246),
                                                            width:
                                                                Ui.width(702),
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    0,
                                                                    Ui.width(
                                                                        20),
                                                                    0,
                                                                    Ui.width(
                                                                        20)),
                                                            decoration: BoxDecoration(
                                                                border: Border(
                                                                    bottom: BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Color(
                                                                            0xffEAEAEA)))),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 1,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        child:
                                                                            Text(
                                                                          '${listdried[index]['title']}',
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: Color(0xFF111F37),
                                                                              fontWeight: FontWeight.w500,
                                                                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                                                                              fontSize: Ui.setFontSizeSetSp(32.0)),
                                                                        ),
                                                                      ),
                                                                      // Container(
                                                                      //   child: Text(
                                                                      //     '${listdried[index]['content']}',
                                                                      //     maxLines: 2,
                                                                      //     overflow:
                                                                      //         TextOverflow
                                                                      //             .ellipsis,
                                                                      //     style: TextStyle(
                                                                      //         color: Color(
                                                                      //             0xFF9398A5),
                                                                      //         fontWeight:
                                                                      //             FontWeight
                                                                      //                 .w400,
                                                                      //         fontFamily:
                                                                      //             'PingFangSC-Medium,PingFang SC',
                                                                      //         fontSize: Ui
                                                                      //             .setFontSizeSetSp(
                                                                      //                 24.0)),
                                                                      //   ),
                                                                      // ),
                                                                      Container(
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Image.asset(
                                                                              'images/2.0x/loginnew.png',
                                                                              width: Ui.width(36),
                                                                              height: Ui.width(36),
                                                                            ),
                                                                            Container(
                                                                              margin: EdgeInsets.fromLTRB(Ui.width(10), 0, 0, 0),
                                                                              child: Text(
                                                                                '来自团个车',
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(color: Color(0xFF9398A5), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(24.0)),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width:
                                                                      Ui.width(
                                                                          270),
                                                                  height:
                                                                      Ui.width(
                                                                          207),
                                                                  margin: EdgeInsets
                                                                      .fromLTRB(
                                                                          Ui.width(
                                                                              20),
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  // decoration:
                                                                  //     BoxDecoration(
                                                                  //         borderRadius: new BorderRadius.all(new Radius.circular(Ui.width(
                                                                  //             10.0))),
                                                                  //         image:
                                                                  //             DecorationImage(
                                                                  //           image:
                                                                  //               NetworkImage('${listdried[index]['picUrl']}?x-oss-process=image/resize,p_70'),
                                                                  //           fit:
                                                                  //               BoxFit.fill,
                                                                  //         )),
                                                                  child: Stack(
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius:
                                                                              new BorderRadius.all(new Radius.circular(Ui.width(10.0))),
                                                                          child: CachedNetworkImage(
                                                                              width: Ui.width(270),
                                                                              height: Ui.width(207),
                                                                              fit: BoxFit.fill,
                                                                              imageUrl: '${listdried[index]['picUrl']}'),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: 0,
                                                                        left: 0,
                                                                        child: listdried[index]['isHot']
                                                                            ? Container(
                                                                                alignment: Alignment.center,
                                                                                width: Ui.width(70),
                                                                                height: Ui.width(34),
                                                                                decoration: BoxDecoration(
                                                                                    image: DecorationImage(
                                                                                  image: AssetImage('images/2.0x/hot.png'),
                                                                                  // fit: BoxFit.cover,
                                                                                )),
                                                                                child: Text(
                                                                                  '最热',
                                                                                  style: TextStyle(color: Color(0XFFFFFFFF), fontSize: Ui.setFontSizeSetSp(22), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                                                                                ),
                                                                              )
                                                                            : Text(''),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                  : Container(
                                                      height: Ui.width(600),
                                                      child: Nofind(
                                                        text: "暂无更多数据哦～",
                                                      ),
                                                    ))
                                        ]))
                                  ],
                                ),
                              ],
                            )),
                        Positioned(
                          top: Ui.width(93) - isScolln,
                          left: Ui.width(24),
                          child: Container(
                            width: Ui.width(702),
                            height: Ui.width(300),
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                    onTap: () {},
                                    child: Container(
                                      width: Ui.width(702),
                                      height: Ui.width(300),
                                      child: Container(
                                        child: ClipRRect(
                                          borderRadius: new BorderRadius.all(
                                              new Radius.circular(
                                                  Ui.width(4.0))),
                                          child: CachedNetworkImage(
                                              width: Ui.width(702),
                                              height: Ui.width(300),
                                              fit: BoxFit.fill,
                                              imageUrl:
                                                  '${banners[index]['url']}'),
                                        ),
                                      ),
                                      // decoration: BoxDecoration(
                                      //   borderRadius:
                                      //       BorderRadius.circular(Ui.width(4)),
                                      //   image: DecorationImage(
                                      //     image: NetworkImage(
                                      //         '${banners[index]['url']}?x-oss-process=image/resize,p_70'),
                                      //     fit: BoxFit.fill,
                                      //   ),
                                      // ),
                                    ));
                              },
                              itemCount: banners.length,
                              autoplay: banners.length > 1 ? true : false,
                              autoplayDelay: 5000,
                              pagination: SwiperPagination(
                                  alignment: Alignment.bottomCenter,
                                  builder: new SwiperCustomPagination(builder:
                                      (BuildContext context,
                                          SwiperPluginConfig config) {
                                    return new PageIndicator(
                                      layout: PageIndicatorLayout.NIO,
                                      size: 8.0,
                                      space: 15.0,
                                      count: banners.length,
                                      color: Color.fromRGBO(255, 255, 255, 0.4),
                                      activeColor: Color(0XFF111F37),
                                      controller: config.pageController,
                                    );
                                  })),
                            ),
                          ),
                        ),
                        Positioned(
                          top: (Ui.width(393) - isScolln) < Ui.width(90)
                              ? Ui.width(90)
                              : (Ui.width(393) - isScolln),
                          left: Ui.width(24),
                          child: Container(
                            height: Ui.width(138),
                            width: Ui.width(702),
                            color: Colors.white,
                            padding: EdgeInsets.fromLTRB(
                                0, Ui.width(40), 0, Ui.width(40)),
                          ),
                        ),
                        Positioned(
                          top: (Ui.width(393) - isScolln) < Ui.width(90)
                              ? Ui.width(90)
                              : (Ui.width(393) - isScolln),
                          left: Ui.width(24),
                          child: Container(
                              height: Ui.width(138),
                              width: Ui.width(510),
                              color: Colors.white,
                              padding: EdgeInsets.fromLTRB(
                                  0, Ui.width(40), 0, Ui.width(40)),
                              child: Stack(
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: currentPage$,
                                    builder:
                                        (context, AsyncSnapshot<int> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.active) {
                                        return AnimatedAlign(
                                          duration: kThemeAnimationDuration,
                                          alignment: Alignment(
                                              ourMap(snapshot.data, 0,
                                                  tabs.length - 1, -1, 1),
                                              0),
                                          child: LayoutBuilder(
                                            builder: (BuildContext context,
                                                BoxConstraints constraints) {
                                              double width =
                                                  constraints.maxWidth;
                                              return Container(
                                                height: double.infinity,
                                                width: width / tabs.length,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEAEAEC),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Ui.width(30)),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                      return SizedBox();
                                    },
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.start,
                                      children: tabs.map((t) {
                                        int index = tabs.indexOf(t);
                                        return Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              currentPageSink.add(index);
                                              _pageController.jumpToPage(index);
                                            },
                                            child: Container(
                                                height: double.infinity,
                                                width: Ui.width(170),
                                                alignment: Alignment.center,
                                                child: StreamBuilder(
                                                    stream: currentPage$,
                                                    builder: (context,
                                                        AsyncSnapshot<int>
                                                            snapshot) {
                                                      return AnimatedDefaultTextStyle(
                                                        duration:
                                                            kThemeAnimationDuration,
                                                        style: TextStyle(
                                                          inherit: true,
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  30),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Regular,PingFang SC',
                                                          color: snapshot
                                                                      .data ==
                                                                  index
                                                              ? Color(
                                                                  0xFF111F37)
                                                              : Color(
                                                                  0xFF5E6578),
                                                        ),
                                                        child: Text(t),
                                                      );
                                                    })),
                                          ),
                                        );

                                        // Expanded(
                                        //   child: MaterialButton(
                                        //     splashColor: Colors.transparent,
                                        //     focusColor: Colors.transparent,
                                        //     color: Colors.transparent,
                                        //     highlightColor: Colors.transparent,
                                        //     hoverColor: Colors.transparent,
                                        //     focusElevation: 0.0,
                                        //     hoverElevation: 0.0,
                                        //     elevation: 0.0,
                                        //     highlightElevation: 0.0,
                                        //     child: StreamBuilder(
                                        //         stream: currentPage$,
                                        //         builder: (context,
                                        //             AsyncSnapshot<int>
                                        //                 snapshot) {
                                        //           return AnimatedDefaultTextStyle(
                                        //             duration:
                                        //                 kThemeAnimationDuration,
                                        //             style: TextStyle(
                                        //               inherit: true,
                                        //               fontSize:
                                        //                   Ui.setFontSizeSetSp(
                                        //                       24),
                                        //               fontWeight:
                                        //                   FontWeight.w400,
                                        //               fontFamily:
                                        //                   'PingFangSC-Regular,PingFang SC',
                                        //               color: snapshot.data ==
                                        //                       index
                                        //                   ? Color(0xFF111F37)
                                        //                   : Color(0xFF5E6578),
                                        //             ),
                                        //             child: Text(t),
                                        //           );
                                        //         }),
                                        //     onPressed: () {
                                        //       // print(index);
                                        //       currentPageSink.add(index);
                                        //       _pageController.jumpToPage(index);
                                        //     },
                                        //   ),
                                        // );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Positioned(
                            top: 0,
                            child: Container(
                              width: Ui.width(750),
                              height: Ui.width(93),
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: Ui.width(90),
                                    margin: EdgeInsets.fromLTRB(
                                        Ui.width(15), 0, 0, 0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${this.city}',
                                      style: TextStyle(
                                          color: Color(0XFF111F37),
                                          fontSize: Ui.setFontSizeSetSp(28),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'PingFangSC-Regular,PingFang SC;'),
                                    ),
                                  ),
                                  SizedBox(width: Ui.width(10)),
                                  Image.asset(
                                    'images/2.0x/homeadresstop.png',
                                    width: Ui.width(24),
                                    height: Ui.width(29),
                                  ),
                                  SizedBox(width: Ui.width(15)),

                                  Container(
                                    height: Ui.width(62),
                                    width: Ui.width(520),
                                    color: Color(0xFFf5f6fa),
                                    padding: EdgeInsets.fromLTRB(
                                        Ui.width(30), 0, 0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('images/2.0x/searchnew.png',
                                            width: Ui.width(28),
                                            height: Ui.width(28)),
                                        SizedBox(
                                          width: Ui.width(20),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            autofocus: false,
                                            // textInputAction: TextInputAction.none,
                                            keyboardAppearance:
                                                Brightness.light,
                                            keyboardType: TextInputType.text,
                                            controller: _initKeywordsController,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    Ui.setFontSizeSetSp(32)),
                                            decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        0,
                                                        style == 1
                                                            ? Ui.width(22)
                                                            : Ui.width(30)),
                                                border: InputBorder.none,
                                                hintText: '请输入搜索内容',
                                                hintStyle: TextStyle(
                                                    color: Color(0xFFC4C9D3),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: 'Helvetica;',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            28.0))),
                                            onChanged: (value) {
                                              if (index == 0) {
                                                setState(() {
                                                  listdanshan = [];
                                                  isMoredanshan = true;
                                                  danshankeyword = value;
                                                });
                                                getdanshan();
                                              } else if (index == 1) {
                                                setState(() {
                                                  listvideo = [];
                                                  isMorevideo = true;
                                                  videokeyword = value;
                                                });
                                                getvideodata();
                                              } else if (index == 2) {
                                                setState(() {
                                                  listdried = [];
                                                  isMoredried = true;
                                                  driedkeyword = value;
                                                });
                                                getdriedData();
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // InkWell(
                                  //   onTap: () {
                                  //     Navigator.pushNamed(context, '/grabble');
                                  //   },
                                  //   child: Container(
                                  //     height: Ui.width(62),
                                  //     width: Ui.width(520),
                                  //     child: Row(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.center,
                                  //       mainAxisAlignment: MainAxisAlignment.start,
                                  //       children: <Widget>[
                                  //         SizedBox(width: Ui.width(19)),
                                  //         Image.asset(
                                  //           'images/2.0x/searchnew.png',
                                  //           width: Ui.width(28),
                                  //           height: Ui.width(28),
                                  //         ),
                                  //         SizedBox(width: Ui.width(17)),
                                  //         Text(
                                  //           '您想购买什么车',
                                  //           style: TextStyle(
                                  //               color: Color(0XFFC4C9D3),
                                  //               fontSize: Ui.setFontSizeSetSp(28),
                                  //               fontWeight: FontWeight.w400,
                                  //               fontFamily:
                                  //                   'PingFangSC-Regular,PingFang SC;'),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     decoration: BoxDecoration(
                                  //         image: DecorationImage(
                                  //       image: AssetImage(
                                  //           'images/2.0x/searchbgtop.png'),
                                  //     )),
                                  //   ),
                                  // ),

                                  SizedBox(width: Ui.width(15)),
                                  InkWell(
                                    onTap: () async {
                                      // var tel = await Storage.getString('phone');
                                      // var url = 'tel:${tel.replaceAll(' ', '')}';
                                      // if (await canLaunch(url)) {
                                      //   await launch(url);
                                      // } else {
                                      //   throw '拨打失败';
                                      // }
                                    },
                                    child: Image.asset(
                                      'images/2.0x/tips.png',
                                      width: Ui.width(41),
                                      height: Ui.width(38),
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ],
                    )
                  : Container(
                      child: LoadingDialog(
                        text: "加载中...",
                      ),
                    ),
            )));
  }
}
