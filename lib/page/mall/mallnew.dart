import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../../ui/ui.dart';
import './test.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import '../../common/Nofind.dart';
import '../../common/Storage.dart';
import 'package:provider/provider.dart';
import '../../provider/Successlogin.dart';
import '../../provider/Carnum.dart';
import '../../provider/Integral.dart';
import 'package:cached_network_image/cached_network_image.dart';

double ourMap(v, start1, stop1, start2, stop2) {
  // print(v);
  // print(start1);
  // print(stop1);
  // print(start2);
  // print(stop2);
  return (v - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}

class Mallnew extends StatefulWidget {
  Mallnew({Key key}) : super(key: key);

  @override
  _MallnewState createState() => _MallnewState();
}

class _MallnewState extends State<Mallnew>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final int initPage = 0;
  PageController _pageController;
  // List<String> tabs = ['为你推荐', '养护油品', '汽车配件', '汽车用品'];
  List tabs = [];
  Stream<int> get currentPage$ => _currentPageSubject.stream;
  Sink<int> get currentPageSink => _currentPageSubject.sink;
  BehaviorSubject<int> _currentPageSubject;

  // Alignment _dragAlignment;
  // AnimationController _controller;
  // Animation<Alignment> _animation;

  var _initKeywordsController = new TextEditingController();
  int active = 1;
  ScrollController _scrollController = new ScrollController();
  // ScrollController _scrollControllerpoint = new ScrollController();
  var isScolln = 0.0;
  bool isloading = false;
  List banners = [];
  List tags = [];
  var countshorping = 0;
  bool nolist = true;
  bool isMore = true;
  int page = 1;
  int limit = 1000000;
  List listAll = [];
  int count = 0;
  bool flage = false;
  List pointbanner = [];
  List bannersagin = [];
  List pointtags = [];
  var item;
  bool flages = true;
  @override
  void initState() {
    super.initState();
    initdata();
    // _currentPageSubject = BehaviorSubject<int>.seeded(initPage);
    // _pageController = PageController(initialPage: initPage);
    // _dragAlignment = Alignment(ourMap(initPage, 0, tabs.length - 1, -1, 1), 0);
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: kThemeAnimationDuration,
    // )..addListener(() {
    //     setState(() {
    //       _dragAlignment = _animation.value;
    //     });
    //   });

    // currentPage$.listen((int pages) {
    //   if (flage) {
    //     getDatalist(tabs[pages]);
    //   }
    //   setState(() {
    //     flage = true;
    //     // index = pages;
    //     nolist = true;
    //     isMore = true;
    //     page = 1;
    //     limit = 10;
    //     listAll = [];
    //     // getDatalist(tabs[pages]);
    //   });

    //   _runAnimation(
    //     _dragAlignment,
    //     Alignment(ourMap(page, 0, tabs.length - 1, -1, 1), 0),
    //   );
    // });
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels >
    //       _scrollController.position.maxScrollExtent - 60) {
    //     // if (nolistdanshan) {
    //     //   getdanshan();
    //     // }
    //     // setState(() {
    //     //   isMoredanshan = false;
    //     // });
    //   }

    // });
    _scrollController.addListener(() {
      // print(_scrollController.position.pixels); //获取滚动条下拉的距离
      // print(_scrollController.position.maxScrollExtent); //获取整个页面的高度
      if (active == 1) {
        var i = 0;
        getscoll(i, Ui.width(360));
        setState(() {
          isScolln = _scrollController.position.pixels;
        });
      } else if (active == 2) {
        var i = 0;
        getscollpoint(i, Ui.width(450));
        setState(() {
          isScolln = _scrollController.position.pixels;
        });
      }
      //  print(Ui.width(_scrollController.position.maxScrollExtent)); //100

      // if (_scrollController.position.pixels >
      //     _scrollController.position.maxScrollExtent - 60) {
      //   if (nolist) {
      //     if(flages){
      //        if (active == 1) {
      //       getDatalist(tags[count]['extra']['query']);
      //     } else {
      //       getDatalist(pointtags[count]['extra']['query']);
      //     }
      //     }
      //   }
      //   setState(() {
      //     isMore = false;
      //   });
      // }
    });
    // _scrollControllerpoint.addListener(() {
    //   if (_scrollController.position.pixels >
    //       _scrollController.position.maxScrollExtent - 60) {
    //     if (nolist) {
    //       getDatalist(tags[count]['extra']['query']);
    //     }
    //     setState(() {
    //       isMore = false;
    //     });
    //   }
    //    setState(() {
    //     isScolln = _scrollController.position.pixels;
    //   });
    // });
  }

  // void _runAnimation(Alignment oldA, Alignment newA) {
  //   _animation = _controller.drive(
  //     AlignmentTween(
  //       begin: oldA,
  //       end: newA,
  //     ),
  //   );
  //   _controller.reset();
  //   _controller.forward();
  // }
  getscollpoint(i, scoll) {
    if (i < pointtags.length) {
      if (_scrollController.position.pixels > scoll &&
          _scrollController.position.pixels <
              (scoll + Ui.width(pointtags[i]['nums']))) {
        setState(() {
          count = i;
        });
      }
      getscollpoint(i + 1, scoll + Ui.width(pointtags[i]['nums']));
    }
  }

  getscoll(i, scoll) {
    // print(tags[i]['nums']);
    if (i < tags.length) {
      if (_scrollController.position.pixels > scoll &&
          _scrollController.position.pixels <
              (scoll + Ui.width(tags[i]['nums']))) {
        setState(() {
          count = i;
        });
      }
      getscoll(i + 1, scoll + Ui.width(tags[i]['nums']) - Ui.width(200));
    }
  }

  getcount(carnum) async {
    await HttpUtlis.get('wx/cart/count', success: (value) {
      if (value['errno'] == 0) {
        if (value['data']['count'] != null) {
          setState(() {
            countshorping = value['data']['count'];
          });
        } else {
          setState(() {
            countshorping = 0;
          });
        }
      }
      carnum.increment(countshorping);
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getjumpTo(index) {
    var scoll = Ui.width(360); //Ui.width(510)
    for (var i = 0, len = tags.length; i < len; i++) {
      if (i < index) {
        scoll = scoll + Ui.width(tags[i]['nums']);
      }
    }
    return scoll;
  }

  getjumpTopoint(index) {
    var scoll = Ui.width(680); //Ui.width(510)
    for (var i = 0, len = pointtags.length; i < len; i++) {
      if (i < index) {
        scoll = scoll + Ui.width(pointtags[i]['nums']);
      }
    }
    return scoll;
  }

  getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
  }

  void dispose() {
    _currentPageSubject.close();
    _pageController.dispose();
    // _controller.dispose();
    super.dispose();
  }

  getdataagin() async {
    await HttpUtlis.get('wx/mall/index?best=1', success: (value) async {
      if (value['errno'] == 0) {
        setState(() {
          bannersagin = value['data']['banners'];
          // tags = value['data']['tags'];
          listAll = [];
          isScolln = 0.0;
          this.isloading = true;
        });
        // print(value['data']['tags']);
        if (value['data']['tags'].length > 0) {
          for (var i = 0, len = value['data']['tags'].length; i < len; i++) {
            await getDatalist(value['data']['tags'][i]['extra']['query'], i);
          } //x
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

  getData() async {
    await HttpUtlis.get('wx/mall/index', success: (value) async {
      if (value['errno'] == 0) {
        // List list = [];
        // for (var i = 0, len = value['data']['tags'].length; i < len; i++) {
        //   list.add(value['data']['tags'][i]['label']);
        // }
        // 草！！
        print('object');
        print(value['data']['banners']);
        setState(() {
          banners = value['data']['banners'];
          tags = value['data']['tags'];
          // tabs = list;
          listAll = [];
          isScolln = 0.0;
          this.isloading = true;
        });

        if (value['data']['tags'].length > 0) {
          for (var i = 0, len = value['data']['tags'].length; i < len; i++) {
            await getDatalist(value['data']['tags'][i]['extra']['query'], i);
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

  getDatalist(data, index) async {
    var str = '';
    data.forEach((key, value) {
      str = str + '${key}=${value}&';
    });
    int type = 1;
    if (active == 1 || active == 3) {
      type = 1;
    } else {
      type = 3;
    }
    // if (isMore) {
    await HttpUtlis.get(
        'wx/goods/list?type=${type}&page=${page}&limit=${limit}&${str.substring(0, str.length - 1)}',
        success: (value) {
      if (value['errno'] == 0) {
        // if (value['data']['list'].length < limit) {
        setState(() {
          // nolist = false;
          // this.isMore = true;
          // flages=true;  print((13/5).ceil());
          if (active == 1 || active == 1) {
            setState(() {
              tags[index]['nums'] =
                  (value['data']['list'].length / 2).ceil() * 480.0;
            });
          } else if (active == 2) {
            setState(() {
              pointtags[index]['nums'] =
                  (value['data']['list'].length / 2).ceil() * 480.0;
            });
          }
          listAll.addAll(value['data']['list']);
        });
        // print(tags);
        // } else {
        //   setState(() {
        //     // page++;
        //     // nolist = true;
        //     // this.isMore = true;
        //     // flages=true;
        //     listAll.addAll(value['data']['list']);
        //   });
        // }
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    // }
  }

  getDatapoint() async {
    await HttpUtlis.get('wx/points/index', success: (value) async {
      if (value['errno'] == 0) {
        setState(() {
          pointbanner = value['data']['banners'];
          pointtags = value['data']['tags'];
          listAll = [];
          isScolln = 0.0;
          this.isloading = true;
          item = value['data'];
        });
        if (value['data']['tags'].length > 0) {
          for (var i = 0, len = value['data']['tags'].length; i < len; i++) {
            await getDatalist(value['data']['tags'][i]['extra']['query'], i);
          } //x
        }
        // getDatalist(value['data']['tags'][0]['extra']['query']);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  getpoint() async {
    await HttpUtlis.get('wx/points/index', success: (value) async {
      if (value['errno'] == 0) {
        setState(() {
          item = value['data'];
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

  initdata() async {
    await getData();
    setState(() {
      this.isloading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final counter = Provider.of<Successlogin>(context);
    final carnum = Provider.of<Carnum>(context);
    final integrals = Provider.of<Integral>(context);
    if (integrals.count) {
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        //用延迟防止报错
        integrals.increment(false);
      });
      getpoint();
    }
    if (flages) {
      getcount(carnum);
      flages = false;
    }
    if (counter.count) {
      flages = true;
      Future.delayed(Duration(milliseconds: 200)).then((e) {
        counter.increment(false);
      });
      //  counter.increment(false);
      getData();
    }
    Ui.init(context);
    showtosh() {
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                  width: Ui.width(600),
                  height: Ui.width(300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.all(Radius.circular(Ui.width(20.0))),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: Ui.width(600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: Ui.width(30),
                            ),
                            Text('温馨提示',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(36.0))),
                            SizedBox(
                              height: Ui.width(40),
                            ),
                            Text('当前还未登陆，请登录～',
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Color(0xFF111F37),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                                    fontSize: Ui.setFontSizeSetSp(30.0))),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: Ui.width(600),
                          height: Ui.width(92),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(
                                                  Ui.width(20)))),
                                      alignment: Alignment.center,
                                      child: Text('取消',
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Color(0xFF3895FF),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(36.0))),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: Ui.width(2),
                                            color: Color(0xffEAEAEA)),
                                        right: BorderSide(
                                            width: Ui.width(2),
                                            color: Color(0xffEAEAEA))),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.popAndPushNamed(
                                            context, '/login');
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    Ui.width(20)))),
                                        child: Text('去登陆',
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                color: Color(0xFF3895FF),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(36.0))),
                                      )),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: Ui.width(2),
                                            color: Color(0xffEAEAEA))),
                                  ),
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(Ui.width(20))),
                          ),
                        ),
                      )
                    ],
                  )),
            );
          });
    }

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
                                  Ui.width(0), Ui.width(90), Ui.width(0), 0),
                              child: active == 1
                                  ? Stack(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.fromLTRB(
                                              Ui.width(24),
                                              Ui.width(0),
                                              Ui.width(24),
                                              0),
                                          child: ListView(
                                            controller: _scrollController,
                                            children: <Widget>[
                                              SizedBox(
                                                height: Ui.width(510),
                                              ),
                                              Container(
                                                  child: listAll.length > 0
                                                      ? Container(
                                                          child: Wrap(
                                                              runSpacing:
                                                                  Ui.width(10),
                                                              spacing:
                                                                  Ui.width(10),
                                                              children: listAll
                                                                  .map((val) {
                                                                // print(val);
                                                                return InkWell(
                                                                  onTap: () {
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        '/goods',
                                                                        arguments: {
                                                                          "id":
                                                                              val['id'],
                                                                        });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: Ui
                                                                        .width(
                                                                            346),
                                                                    height: Ui
                                                                        .width(
                                                                            480),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          width:
                                                                              Ui.width(346),
                                                                          height:
                                                                              Ui.width(346),
                                                                          // color: Colors.red,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            image:
                                                                                DecorationImage(
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
                                                                              imageUrl: '${val['picUrl']}'),
                                                                          // AspectRatio(
                                                                          //     aspectRatio: 1 / 1,
                                                                          //     child: Image.network('${val['picUrl']}')),
                                                                        ),
                                                                        Container(
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              SizedBox(
                                                                                height: Ui.width(20),
                                                                              ),
                                                                              Text(
                                                                                '${val['name']}',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(color: Color(0xFF111F37), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(28.0)),
                                                                              ),
                                                                              SizedBox(
                                                                                height: Ui.width(10),
                                                                              ),
                                                                              Text(
                                                                                '${val['retailPrice']}${val['unit']}',
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(color: Color(0xFFD10123), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(28.0)),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }).toList()),
                                                        )
                                                      : Container(
                                                          width:
                                                              double.infinity,
                                                          height: Ui.width(500),
                                                          child: Center(
                                                            child: Nofind(
                                                              text: "没有更多商品哦～",
                                                            ),
                                                          ),
                                                        ))
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: (Ui.width(400) - isScolln) <
                                                  Ui.width(70)
                                              ? Ui.width(70)
                                              : (Ui.width(400) - isScolln),
                                          left: Ui.width(24),
                                          child: Container(
                                            height: Ui.width(98),
                                            width: Ui.width(750),
                                            color: Colors.white,
                                            padding: EdgeInsets.fromLTRB(0,
                                                Ui.width(20), 0, Ui.width(20)),
                                          ),
                                        ),
                                        Positioned(
                                          top: (Ui.width(400) - isScolln) <
                                                  Ui.width(70)
                                              ? Ui.width(70)
                                              : (Ui.width(400) - isScolln),
                                          left: Ui.width(24),
                                          child: Container(
                                            height: Ui.width(98),
                                            width: Ui.width(702),
                                            color: Colors.white,
                                            padding: EdgeInsets.fromLTRB(0,
                                                Ui.width(20), 0, Ui.width(20)),
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: tags.length,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      _scrollController.jumpTo(
                                                          getjumpTo(index));
                                                      setState(() {
                                                        count = index;
                                                        // nolist = true;
                                                        // isMore = true;
                                                        // page = 1;
                                                        // limit = 10;
                                                        // listAll = [];
                                                        //  flages=false;
                                                        // getDatalist(tags[index]['extra']['query']);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: Ui.width(170),
                                                      height: Ui.width(60),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      Ui.width(
                                                                          30)),
                                                          color: count == index
                                                              ? Color(
                                                                  0xFFEAEAEC)
                                                              : Color(
                                                                  0xFFFFFFFF)),
                                                      child: Text(
                                                        '${tags[index]['label']}',
                                                        style: TextStyle(
                                                            color: count ==
                                                                    index
                                                                ? Color(
                                                                    0xFF111F37)
                                                                : Color(
                                                                    0xFF5E6578),
                                                            fontWeight:
                                                                count == index
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    30.0)),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                        Positioned(
                                          top: Ui.width(62) - isScolln,
                                          left: Ui.width(24),
                                          child: Container(
                                            width: Ui.width(702),
                                            height: Ui.width(300),
                                            margin: EdgeInsets.fromLTRB(
                                                0, Ui.width(20), 0, 0),
                                            alignment: Alignment.center,
                                            child: Swiper(
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      if (banners[index]
                                                              ['link'] !=
                                                          null) {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/bannerwebview',
                                                            arguments: {
                                                              "url":
                                                                  banners[index]
                                                                      ['link'],
                                                              "title":
                                                                  banners[index]
                                                                      ['name']
                                                            });
                                                      }
                                                    },
                                                    child: 
                                                    CachedNetworkImage(
                                                      width: Ui.width(702),
                                                      height: Ui.width(300),
                                                      fit: BoxFit.fill,
                                                      imageUrl:
                                                          "${banners[index]['url']}",
                                                    ),

                                                    // Image.network(
                                                    //   "${banners[index]['url']}",
                                                    //   fit: BoxFit.cover,
                                                    // ),
                                                  );
                                                },
                                                itemCount: banners.length,
                                                autoplay: banners.length > 1
                                                    ? true
                                                    : false,
                                                // pagination: SwiperPagination(
                                                //   alignment:
                                                //       Alignment.bottomCenter,
                                                //   builder:
                                                //       new SwiperCustomPagination(
                                                //           builder: (BuildContext
                                                //                   context,
                                                //               SwiperPluginConfig
                                                //                   config) {
                                                //     return new PageIndicator(
                                                //       layout:
                                                //           PageIndicatorLayout
                                                //               .NIO,
                                                //       size: 8.0,
                                                //       space: 15.0,
                                                //       count: banners.length,
                                                //       color: Color.fromRGBO(
                                                //           255, 255, 255, 0.4),
                                                //       activeColor:
                                                //           Color(0XFF111F37),
                                                //       controller:
                                                //           config.pageController,
                                                //     );
                                                //   }),
                                                // )
                                                ),
                                          ),
                                        ),
                                        Positioned(
                                          top: Ui.width(8),
                                          left: Ui.width(24),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/mallseach',
                                                  arguments: {'type': '1'});
                                              // Navigator.pushNamed(
                                              //     context, '/grabble');
                                            },
                                            child: Container(
                                              height: Ui.width(62),
                                              width: Ui.width(702),
                                              // color: Color(0xFFf5f6fa),
                                              padding: EdgeInsets.fromLTRB(
                                                  Ui.width(19), 0, 0, 0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  // SizedBox(width: Ui.width(19)),
                                                  Image.asset(
                                                    'images/2.0x/searchnew.png',
                                                    width: Ui.width(28),
                                                    height: Ui.width(28),
                                                  ),
                                                  SizedBox(width: Ui.width(17)),
                                                  Text(
                                                    '您想购买什么车',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0XFFC4C9D3),
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                28),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Regular,PingFang SC;'),
                                                  ),
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFf5f6fa),
                                                  // color: Color(0XFFFFFFFF),
                                                  borderRadius:
                                                      new BorderRadius.all(
                                                          new Radius.circular(
                                                              Ui.width(4.0))),
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'images/2.0x/searchbgtop.png'),
                                                  )),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: Ui.width(30),
                                          bottom: Ui.width(30),
                                          child: InkWell(
                                            onTap: () async {
                                              if (await getToken() != null) {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/shoppingcart',
                                                );
                                              } else {
                                                showtosh();
                                              }
                                            },
                                            child: Container(
                                              width: Ui.width(100),
                                              height: Ui.width(100),
                                              decoration: BoxDecoration(
                                                  color: Color(0xFFFFFFFF),
                                                  borderRadius:
                                                      new BorderRadius.all(
                                                          new Radius.circular(
                                                              Ui.width(100.0))),
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        'images/2.0x/shorpingcar.png'),
                                                    fit: BoxFit.fill,
                                                  )),
                                              child: Stack(
                                                children: <Widget>[
                                                  Positioned(
                                                    top: Ui.width(24),
                                                    right: Ui.width(21),
                                                    child: Container(
                                                      width: Ui.width(28),
                                                      height: Ui.width(28),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFD10123),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .all(new Radius
                                                                    .circular(
                                                                Ui.width(
                                                                    28.0))),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text('${carnum.count}',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFFFFFFF),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      18.0))),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : active == 2
                                      ? Stack(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  Ui.width(24),
                                                  Ui.width(0),
                                                  Ui.width(24),
                                                  0),
                                              child: ListView(
                                                controller: _scrollController,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: Ui.width(80),
                                                  ),
                                                  Container(
                                                    width: Ui.width(702),
                                                    height: Ui.width(300),
                                                    margin: EdgeInsets.fromLTRB(
                                                        0, Ui.width(20), 0, 0),
                                                    alignment: Alignment.center,
                                                    child: Swiper(
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return InkWell(
                                                            onTap: () {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/bannerwebview',
                                                                  arguments: {
                                                                    "url": pointbanner[
                                                                            index]
                                                                        [
                                                                        'link'],
                                                                    "title": pointbanner[
                                                                            index]
                                                                        ['name']
                                                                  });
                                                            },
                                                            child:
                                                                CachedNetworkImage(
                                                              width:
                                                                  Ui.width(390),
                                                              height:
                                                                  Ui.width(220),
                                                              fit: BoxFit.cover,
                                                              imageUrl:
                                                                  "${pointbanner[index]['url']}",
                                                            ),
                                                            //     Image.network(
                                                            //   "${pointbanner[index]['url']}",
                                                            //   fit: BoxFit.cover,
                                                            // ),
                                                          );
                                                        },
                                                        itemCount:
                                                            pointbanner.length,
                                                        autoplay:
                                                            pointbanner.length >
                                                                    1
                                                                ? true
                                                                : false,
                                                        pagination:
                                                            SwiperPagination(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          builder: new SwiperCustomPagination(
                                                              builder: (BuildContext
                                                                      context,
                                                                  SwiperPluginConfig
                                                                      config) {
                                                            return new PageIndicator(
                                                              layout:
                                                                  PageIndicatorLayout
                                                                      .NIO,
                                                              size: 8.0,
                                                              space: 15.0,
                                                              count: pointbanner
                                                                  .length,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      0.4),
                                                              activeColor: Color(
                                                                  0XFF111F37),
                                                              controller: config
                                                                  .pageController,
                                                            );
                                                          }),
                                                        )),
                                                  ),
                                                  Container(
                                                    width: Ui.width(702.0),
                                                    height: Ui.width(108.0),
                                                    color: Color(0XFFFFFFFF),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                            // alignment: Alignment.center,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Image.asset(
                                                                  'images/2.0x/integral.png',
                                                                  width:
                                                                      Ui.width(
                                                                          29.0),
                                                                  height:
                                                                      Ui.width(
                                                                          32.0),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      Ui.width(
                                                                          20),
                                                                ),
                                                                RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    text:
                                                                        '积分  ',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFF111F37),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'PingFangSC-Medium,PingFang SC',
                                                                        fontSize:
                                                                            Ui.setFontSizeSetSp(30.0)),
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                          text: item["points"] == null
                                                                              ? '0'
                                                                              : '${item["points"]}',
                                                                          style: TextStyle(
                                                                              color: Color(0xFFD10123),
                                                                              fontWeight: FontWeight.w400,
                                                                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                                                                              fontSize: Ui.setFontSizeSetSp(28.0))),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                            flex: 1,
                                                            child: InkWell(
                                                              onTap: () async {
                                                                if (await getToken() !=
                                                                    null) {
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      '/exchange');
                                                                } else {
                                                                  showtosh();
                                                                }
                                                              },
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    Image.asset(
                                                                      'images/2.0x/exchange.png',
                                                                      width: Ui
                                                                          .width(
                                                                              29.0),
                                                                      height: Ui
                                                                          .width(
                                                                              32.0),
                                                                    ),
                                                                    SizedBox(
                                                                      width: Ui
                                                                          .width(
                                                                              20),
                                                                    ),
                                                                    Text('兑换记录',
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xFF111F37),
                                                                            fontWeight: FontWeight
                                                                                .w400,
                                                                            fontFamily:
                                                                                'PingFangSC-Medium,PingFang SC',
                                                                            fontSize:
                                                                                Ui.setFontSizeSetSp(30.0))),
                                                                  ],
                                                                ),
                                                              ),
                                                            )),
                                                        // Expanded(
                                                        //   flex: 1,
                                                        //   child: InkWell(
                                                        //     onTap: () async {
                                                        //       if (await getToken() !=
                                                        //           null) {
                                                        //         Navigator.pushNamed(
                                                        //             context,
                                                        //             '/rollbag');
                                                        //       } else {
                                                        //         showtosh();
                                                        //       }
                                                        //     },
                                                        //     child: Container(
                                                        //       alignment:
                                                        //           Alignment
                                                        //               .center,
                                                        //       child: Row(
                                                        //         mainAxisAlignment:
                                                        //             MainAxisAlignment
                                                        //                 .center,
                                                        //         crossAxisAlignment:
                                                        //             CrossAxisAlignment
                                                        //                 .center,
                                                        //         children: <
                                                        //             Widget>[
                                                        //           Image.asset(
                                                        //             'images/2.0x/rollbag.png',
                                                        //             width: Ui
                                                        //                 .width(
                                                        //                     37.0),
                                                        //             height: Ui
                                                        //                 .width(
                                                        //                     32.0),
                                                        //           ),
                                                        //           SizedBox(
                                                        //             width: Ui
                                                        //                 .width(
                                                        //                     20),
                                                        //           ),
                                                        //           Text('券包',
                                                        //               style: TextStyle(
                                                        //                   color: Color(
                                                        //                       0xFF111F37),
                                                        //                   fontWeight: FontWeight
                                                        //                       .w400,
                                                        //                   fontFamily:
                                                        //                       'PingFangSC-Medium,PingFang SC',
                                                        //                   fontSize:
                                                        //                       Ui.setFontSizeSetSp(30.0))),
                                                        //         ],
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    color: Color(0xFFFFFFFF),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        InkWell(
                                                          onTap: () async {
                                                            if (await getToken() !=
                                                                null) {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  '/tokenwebview',
                                                                  arguments: {
                                                                    'url':
                                                                        'applotterys'
                                                                  });
                                                            } else {
                                                              showtosh();
                                                            }
                                                          },
                                                          child: Container(
                                                            width:
                                                                Ui.width(346),
                                                            height:
                                                                Ui.width(226),
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    'images/2.0x/turntable.png'),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                Positioned(
                                                                  top: Ui.width(
                                                                      35),
                                                                  left:
                                                                      Ui.width(
                                                                          30),
                                                                  child: Text(
                                                                    '幸运大转盘',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFFFFFFFF),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            'PingFangSC-Medium,PingFang SC',
                                                                        fontSize:
                                                                            Ui.setFontSizeSetSp(34.0)),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: Ui.width(
                                                                      83),
                                                                  left:
                                                                      Ui.width(
                                                                          30),
                                                                  child: Text(
                                                                    '积分“转”大奖',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFFFFFFFF),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'PingFangSC-Medium,PingFang SC',
                                                                        fontSize:
                                                                            Ui.setFontSizeSetSp(24.0)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/integral');
                                                          },
                                                          child: Container(
                                                            width:
                                                                Ui.width(346),
                                                            height:
                                                                Ui.width(226),
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    'images/2.0x/explosive.png'),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            child: Stack(
                                                              children: <
                                                                  Widget>[
                                                                Positioned(
                                                                  top: Ui.width(
                                                                      35),
                                                                  left:
                                                                      Ui.width(
                                                                          30),
                                                                  child: Text(
                                                                    '1积分 抽爆品',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFFFFFFFF),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            'PingFangSC-Medium,PingFang SC',
                                                                        fontSize:
                                                                            Ui.setFontSizeSetSp(34.0)),
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: Ui.width(
                                                                      83),
                                                                  left:
                                                                      Ui.width(
                                                                          30),
                                                                  child: Text(
                                                                    '兑海量好礼',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xFFFFFFFF),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontFamily:
                                                                            'PingFangSC-Medium,PingFang SC',
                                                                        fontSize:
                                                                            Ui.setFontSizeSetSp(24.0)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              0,
                                                              Ui.width(100),
                                                              0,
                                                              0),
                                                      child: listAll.length > 0
                                                          ? Container(
                                                              child: Wrap(
                                                                  runSpacing:
                                                                      Ui.width(
                                                                          10),
                                                                  spacing:
                                                                      Ui.width(
                                                                          10),
                                                                  children:
                                                                      listAll.map(
                                                                          (val) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            '/goodsdetail',
                                                                            arguments: {
                                                                              "id": val['id'],
                                                                            });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: Ui.width(
                                                                            346),
                                                                        height:
                                                                            Ui.width(480),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            Container(
                                                                              width: Ui.width(346),
                                                                              height: Ui.width(346),
                                                                              decoration: BoxDecoration(
                                                                                image: DecorationImage(
                                                                                  image: AssetImage(
                                                                                    'images/2.0x/pointbg.png',
                                                                                  ),
                                                                                  fit: BoxFit.fill,
                                                                                ),
                                                                              ),
                                                                              child: CachedNetworkImage(width: Ui.width(346), height: Ui.width(346), fit: BoxFit.fill, imageUrl: '${val['picUrl']}'),

                                                                              //  AspectRatio(aspectRatio: 1 / 1, child: Image.network('${val['picUrl']}')),
                                                                            ),
                                                                            Container(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  SizedBox(
                                                                                    height: Ui.width(20),
                                                                                  ),
                                                                                  Text(
                                                                                    '${val['name']}',
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: Color(0xFF111F37), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(28.0)),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: Ui.width(10),
                                                                                  ),
                                                                                  Text(
                                                                                    '${val['points']}积分+${val['retailPrice']}${val['unit']}',
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: Color(0xFFD10123), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(28.0)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList()),
                                                            )
                                                          : Container(
                                                              width: double
                                                                  .infinity,
                                                              height:
                                                                  Ui.width(500),
                                                              child: Center(
                                                                child: Nofind(
                                                                  text:
                                                                      "没有更多商品哦～",
                                                                ),
                                                              ),
                                                            ))
                                                ],
                                              ),
                                            ),

                                            Positioned(
                                                top:
                                                    (Ui.width(720) - isScolln) <
                                                            Ui.width(60)
                                                        ? Ui.width(60)
                                                        : (Ui.width(720) -
                                                            isScolln),
                                                left: Ui.width(24),
                                                child: Container(
                                                  height: Ui.width(98),
                                                  width: Ui.width(702),
                                                  color: Colors.white,
                                                  padding: EdgeInsets.fromLTRB(
                                                      0,
                                                      Ui.width(20),
                                                      0,
                                                      Ui.width(20)),
                                                  child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          pointtags.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            _scrollController
                                                                .jumpTo(
                                                                    getjumpTopoint(
                                                                        index));

                                                            setState(() {
                                                              count = index;
                                                              // nolist = true;
                                                              // isMore = true;
                                                              // page = 1;
                                                              // limit = 10;
                                                              // listAll = [];
                                                              //  flages=false;
                                                              // getDatalist(pointtags[index]['extra']['query']);
                                                            });
                                                          },
                                                          child: Container(
                                                            width:
                                                                Ui.width(170),
                                                            height:
                                                                Ui.width(60),
                                                            alignment: Alignment
                                                                .center,
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .circular(Ui
                                                                        .width(
                                                                            30)),
                                                                color: count ==
                                                                        index
                                                                    ? Color(
                                                                        0xFFEAEAEC)
                                                                    : Color(
                                                                        0xFFFFFFFF)),
                                                            child: Text(
                                                              '${pointtags[index]['label']}',
                                                              style: TextStyle(
                                                                  color: count ==
                                                                          index
                                                                      ? Color(
                                                                          0xFF111F37)
                                                                      : Color(
                                                                          0xFF5E6578),
                                                                  fontWeight: count ==
                                                                          index
                                                                      ? FontWeight
                                                                          .w500
                                                                      : FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'PingFangSC-Medium,PingFang SC',
                                                                  fontSize: Ui
                                                                      .setFontSizeSetSp(
                                                                          30.0)),
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                )),
                                            Positioned(
                                              top: Ui.width(8),
                                              left: Ui.width(24),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, '/mallseach',
                                                      arguments: {'type': '3'});
                                                },
                                                child: Container(
                                                  height: Ui.width(62),
                                                  width: Ui.width(702),
                                                  // color: Color(0xFFf5f6fa),
                                                  padding: EdgeInsets.fromLTRB(
                                                      Ui.width(19), 0, 0, 0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      // SizedBox(width: Ui.width(19)),
                                                      Image.asset(
                                                        'images/2.0x/searchnew.png',
                                                        width: Ui.width(28),
                                                        height: Ui.width(28),
                                                      ),
                                                      SizedBox(
                                                          width: Ui.width(17)),
                                                      Text(
                                                        '您想购买什么车',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0XFFC4C9D3),
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    28),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Regular,PingFang SC;'),
                                                      ),
                                                    ],
                                                  ),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFf5f6fa),
                                                      // color: Color(0XFFFFFFFF),
                                                      borderRadius:
                                                          new BorderRadius
                                                              .all(new Radius
                                                                  .circular(
                                                              Ui.width(4.0))),
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'images/2.0x/searchbgtop.png'),
                                                      )),
                                                ),
                                              ),
                                            ),
                                            // Positioned(
                                            //   top: 0,
                                            //   left: 0,
                                            //   child: Container(
                                            //     height: Ui.width(62),
                                            //     width: Ui.width(702),
                                            //     color: Color(0xFFf5f6fa),
                                            //     padding: EdgeInsets.fromLTRB(
                                            //         Ui.width(19), Ui.width(10), 0, 0),
                                            //     child: Row(
                                            //       mainAxisAlignment:
                                            //           MainAxisAlignment.start,
                                            //       crossAxisAlignment:
                                            //           CrossAxisAlignment.center,
                                            //       children: <Widget>[
                                            //         Image.asset(
                                            //             'images/2.0x/searchnew.png',
                                            //             width: Ui.width(28),
                                            //             height: Ui.width(28)),
                                            //         SizedBox(
                                            //           width: Ui.width(19),
                                            //         ),
                                            //         Expanded(
                                            //           flex: 1,
                                            //           child: TextField(
                                            //             autofocus: false,
                                            //             // textInputAction: TextInputAction.none,
                                            //             keyboardAppearance:
                                            //                 Brightness.light,
                                            //             keyboardType:
                                            //                 TextInputType.text,
                                            //             controller:
                                            //                 _initKeywordsController,
                                            //             style: TextStyle(
                                            //                 color: Color(0XFF111F37),
                                            //                 fontWeight:
                                            //                     FontWeight.w400,
                                            //                 fontSize:
                                            //                     Ui.setFontSizeSetSp(
                                            //                         32)),
                                            //             decoration: InputDecoration(
                                            //                 contentPadding:
                                            //                     EdgeInsets.fromLTRB(
                                            //                         0,
                                            //                         0,
                                            //                         0,
                                            //                         Ui.width(25)),
                                            //                 border: InputBorder.none,
                                            //                 hintText: '您想兑换什么车品',
                                            //                 hintStyle: TextStyle(
                                            //                     color:
                                            //                         Color(0xFFC4C9D3),
                                            //                     fontWeight:
                                            //                         FontWeight.w400,
                                            //                     fontFamily:
                                            //                         'Helvetica;',
                                            //                     fontSize: Ui
                                            //                         .setFontSizeSetSp(
                                            //                             28.0))),
                                            //             onChanged: (value) {},
                                            //           ),
                                            //         )
                                            //       ],
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        )
                                      : Stack(
                                          children: <Widget>[
                                            Container(
                                              child: ListView(
                                                controller: _scrollController,
                                                children: <Widget>[
                                                  Container(
                                                    // width: Ui.width(702),
                                                    child: AspectRatio(
                                                      aspectRatio: 3 / 4.2,
                                                      child: Swiper(
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return InkWell(
                                                              onTap: () {
                                                                if (bannersagin[
                                                                            index]
                                                                        [
                                                                        'link'] !=
                                                                    null) {
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      '/bannerwebview',
                                                                      arguments: {
                                                                        "url": bannersagin[index]
                                                                            [
                                                                            'link'],
                                                                        "title":
                                                                            bannersagin[index]['name']
                                                                      });
                                                                }
                                                              },
                                                              child:
                                                                  CachedNetworkImage(
                                                                // width: Ui.width(390),
                                                                // height: Ui.width(220),
                                                                fit: BoxFit
                                                                    .cover,
                                                                imageUrl:
                                                                    "${bannersagin[index]['url']}",
                                                              ),
                                                              //     Image.network(
                                                              //   "${bannersagin[index]['url']}",
                                                              //   fit: BoxFit
                                                              //       .cover,
                                                              // ),
                                                            );
                                                          },
                                                          itemCount: bannersagin
                                                              .length,
                                                          autoplay: bannersagin
                                                                      .length >
                                                                  1
                                                              ? true
                                                              : false,
                                                          pagination:
                                                              SwiperPagination(
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            builder: new SwiperCustomPagination(
                                                                builder: (BuildContext
                                                                        context,
                                                                    SwiperPluginConfig
                                                                        config) {
                                                              return new PageIndicator(
                                                                layout:
                                                                    PageIndicatorLayout
                                                                        .NIO,
                                                                size: 8.0,
                                                                space: 15.0,
                                                                count: banners
                                                                    .length,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.4),
                                                                activeColor: Color(
                                                                    0XFF111F37),
                                                                controller: config
                                                                    .pageController,
                                                              );
                                                            }),
                                                          )),
                                                    ),
                                                  ),
                                                  Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              Ui.width(24),
                                                              0,
                                                              Ui.width(24),
                                                              0),
                                                      child: listAll.length > 0
                                                          ? Container(
                                                              child: Wrap(
                                                                  runSpacing:
                                                                      Ui.width(
                                                                          10),
                                                                  spacing:
                                                                      Ui.width(
                                                                          10),
                                                                  children:
                                                                      listAll.map(
                                                                          (val) {
                                                                    return InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            '/goods',
                                                                            arguments: {
                                                                              "id": val['id'],
                                                                            });
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: Ui.width(
                                                                            346),
                                                                        height:
                                                                            Ui.width(480),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
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
                                                                              child: CachedNetworkImage(width: Ui.width(346), height: Ui.width(346), fit: BoxFit.fill, imageUrl: '${val['picUrl']}'),

                                                                              //  AspectRatio(aspectRatio: 1 / 1, child: Image.network('${val['picUrl']}')),
                                                                            ),
                                                                            Container(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  SizedBox(
                                                                                    height: Ui.width(20),
                                                                                  ),
                                                                                  Text(
                                                                                    '${val['name']}',
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: Color(0xFF111F37), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(28.0)),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: Ui.width(10),
                                                                                  ),
                                                                                  Text(
                                                                                    '${val['retailPrice']}${val['unit']}',
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: TextStyle(color: Color(0xFFD10123), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(28.0)),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList()),
                                                            )
                                                          : Container(
                                                              width: double
                                                                  .infinity,
                                                              height:
                                                                  Ui.width(500),
                                                              child: Center(
                                                                child: Nofind(
                                                                  text:
                                                                      "没有更多商品哦～",
                                                                ),
                                                              ),
                                                            ))
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              right: Ui.width(30),
                                              bottom: Ui.width(30),
                                              child: InkWell(
                                                onTap: () async {
                                                  if (await getToken() !=
                                                      null) {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/shoppingcart',
                                                    );
                                                  } else {
                                                    showtosh();
                                                  }
                                                },
                                                child: Container(
                                                  width: Ui.width(100),
                                                  height: Ui.width(100),
                                                  decoration: BoxDecoration(
                                                      color: Color(0xFFFFFFFF),
                                                      borderRadius:
                                                          new BorderRadius
                                                              .all(new Radius
                                                                  .circular(
                                                              Ui.width(100.0))),
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            'images/2.0x/shorpingcar.png'),
                                                        fit: BoxFit.fill,
                                                      )),
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Positioned(
                                                        top: Ui.width(24),
                                                        right: Ui.width(21),
                                                        child: Container(
                                                          width: Ui.width(28),
                                                          height: Ui.width(28),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFD10123),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .all(new Radius
                                                                        .circular(
                                                                    Ui.width(
                                                                        28.0))),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              '${carnum.count}',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFFFFFFFF),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      'PingFangSC-Medium,PingFang SC',
                                                                  fontSize: Ui
                                                                      .setFontSizeSetSp(
                                                                          18.0))),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                          Positioned(
                              top: 0,
                              child: Container(
                                  width: Ui.width(750),
                                  height: Ui.width(100),
                                  padding: EdgeInsets.fromLTRB(Ui.width(24),
                                      Ui.width(15), Ui.width(24), Ui.width(10)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  active = 1;
                                                  isloading = false;
                                                  listAll = [];
                                                  // isScolln=0.0;
                                                  // nolist = true;
                                                  // isMore = true;
                                                  // page = 1;
                                                  // limit = 10;
                                                  count = 0;
                                                });
                                                getData();
                                              },
                                              child: Container(
                                                  width: Ui.width(80),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '车品',
                                                        style: TextStyle(
                                                            color: active == 1
                                                                ? Color(
                                                                    0xFF111F37)
                                                                : Color(
                                                                    0xFF5E6578),
                                                            fontWeight:
                                                                active == 1
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: active ==
                                                                    1
                                                                ? Ui.setFontSizeSetSp(
                                                                    38.0)
                                                                : Ui.setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(10),
                                                      ),
                                                      Container(
                                                        width: Ui.width(40),
                                                        height: Ui.width(6),
                                                        color: active == 1
                                                            ? Color(0xFFD10123)
                                                            : Color(0xFFFFFFFF),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            SizedBox(
                                              width: Ui.width(50),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  active = 2;
                                                  isloading = false;
                                                  count = 0;
                                                  listAll = [];
                                                  // nolist = true;
                                                  // isMore = true;
                                                  // page = 1;
                                                  // limit = 10;
                                                  // isScolln=0.0;
                                                });
                                                getDatapoint();
                                              },
                                              child: Container(
                                                  width: Ui.width(80),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '兑换',
                                                        style: TextStyle(
                                                            color: active == 2
                                                                ? Color(
                                                                    0xFF111F37)
                                                                : Color(
                                                                    0xFF5E6578),
                                                            fontWeight:
                                                                active == 2
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: active ==
                                                                    2
                                                                ? Ui.setFontSizeSetSp(
                                                                    38.0)
                                                                : Ui.setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(10),
                                                      ),
                                                      Container(
                                                        width: Ui.width(40),
                                                        height: Ui.width(6),
                                                        color: active == 2
                                                            ? Color(0xFFD10123)
                                                            : Color(0xFFFFFFFF),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                            SizedBox(
                                              width: Ui.width(40),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  active = 3;
                                                  isloading = false;
                                                  count = 0;
                                                  listAll = [];
                                                });
                                                getdataagin();
                                              },
                                              child: Container(
                                                  width: Ui.width(120),
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '加盟商',
                                                        style: TextStyle(
                                                            color: active == 3
                                                                ? Color(
                                                                    0xFF111F37)
                                                                : Color(
                                                                    0xFF5E6578),
                                                            fontWeight:
                                                                active == 3
                                                                    ? FontWeight
                                                                        .w500
                                                                    : FontWeight
                                                                        .w400,
                                                            fontFamily:
                                                                'PingFangSC-Medium,PingFang SC',
                                                            fontSize: active ==
                                                                    3
                                                                ? Ui.setFontSizeSetSp(
                                                                    38.0)
                                                                : Ui.setFontSizeSetSp(
                                                                    32.0)),
                                                      ),
                                                      SizedBox(
                                                        height: Ui.width(10),
                                                      ),
                                                      Container(
                                                        width: Ui.width(40),
                                                        height: Ui.width(6),
                                                        color: active == 3
                                                            ? Color(0xFFD10123)
                                                            : Color(0xFFFFFFFF),
                                                      )
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/easywebview',
                                              arguments: {
                                                'url': 'appintegral'
                                              });
                                        },
                                        child: Container(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Image.asset(
                                              'images/2.0x/yiwen.png',
                                              width: Ui.width(30),
                                              height: Ui.width(30),
                                            ),
                                            SizedBox(
                                              width: Ui.width(9),
                                            ),
                                            Text(
                                              '积分规则',
                                              style: TextStyle(
                                                  color: Color(0XFF5E6578),
                                                  fontSize:
                                                      Ui.setFontSizeSetSp(26),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Regular,PingFang SC;'),
                                            ),
                                          ],
                                        )),
                                      )
                                    ],
                                  ))),
                        ],
                      )
                    : Container(
                      color: Colors.white,
                        child: LoadingDialog(
                          text: "加载中…",
                        ),
                      ))));
  }
}
