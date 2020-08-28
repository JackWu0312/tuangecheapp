import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

// import '../../http/index.dart';

class Bannervideo extends StatefulWidget {
  final Map arguments;
  Bannervideo({Key key, this.arguments}) : super(key: key);
  @override
  _BannervideoState createState() => _BannervideoState();
}

class _BannervideoState extends State<Bannervideo> {
  // ChewieController chewieController;
  VideoPlayerController videoPlayerController;
  bool isvideo = false;
  // var arr = [];

  @override
  void initState() {
    // TODO: implement initState、

    super.initState();
    // 在初始化完成后必须更新界面
    videoPlayerController =
        VideoPlayerController.network('${widget.arguments['url']}')
          ..initialize().then((_) {
            setState(() {});
          });
    setsate();
    // 'https://litecarmall.oss-cn-beijing.aliyuncs.com/ea6glniok5dsvsahwd0g.mp4'
  }

  void dispose() {
    videoPlayerController.dispose();
    // arr[1].dispose();
    super.dispose();
  }

  setsate() {
    Future.delayed(Duration(milliseconds: 500)).then((e) {
      setState(() {
        isvideo = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              //  Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
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
        body: Center(
          child: isvideo
              ? Chewie(
                  controller: ChewieController(
                  videoPlayerController: videoPlayerController,
                  aspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          56),
                  autoPlay: true,
                  looping: false,
                  // showControlsOnInitialize: false,
                  allowMuting: false,
                  autoInitialize: true,
                  // fullScreenByDefault:true
                ))
              : SizedBox(),
        ));
  }
}
