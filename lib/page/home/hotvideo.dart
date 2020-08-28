import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
// import '../../common/Nofind.dart';
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';

class Hotvideo extends StatefulWidget {
  Hotvideo({Key key}) : super(key: key);

  @override
  _HotvideoState createState() => _HotvideoState();
}

class _HotvideoState extends State<Hotvideo> {
  var test = false;
  bool falge = true;
  // VideoPlayerController _videoPlayerController1;
  // ChewieController _chewieController;
  List arr = [];
  List arr1 = [];

  ScrollController _scrollController = new ScrollController();
  List list = [];
  bool nolist = true;
  bool isMore = true;
  int page = 1;
  int limit = 10;
  @override
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
    // for (var i = 0, len = list.length; i < len; i++) {
    //   VideoPlayerController videoPlayerController;
    //   videoPlayerController =
    //       VideoPlayerController.network('${list[i]['url']}');
    //   arr.add(videoPlayerController);
    //   ChewieController chewieController;
    //   chewieController = ChewieController(
    //     videoPlayerController: videoPlayerController,
    //     aspectRatio: 5 / 3,
    //     autoPlay: false,
    //     looping: false,
    //     showControlsOnInitialize: false,
    //     allowMuting: false,
    //     autoInitialize: true,
    //   );
    //   arr1.add(chewieController);
    // }
  }

  getvideo() {
    setState(() {
      arr = [];
      arr1 = [];
    });
    for (var i = 0, len = list.length; i < len; i++) {
      VideoPlayerController videoPlayerController;
      videoPlayerController =
          VideoPlayerController.network('${list[i]['url']}');
      arr.add(videoPlayerController);
      ChewieController chewieController;
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 5 / 3,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        allowMuting: false,
        autoInitialize: true,
      );
      arr1.add(chewieController);
    }
  }

  getData() async {
    if (isMore) {
      await HttpUtlis.get(
          'wx/promote/vidoes?page=${this.page}&limit=${this.limit}',
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
          getvideo();
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
  void dispose() {
    for (var i = 0, len = list.length; i < len; i++) {
      arr1[i].dispose();
      arr[i].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '热门视频',
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
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(60)),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: list.length,
            itemBuilder: (context, index) {
              return Container(
                  width: Ui.width(690),
                  margin: EdgeInsets.fromLTRB(
                      Ui.width(30), Ui.width(30), Ui.width(30), Ui.width(20)),
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.all(
                        new Radius.circular(Ui.width(20.0))),
                  ),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          for (var i = 0, len = arr1.length; i < len; i++) {
                            arr1[i].pause();
                          }
                          arr1[index].play();
                          setState(() {
                            falge = false;
                          });
                          // }
                        },
                        child: Container(
                          child: Stack(
                            children: <Widget>[
                              Chewie(controller: arr1[index]),
                              Positioned(
                                left: Ui.width(280),
                                top: Ui.width(130),
                                child: !arr[index].value.isPlaying
                                    ? Image.asset('images/2.0x/bofang.png',
                                        width: Ui.width(120),
                                        height: Ui.width(120))
                                    : Text(''),
                              ),
                              Positioned(
                                  left: Ui.width(0),
                                  bottom: Ui.width(80),
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        Ui.width(30), 0, 0, 0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('images/2.0x/pay.png',
                                            width: Ui.width(19),
                                            height: Ui.width(24)),
                                        SizedBox(
                                          width: Ui.width(10),
                                        ),
                                        Text(
                                          '1308播放',
                                          style: TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(24.0)),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            0, Ui.width(20), 0, Ui.width(20)),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${list[index]['title']}',
                          style: TextStyle(
                              color: Color(0xFF111F37),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PingFangSC-Medium,PingFang SC',
                              fontSize: Ui.setFontSizeSetSp(32.0)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          TalkingDataAppAnalytics.onEvent(
                              eventID: 'cardetail',
                              eventLabel: '汽车详情',
                              params: {
                                "goodsSn": list[index]['goods']['goodsSn']
                              });
                          for (var i = 0, len = list.length; i < len; i++) {
                            arr1[i].pause();
                          }

                          Navigator.pushNamed(context, '/cardetail',
                              arguments: {
                                "id": list[index]['goods']['id'],
                              });
                        },
                        child: Container(
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
                            borderRadius: new BorderRadius.all(
                                new Radius.circular(Ui.width(15.0))),
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
                                            '视频同款',
                                            style: TextStyle(
                                                color: Color(0xFF7F3A1C),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(24.0)),
                                          ),
                                        )),
                                    Container(
                                      child: Text(
                                        '               ${list[index]['goods']['name']}',
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
                                                      color: Color(0xFF9398A5),
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
                                                      '${list[index]['goods']['picUrl']}'),

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
                        ),
                      )
                    ],
                  ));
            },
          )

          //  ListView(
          //   children: <Widget>[
          //     Container(
          //         width: Ui.width(690),
          //         margin: EdgeInsets.fromLTRB(Ui.width(30), Ui.width(30), Ui.width(30), 0),
          //         decoration: BoxDecoration(
          //           borderRadius:
          //               new BorderRadius.all(new Radius.circular(Ui.width(20.0))),
          //         ),
          //         child: Column(
          //           children: <Widget>[
          //             Container(
          //               child: Stack(
          //                 children: <Widget>[
          //                   Chewie(
          //                     controller: _chewieController,
          //                   ),
          //                   Positioned(
          //                       left: Ui.width(30),
          //                       bottom: Ui.width(90),
          //                       child: Container(
          //                         padding:
          //                             EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
          //                         child: Row(
          //                           mainAxisAlignment: MainAxisAlignment.start,
          //                           crossAxisAlignment: CrossAxisAlignment.center,
          //                           children: <Widget>[
          //                             Image.asset('images/2.0x/pay.png',
          //                                 width: Ui.width(19),
          //                                 height: Ui.width(24)),
          //                             SizedBox(
          //                               width: Ui.width(10),
          //                             ),
          //                             Text(
          //                               '1308播放',
          //                               style: TextStyle(
          //                                   color: Color(0xFFFFFFFF),
          //                                   fontWeight: FontWeight.w400,
          //                                   fontFamily:
          //                                       'PingFangSC-Medium,PingFang SC',
          //                                   fontSize: Ui.setFontSizeSetSp(24.0)),
          //                             ),
          //                           ],
          //                         ),
          //                       )),
          //                 ],
          //               ),
          //             ),
          //             Container(
          //               padding: EdgeInsets.fromLTRB(
          //                   Ui.width(40), Ui.width(20), 0, Ui.width(30)),
          //               alignment: Alignment.centerLeft,
          //               child: Text(
          //                 '宝马新5系内饰解说',
          //                 style: TextStyle(
          //                     color: Color(0xFF111F37),
          //                     fontWeight: FontWeight.w500,
          //                     fontFamily: 'PingFangSC-Medium,PingFang SC',
          //                     fontSize: Ui.setFontSizeSetSp(32.0)),
          //               ),
          //             ),
          //             Container(
          //               width: Ui.width(690),
          //               padding: EdgeInsets.fromLTRB(
          //                   Ui.width(30), Ui.width(30), Ui.width(30), 0),
          //               margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          //               constraints: BoxConstraints(
          //                 minHeight: Ui.width(270),
          //               ),
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 shape: BoxShape.rectangle,
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Color(0XFFDFE3EC),
          //                     offset: Offset(1, 1),
          //                     blurRadius: Ui.width(20.0),
          //                   ),
          //                 ],
          //                 borderRadius: new BorderRadius.all(
          //                     new Radius.circular(Ui.width(15.0))),
          //               ),
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.start,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: <Widget>[
          //                   Container(
          //                     child: Stack(
          //                       children: <Widget>[
          //                         Positioned(
          //                           left: 0,
          //                           top: 0,
          //                           child: Image.asset(
          //                             'images/2.0x/sepbg.png',
          //                             width: Ui.width(65),
          //                             height: Ui.width(40),
          //                           ),
          //                         ),
          //                         Container(
          //                           child: Text(
          //                             '          哈佛 H6 2020款 1.5GDIT 自动铂金豪华版',
          //                             style: TextStyle(
          //                                 color: Color(0xFF111F37),
          //                                 fontWeight: FontWeight.w500,
          //                                 fontFamily:
          //                                     'PingFangSC-Medium,PingFang SC',
          //                                 fontSize: Ui.setFontSizeSetSp(32.0)),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   Container(
          //                     height: Ui.width(188),
          //                     // width: Ui.width(690),
          //                     child: Row(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: <Widget>[
          //                         Expanded(
          //                           flex: 1,
          //                           child: Container(
          //                             child: Column(
          //                               crossAxisAlignment:
          //                                   CrossAxisAlignment.start,
          //                               mainAxisAlignment:
          //                                   MainAxisAlignment.start,
          //                               children: <Widget>[
          //                                 Container(
          //                                   margin: EdgeInsets.fromLTRB(
          //                                       0, Ui.width(28), 0, 0),
          //                                   child: RichText(
          //                                     textAlign: TextAlign.end,
          //                                     text: TextSpan(
          //                                       text: '惊爆价:',
          //                                       style: TextStyle(
          //                                           color: Color(0xFFED3221),
          //                                           fontWeight: FontWeight.w400,
          //                                           fontFamily:
          //                                               'PingFangSC-Medium,PingFang SC',
          //                                           fontSize: Ui.setFontSizeSetSp(
          //                                               26.0)),
          //                                       children: <TextSpan>[
          //                                         TextSpan(
          //                                           text: '9.05万',
          //                                           style: TextStyle(
          //                                               fontSize:
          //                                                   Ui.setFontSizeSetSp(
          //                                                       32.0)),
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ),
          //                                 ),
          //                                 Container(
          //                                   margin: EdgeInsets.fromLTRB(
          //                                       0, Ui.width(23), 0, 0),
          //                                   child: RichText(
          //                                     textAlign: TextAlign.end,
          //                                     text: TextSpan(
          //                                       text: '官方指导价:',
          //                                       style: TextStyle(
          //                                           color: Color(0xFF9398A5),
          //                                           fontWeight: FontWeight.w400,
          //                                           fontFamily:
          //                                               'PingFangSC-Medium,PingFang SC',
          //                                           fontSize: Ui.setFontSizeSetSp(
          //                                               24.0)),
          //                                       children: <TextSpan>[
          //                                         TextSpan(
          //                                           text: '12.1万',
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ),
          //                                 )
          //                               ],
          //                             ),
          //                           ),
          //                         ),
          //                         Container(
          //                             width: Ui.width(250),
          //                             height: Ui.width(188),
          //                             child: Stack(
          //                               children: <Widget>[
          //                                 Container(
          //                                   width: Ui.width(250),
          //                                   height: Ui.width(188),
          //                                   child: AspectRatio(
          //                                     aspectRatio: 4 / 3,
          //                                     child: Image.network(
          //                                       'https://litecarmall.oss-cn-beijing.aliyuncs.com/kv4j905rfq6fvpl3tpnd.png',
          //                                     ),
          //                                   ),
          //                                 ),
          //                                 // Positioned(
          //                                 //   right: 0,
          //                                 //   top: 0,
          //                                 //   child: Image.asset(
          //                                 //     'images/2.0x/sepbg.png',
          //                                 //     width: Ui.width(65),
          //                                 //     height: Ui.width(56),
          //                                 //   ),
          //                                 // ),
          //                               ],
          //                             ))
          //                       ],
          //                     ),
          //                   )
          //                 ],
          //               ),
          //             )
          //           ],
          //         )),
          //     Container(
          //         width: Ui.width(690),
          //         margin: EdgeInsets.fromLTRB(0, Ui.width(30), 0, 0),
          //         decoration: BoxDecoration(
          //           borderRadius:
          //               new BorderRadius.all(new Radius.circular(Ui.width(20.0))),
          //         ),
          //         child: Column(
          //           children: <Widget>[
          //             Container(
          //               child: Stack(
          //                 children: <Widget>[
          //                   Chewie(
          //                     controller: _chewieController,
          //                   ),
          //                   Positioned(
          //                       left: Ui.width(30),
          //                       bottom: Ui.width(80),
          //                       child: Container(
          //                         padding:
          //                             EdgeInsets.fromLTRB(Ui.width(30), 0, 0, 0),
          //                         child: Row(
          //                           mainAxisAlignment: MainAxisAlignment.start,
          //                           crossAxisAlignment: CrossAxisAlignment.center,
          //                           children: <Widget>[
          //                             Image.asset('images/2.0x/pay.png',
          //                                 width: Ui.width(19),
          //                                 height: Ui.width(24)),
          //                             SizedBox(
          //                               width: Ui.width(10),
          //                             ),
          //                             Text(
          //                               '1308播放',
          //                               style: TextStyle(
          //                                   color: Color(0xFFFFFFFF),
          //                                   fontWeight: FontWeight.w400,
          //                                   fontFamily:
          //                                       'PingFangSC-Medium,PingFang SC',
          //                                   fontSize: Ui.setFontSizeSetSp(24.0)),
          //                             ),
          //                           ],
          //                         ),
          //                       )),
          //                 ],
          //               ),
          //             ),
          //             Container(
          //               padding: EdgeInsets.fromLTRB(
          //                   Ui.width(40), Ui.width(20), 0, Ui.width(30)),
          //               alignment: Alignment.centerLeft,
          //               child: Text(
          //                 '宝马新5系内饰解说',
          //                 style: TextStyle(
          //                     color: Color(0xFF111F37),
          //                     fontWeight: FontWeight.w500,
          //                     fontFamily: 'PingFangSC-Medium,PingFang SC',
          //                     fontSize: Ui.setFontSizeSetSp(32.0)),
          //               ),
          //             ),
          //             Container(
          //               width: Ui.width(690),
          //               padding: EdgeInsets.fromLTRB(
          //                   Ui.width(30), Ui.width(30), Ui.width(30), 0),
          //               margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          //               constraints: BoxConstraints(
          //                 minHeight: Ui.width(270),
          //               ),
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 shape: BoxShape.rectangle,
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Color(0XFFDFE3EC),
          //                     offset: Offset(1, 1),
          //                     blurRadius: Ui.width(20.0),
          //                   ),
          //                 ],
          //                 borderRadius: new BorderRadius.all(
          //                     new Radius.circular(Ui.width(15.0))),
          //               ),
          //               child: Column(
          //                 mainAxisAlignment: MainAxisAlignment.start,
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: <Widget>[
          //                   Container(
          //                     child: Stack(
          //                       children: <Widget>[
          //                         Positioned(
          //                           left: 0,
          //                           top: 0,
          //                           child: Image.asset(
          //                             'images/2.0x/sepbg.png',
          //                             width: Ui.width(65),
          //                             height: Ui.width(40),
          //                           ),
          //                         ),
          //                         Container(
          //                           child: Text(
          //                             '          哈佛 H6 2020款 1.5GDIT 自动铂金豪华版',
          //                             style: TextStyle(
          //                                 color: Color(0xFF111F37),
          //                                 fontWeight: FontWeight.w500,
          //                                 fontFamily:
          //                                     'PingFangSC-Medium,PingFang SC',
          //                                 fontSize: Ui.setFontSizeSetSp(32.0)),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                   Container(
          //                     height: Ui.width(188),
          //                     // width: Ui.width(690),
          //                     child: Row(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: <Widget>[
          //                         Expanded(
          //                           flex: 1,
          //                           child: Container(
          //                             child: Column(
          //                               crossAxisAlignment:
          //                                   CrossAxisAlignment.start,
          //                               mainAxisAlignment:
          //                                   MainAxisAlignment.start,
          //                               children: <Widget>[
          //                                 Container(
          //                                   margin: EdgeInsets.fromLTRB(
          //                                       0, Ui.width(28), 0, 0),
          //                                   child: RichText(
          //                                     textAlign: TextAlign.end,
          //                                     text: TextSpan(
          //                                       text: '惊爆价:',
          //                                       style: TextStyle(
          //                                           color: Color(0xFFED3221),
          //                                           fontWeight: FontWeight.w400,
          //                                           fontFamily:
          //                                               'PingFangSC-Medium,PingFang SC',
          //                                           fontSize: Ui.setFontSizeSetSp(
          //                                               26.0)),
          //                                       children: <TextSpan>[
          //                                         TextSpan(
          //                                           text: '9.05万',
          //                                           style: TextStyle(
          //                                               fontSize:
          //                                                   Ui.setFontSizeSetSp(
          //                                                       32.0)),
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ),
          //                                 ),
          //                                 Container(
          //                                   margin: EdgeInsets.fromLTRB(
          //                                       0, Ui.width(23), 0, 0),
          //                                   child: RichText(
          //                                     textAlign: TextAlign.end,
          //                                     text: TextSpan(
          //                                       text: '官方指导价:',
          //                                       style: TextStyle(
          //                                           color: Color(0xFF9398A5),
          //                                           fontWeight: FontWeight.w400,
          //                                           fontFamily:
          //                                               'PingFangSC-Medium,PingFang SC',
          //                                           fontSize: Ui.setFontSizeSetSp(
          //                                               24.0)),
          //                                       children: <TextSpan>[
          //                                         TextSpan(
          //                                           text: '12.1万',
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ),
          //                                 )
          //                               ],
          //                             ),
          //                           ),
          //                         ),
          //                         Container(
          //                             width: Ui.width(250),
          //                             height: Ui.width(188),
          //                             child: Stack(
          //                               children: <Widget>[
          //                                 Container(
          //                                   width: Ui.width(250),
          //                                   height: Ui.width(188),
          //                                   child: AspectRatio(
          //                                     aspectRatio: 4 / 3,
          //                                     child: Image.network(
          //                                       'https://litecarmall.oss-cn-beijing.aliyuncs.com/kv4j905rfq6fvpl3tpnd.png',
          //                                     ),
          //                                   ),
          //                                 ),
          //                                 // Positioned(
          //                                 //   right: 0,
          //                                 //   top: 0,
          //                                 //   child: Image.asset(
          //                                 //     'images/2.0x/sepbg.png',
          //                                 //     width: Ui.width(65),
          //                                 //     height: Ui.width(56),
          //                                 //   ),
          //                                 // ),
          //                               ],
          //                             ))
          //                       ],
          //                     ),
          //                   )
          //                 ],
          //               ),
          //             )
          //           ],
          //         )),
          //   ],
          // ),
          ),
    );
  }
}
