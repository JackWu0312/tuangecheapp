import 'dart:async';
import 'dart:convert';
import 'dart:io'; //提供Platform接口
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
// import 'package:dio/dio.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import '../../ui/ui.dart';
// import '../../config/config.dart';
import '../mall/test.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
// import 'package:amap_location/amap_location.dart';
import '../../common/Storage.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:dio/dio.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_amap_plugin/flutter_amap_plugin.dart';
// import 'package:amap_base/amap_base.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

import './download_progress_dialog.dart';

// import 'package:simple_permissions/simple_permissions.dart';
// import 'package:easy_alert/easy_alert.dart';
// import 'package:permission_handler/permission_handler.dart';
// permission_handler/permission_handler.dart
class Homepage extends StatefulWidget {
  Homepage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  ScrollController _scrollController = new ScrollController();
  bool isbool = false;
  // final _amapLocation = AMapLocation();
  List imgList = [];
  bool isAgree = false;
  bool falge = true;
  List arr = [];
  List arr1 = [];
  var isdingwei = true;
  List list = [
    {
      'url': 'https://v-cdn.zjol.com.cn/276986.mp4',
    },
    {
      'url': 'https://v-cdn.zjol.com.cn/276987.mp4',
    },
    {
      'url': 'https://v-cdn.zjol.com.cn/276988.mp4',
    },
    {
      'url': 'https://v-cdn.zjol.com.cn/276989.mp4',
    },
    {
      'url': 'https://v-cdn.zjol.com.cn/276990.mp4',
    },
  ];

  String city = '';
  List banner = [];
  bool isloading = false;
  List topics = [];
  List secondlist = [];
  List timerlist = [];
  List articles = [];
  List videos = [];
  List shows = [];
  String str = '';
  String str1 = '';
  // Timer _timer;
  var store = '';
  var versions;
  var versionUrl;
  constructTime(int seconds) {
    int day = (seconds ~/ 3600) ~/ 24;
    int hour = (seconds ~/ 3600) % 24;
    int minute = seconds % 3600 ~/ 60;
    int second = seconds % 60;
    var data = {
      'day': formatTime(day),
      'hour': formatTime(hour),
      'minute': formatTime(minute),
      'second': formatTime(second)
    };
    return data;
  }

  getappinfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;
    if (Platform.isAndroid) {
      getversion(2, version);
    }
    if (Platform.isIOS) {
      getversion(3, version);
    }
    // print(appName);
    // print(packageName);
    // print(version);
    // print(buildNumber);
  }

  getversion(platform, version) async {
    // platform 2 安卓  3ios
    await HttpUtlis.get('wx/system/app/update?platform=${platform}',
        success: (value) {
      // print(value);
      if (value['errno'] == 0) {
        print(version);
        if (version != value['data']['version']) {
          setState(() {
            versions = value['data']['version'];
            versionUrl = value['data']['url'];
          });
          _showNewVersionAppDialog(!value['data']['forcible']);
          // _showNewVersionAppDialog(false);

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

  doUpdate(String version, String url) async {
    //关闭更新内容提示框
    Navigator.of(context).pop();

    //获取权限
    var per = await checkPermission();
    if (per != null && !per) {
      return null;
    }

    //开始更新
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      child: DownloadProgressDialog(version, url),
    );
  }

  ///检查是否有权限
  checkPermission() async {
    //检查是否已有读写内存权限
    PermissionStatus status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    //判断如果还没拥有读写权限就申请获取权限
    if (status != PermissionStatus.granted) {
      var map = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      if (map[PermissionGroup.storage] != PermissionStatus.granted) {
        return false;
      }
    }
  }

  //数字格式化，将 0~9 的时间转换为 00~09
  String formatTime(int timeNum) {
    return timeNum < 10 ? "0" + timeNum.toString() : timeNum.toString();
  }

  eachstartTimer() {
    for (var i = 0, len = secondlist.length; i < len; i++) {
      const period = const Duration(seconds: 1);
      var timer = Timer.periodic(period, (timer) {
        //更新界面
        if (secondlist[i] != 0) {
          setState(() {
            //秒数减一，因为一秒回调一次
            secondlist[i]--;
          });
        }
        if (secondlist[i] == 0) {
          //倒计时秒数为0，取消定时器
          cancelTimer();
        }
      });
      timerlist.add(timer);
    }
  }

  void cancelTimer() {
    for (var i = 0, len = timerlist.length; i < len; i++) {
      if (timerlist[i] != null) {
        timerlist[i].cancel();
        timerlist[i] = null;
      }
    }
  }

  // void _initLocation() async {
  // await Storage.setString('city', "太原市");
  // await Storage.setString('longitude', '112.53');
  // await Storage.setString('latitude', '37.87');
  // getjxs(112.53, 37.87);
  // getwechatCode(140100);
  // setState(() {
  //   city = '太原市';
  // });
  // // final _amapLocation = AMapLocation();
  // _amapLocation.init();
  // final options = LocationClientOptions(
  //   isOnceLocation: false,
  //   locatingWithReGeocode: true,
  // );

  // if (await Permissions().requestPermission()) {
  //   Future.delayed(Duration(seconds: 5), () {
  //   _amapLocation.startLocate(options).listen((res) async {
  //     await Storage.setString('city', res.city);
  //     await Storage.setString('longitude', res.longitude.toString());
  //     await Storage.setString('latitude', res.latitude.toString());
  //     print(res);
  //     if (isdingwei) {
  //       setState(() {
  //         city = res.city;
  //         isdingwei = false;
  //       });
  //       // getcity(res.city.substring(0, res.city.length - 1));
  //       getjxs(res.longitude, res.latitude);
  //       getwechatCode(res.adCode);
  //     }
  //     });
  // });

  // Future.delayed(Duration(seconds: 5), () {
  //  if(city!=''){
  // _amapLocation.stopLocate();
  // }
  // });
  // } else {
  //   setState(() {
  //     city = "太原";
  //   });
  // }
  // }

  getlocation() async {
    // print('object');
    // await AMapLocationClient.getLocation(true).then((res) async {
    //   if (!mounted) return;

    //   await Storage.setString('city', res.city);
    //   await Storage.setString('longitude', res.longitude.toString());
    //   await Storage.setString('latitude', res.latitude.toString());

    //   setState(() {
    //     city = res.city;
    //   });
    //   getcity(res.city.substring(0, res.city.length - 1));
    //   getjxs(res.longitude, res.latitude);
    //   getwechatCode(res.adcode);
    // });
    // await AMapLocationClient.startup(new AMapLocationOption(
    //     desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));
    // Map<PermissionGroup, PermissionStatus> permissions =
    //     await PermissionHandler()
    //         .requestPermissions([PermissionGroup.location]);

    // if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
    //   bool isOpened = await PermissionHandler().openAppSettings();
    //   print(isOpened);
    //   Toast.show('无法获取当前位置', context,
    //       backgroundColor: Color(0xff5b5956),
    //       backgroundRadius: Ui.width(16),
    //       duration: Toast.LENGTH_SHORT,
    //       gravity: Toast.CENTER);
    //   // if (isOpened) {
    //   //    print('res.city');
    //   // }
    // } else {
      //    AMapLocationClient.onLocationUpate.listen((AMapLocation res) async{
      //   if (!mounted) return;
      //        await Storage.setString('city', res.city);
      //       await Storage.setString('longitude', res.longitude.toString());
      //       await Storage.setString('latitude', res.latitude.toString());
      //       print(res);
      //       setState(() {
      //         city = res.city;
      //       });
      //       getcity(res.city.substring(0, res.city.length - 1));
      //       getjxs(res.longitude, res.latitude);
      //       getwechatCode(res.adcode);
      //   // print(loc);
      //   // setState(() {
      //   //   location = getLocationStr(loc);
      //   // });
      // });
      // var res = await AMapLocationClient.getLocation(true);
      // //  if (res != null) {
      // await Storage.setString('city', res.city);
      // await Storage.setString('longitude', res.longitude.toString());
      // await Storage.setString('latitude', res.latitude.toString());
      // print(res.city);
      // setState(() {
      //   city = res.city;
      // });
      // getcity(res.city.substring(0, res.city.length - 1));
      // getjxs(res.longitude, res.latitude);
      // getwechatCode(res.adcode);
      // AMapLocationClient.startLocation();
      // await AMapLocationClient.getLocation(true).then((res) async {
      //   // if (res != null) {
      //     await Storage.setString('city', res.city);
      //     await Storage.setString('longitude', res.longitude.toString());
      //     await Storage.setString('latitude', res.latitude.toString());
      //     print(res);
      //     setState(() {
      //       city = res.city;
      //     });
      //     getcity(res.city.substring(0, res.city.length - 1));
      //     getjxs(res.longitude, res.latitude);
      //     getwechatCode(res.adcode);
      //   // }
      // });
      // setState(() {
      //   city = '武汉';
      // });
    // }
    // //  var res= AMapLocationClient.getLocation(true);

    // print(res);

    // });
    // if (!hasPermission) {
    //   PermissionStatus requestPermissionResult =
    //       await SimplePermissions.requestPermission(
    //           Permission.WhenInUseLocation);
    //   if (requestPermissionResult != PermissionStatus.authorized) {
    //     // Alert.alert(context, title: "申请定位权限失败");
    //     return;
    //   }
    // }
    // AMapLocation loc = await AMapLocationClient.getLocation(true);
  }

  getcity(city) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
        'https://api.jisuapi.com/vehiclelimit/city?appkey=faa0c7e42e36387d');
    var data = response.data;
    var list = json.decode(data)['result'];
    for (var i = 0, len = list.length; i < len; i++) {
      if (list[i]['cityname'] == city) {
        getvehiclelimit(list[i]['city']);
        break;
      }
    }
  }

  getvehiclelimit(city) async {
    // print(city);
    var today = DateTime.now();
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
        'https://api.jisuapi.com/vehiclelimit/query?appkey=faa0c7e42e36387d&city=${city}&date=${today.year}-${today.month}-${today.day}');
    var data = response.data;
    var jsons = json.decode(data)['result'];
    setState(() {
      str1 =
          '${jsons['cityname']}  ${jsons['date']}  ${jsons['week']} 限行时间：${jsons['time']}  限行区域：${jsons['area']}  限行摘要：${jsons['summary']}  限行尾号：${jsons['number']}  尾号规则：${jsons['numberrule']}';
    });
  }

  getjxs(longitude, latitude) async {
    await HttpUtlis.post("wx/agent/nearest",
        params: {'longitude': longitude, 'latitude': latitude},
        success: (value) async {
      if (value['errno'] == 0) {
        // print(value['data']);
        setState(() {
          store = value['data']['detail'];
        });
      }
    }, failure: (error) {
      // Toast.show('${error}', context,
      //     backgroundColor: Color(0xff5b5956),
      //     backgroundRadius: Ui.width(16),
      //     duration: Toast.LENGTH_SHORT,
      //     gravity: Toast.CENTER);
    });
  }

  getData() async {
    await HttpUtlis.get('wx/home/index', success: (value) {
      // print(value['data']['videos']);
      if (value['errno'] == 0) {
        var list = value['data']['mall'];
        for (var i = 0, len = list.length; i < len; i++) {
          if (list[i]['key'] == 'MALL_PHONE') {
            Storage.setString('phone', list[i]['value']);
            break;
          }
        }
        var second = value['data']['topics'];
        var secondarr = [];
        for (var i = 0, len = second.length; i < len; i++) {
          var now = DateTime.now();
          var endtime;
          if (DateTime.parse(second[i]['endTime']).millisecondsSinceEpoch -
                  now.millisecondsSinceEpoch >
              0) {
            endtime =
                (DateTime.parse(second[i]['endTime']).millisecondsSinceEpoch -
                        now.millisecondsSinceEpoch) ~/
                    1000;
          } else {
            endtime = 0;
          }
          secondarr.add(endtime);
        }

        setState(() {
          banner = value['data']['banner'];
          topics = value['data']['topics'];
          secondlist = secondarr;
          articles = value['data']['articles'];
          videos = value['data']['videos'];
          shows = value['data']['shows'];
        });
        eachstartTimer();
        getvideo();
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

  void initState() {
    super.initState();
    // await FlutterDownloader.initialize();
    // getappinfo();
    //  const period = const Duration(seconds: 5);
    // _timer = Timer.periodic(period, (timer) {
    //   //更新界面
    //    getlocation();
    // });
    // isAgree?
    // if(isAgree){
    //    showtosh();
    // }
    getinitagree();

    getData();
    _scrollController.addListener(() {
      // print(_scrollController.position.pixels); //获取滚动条下拉的距离
      // print(_scrollController.position.maxScrollExtent); //获取整个页面的高度
      // if (_scrollController.position.pixels >
      //     _scrollController.position.maxScrollExtent - 60) {

      // }
      if (_scrollController.position.pixels > 150) {
        setState(() {
          isbool = true;
        });
      } else {
        setState(() {
          isbool = false;
        });
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      // print('object');
      getlocation();
      // _initLocation();
    });
  }

  getvideo() {
    for (var i = 0, len = videos.length; i < len; i++) {
      VideoPlayerController videoPlayerController;
      videoPlayerController =
          VideoPlayerController.network('${videos[i]['url']}');
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

  videodispose() {
    for (var i = 0, len = videos.length; i < len; i++) {
      arr1[i].dispose();
      arr[i].dispose();
    }
  }

  disposevideo() {
    for (var i = 0, len = arr1.length; i < len; i++) {
      arr1[i].pause();
    }
  }

  void dispose() {
    videodispose();
    // _timer.cancel();
    // _amapLocation.stopLocate();
    // AMapLocationClient.shutdown();
    super.dispose();
  }

  // getdata() async {
  //   var response = await Dio().get("${Config.url}wx/home/index");
  //   // print(response.data['data']['banner']);
  //   // var focusList = FocusModel.fromJson(response.data);
  //   setState(() {
  //     this.imgList = response.data['data']['banner'];
  //   });
  //   //  print(imgList);
  // }

  Widget borderwidth(height) {
    return Container(
      width: double.infinity,
      height: Ui.width(height),
      color: Color(0XFFF8F9FB),
    );
  }

  getagree() async {
    try {
      String agree = await Storage.getString('agree');
      return agree;
    } catch (e) {
      return '';
    }
  }

  getinitagree() async {
    if (await getagree() != null) {
      setState(() {
        isAgree = false;
      });
    } else {
      setState(() {
        isAgree = true;
      });
    }
  }

  Widget titlenew(value) {
    return Text(
      value,
      style: TextStyle(
          color: Color(0XFF111F37),
          fontSize: Ui.setFontSizeSetSp(42),
          fontWeight: FontWeight.w500,
          fontFamily: 'PingFangSC-Regular,PingFang SC;'),
    );
  }

  getwechatCode(citycode) async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get(
      "https://restapi.amap.com/v3/weather/weatherInfo?key=5a1f307d5b13b4e4959e2802ebd1830c&city=${citycode}",
    );
    var json = response.data;
    setState(() {
      str =
          '天气 ${json['lives'][0]['weather']}     气温 ${json['lives'][0]['temperature']}℃';
    });
  }
  // getvehiclelimit()async{
  //   Response response;
  //   Dio dio = new Dio();
  //   response = await dio.get("https://api.jisuapi.com/vehiclelimit/city",);
  //   print(response);
  //   var json =response.data;
  //   // wechatlogin(response.data);
  //  setState(() {
  //    str+='天气 ${json['lives'][0]['weather']}';
  //  });
  // }

  gettopics() {
    // print(topics);
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (var i = 0, len = topics.length; i < len; i++) {
      tiles.add(InkWell(
        onTap: () {
          disposevideo();
          Navigator.pushNamed(context, '/explosive', arguments: {
            'id': topics[i]['id'],
            'title': topics[i]['title'],
          });
        },
        child: Container(
            width: Ui.width(702),
            margin: EdgeInsets.fromLTRB(
                Ui.width(24), i == 0 ? 0 : Ui.width(16), Ui.width(24), 0),
            height: Ui.width(230),
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: Ui.width(30),
                  top: Ui.width(40),
                  child: Text(
                    '${topics[i]['title']}',
                    style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: Ui.setFontSizeSetSp(44),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                  ),
                ),
                Positioned(
                  left: Ui.width(30),
                  top: Ui.width(108),
                  child: Text(
                    '${topics[i]['subtitle']}',
                    style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: Ui.setFontSizeSetSp(24),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                  ),
                ),
                Positioned(
                  left: Ui.width(314),
                  top: Ui.width(54),
                  child: Container(
                      width: Ui.width(93),
                      height: Ui.width(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        image: DecorationImage(
                          image: AssetImage('images/2.0x/go.png'),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(Ui.width(20), 0, 0, 0),
                    width: Ui.width(300),
                    height: Ui.width(60),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/2.0x/salebg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '还剩',
                          style: TextStyle(
                              color: Color(0XFFEE5559),
                              fontSize: Ui.setFontSizeSetSp(20),
                              fontWeight: FontWeight.w400,
                              fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                        ),
                        SizedBox(
                          width: Ui.width(7),
                        ),
                        Container(
                          width: Ui.width(35),
                          height: Ui.width(35),
                          color: Color(0xFFEE5559),
                          alignment: Alignment.center,
                          child: Text(
                            '${constructTime(secondlist[i])['day']}',
                            style: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: Ui.setFontSizeSetSp(22),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(5), 0, Ui.width(5), 0),
                          child: Text(
                            '天',
                            style: TextStyle(
                                color: Color(0XFFEE5559),
                                fontSize: Ui.setFontSizeSetSp(20),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                        Container(
                          width: Ui.width(35),
                          height: Ui.width(35),
                          color: Color(0xFFEE5559),
                          alignment: Alignment.center,
                          child: Text(
                            '${constructTime(secondlist[i])['hour']}',
                            style: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: Ui.setFontSizeSetSp(22),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(5), 0, Ui.width(5), 0),
                          child: Text(
                            '时',
                            style: TextStyle(
                                color: Color(0XFFEE5559),
                                fontSize: Ui.setFontSizeSetSp(20),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                        Container(
                          width: Ui.width(35),
                          height: Ui.width(35),
                          color: Color(0xFFEE5559),
                          alignment: Alignment.center,
                          child: Text(
                            '${constructTime(secondlist[i])['minute']}',
                            style: TextStyle(
                                color: Color(0XFFFFFFFF),
                                fontSize: Ui.setFontSizeSetSp(22),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(
                              Ui.width(5), 0, Ui.width(5), 0),
                          child: Text(
                            '分',
                            style: TextStyle(
                                color: Color(0XFFEE5559),
                                fontSize: Ui.setFontSizeSetSp(20),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
              // color: Colors.white,
              image: DecorationImage(
                image: NetworkImage('${topics[i]['picUrl']}?x-oss-process=image/resize,p_70'),
                fit: BoxFit.cover,
              ),
            )),
      ));
    }

    content = new Column(children: tiles);
    return content;
  }

  void showMyDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
                width: Ui.width(600),
                height: Ui.width(600),
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
                          Text('用户协议与隐私政策',
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Color(0xFF111F37),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(40.0))),
                          SizedBox(
                            height: Ui.width(18),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), 0, Ui.width(30), 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    '    我们尊重并保护所有使用服务用户的个人隐私权。为了给您提供更准确、更有个性化的服务，我们会按照本隐私权政策的规定使用和披露您的个人信息。但我们将以高度的勤勉、审慎义务对待这些信息。除本隐私权政策另有规定外，在未征得您事先许可的情况下，我们不会将这些信息对外披露或向第三方提供。我们会不时更新本隐私权政策。 您在同意我们服务使用协议之时，即视为您已经同意本隐私权政策全部内容。本隐私权政策属于我们服务使用协议不可分割的一部分。',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(24.0))),
                                SizedBox(
                                  height: Ui.width(5),
                                ),
                                Container(
                                  height: Ui.width(30),
                                  // width: Ui.width(500),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('点击查看完整',
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Color(0xFF111F37),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(24.0))),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/easywebview',
                                                arguments: {'url': 'apprlue'});
                                          },
                                          child: Container(
                                            width: Ui.width(300),
                                            child: Text(' 隐私政策',
                                                style: TextStyle(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Color(0xFF3895FF),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            24.0))),
                                          ),
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
                                      Storage.setString('agree', 'agree');
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      alignment: Alignment.center,
                                      child: Text('我知道了',
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Color(0xFF3895FF),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Medium,PingFang SC',
                                              fontSize:
                                                  Ui.setFontSizeSetSp(32.0))),
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

  // doUpdate(String version, String url) async {
  //   //关闭更新内容提示框
  //   Navigator.of(context).pop();
  //   //获取权限
  //   var per = await checkPermission();
  //   if (per != null && !per) {
  //     return null;
  //   }

  //   //开始更新
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     child: DownloadProgressDialog(version, url),
  //   );
  // }

  ///检查是否有权限
  // checkPermission() async {
  //   //检查是否已有读写内存权限
  //   PermissionStatus status = await PermissionHandler()
  //       .checkPermissionStatus(PermissionGroup.storage);

  //   //判断如果还没拥有读写权限就申请获取权限
  //   if (status != PermissionStatus.granted) {
  //     var map = await PermissionHandler()
  //         .requestPermissions([PermissionGroup.storage]);
  //     if (map[PermissionGroup.storage] != PermissionStatus.granted) {
  //       return false;
  //     }
  //   }
  // }

  _showNewVersionAppDialog(forcible) async {
    showDialog(
        context: context,
        barrierDismissible: forcible,
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
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                                  fontSize: Ui.setFontSizeSetSp(40.0))),
                          SizedBox(
                            height: Ui.width(30),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), 0, Ui.width(30), 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text('有新的版本更新哦～',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Color(0xFF111F37),
                                        fontWeight: FontWeight.w400,
                                        fontFamily:
                                            'PingFangSC-Medium,PingFang SC',
                                        fontSize: Ui.setFontSizeSetSp(30.0))),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: forcible
                          ? Container(
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
                                          alignment: Alignment.center,
                                          child: Text('忽略',
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Color(0xFF3895FF),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      36.0))),
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
                                          onTap: () async {
                                            // Navigator.popAndPushNamed(
                                            //     context, '/login');
                                            // doUpdate(versions, versionUrl);
                                            if (Platform.isIOS) {
                                              final url =
                                                  "https://itunes.apple.com/cn/app/1482599438"; // id 后面的数字换成自己的应用 id 就行了
                                              if (await canLaunch(url)) {
                                                await launch(url,
                                                    forceSafariVC: false);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            child: Text('立即更新',
                                                style: TextStyle(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Color(0xFF3895FF),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            36.0))),
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
                            )
                          : Container(
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
                                          onTap: () async {
                                            if (Platform.isIOS) {
                                              final url =
                                                  "https://itunes.apple.com/cn/app/1482599438"; // id 后面的数字换成自己的应用 id 就行了
                                              if (await canLaunch(url)) {
                                                await launch(url,
                                                    forceSafariVC: false);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            }

                                            if (Platform.isAndroid) {
                                              // await FlutterDownloader
                                              //     .initialize();
                                              // Future.delayed(
                                              //     Duration(seconds: 3), () {
                                                doUpdate(versions, versionUrl);
                                              // });
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            child: Text('立即更新',
                                                style: TextStyle(
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Color(0xFF3895FF),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Medium,PingFang SC',
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(
                                                            32.0))),
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

  @override
  Widget build(BuildContext context) {
    if (isAgree) {
      Future.delayed(Duration.zero, () => showMyDialog(context));
      isAgree = false;
    }
    Ui.init(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: !isbool ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          appBar: PreferredSize(
              child: Container(
                color: isbool ? Colors.white : Colors.transparent,
                height:
                    !isbool ? Ui.width(0) : MediaQuery.of(context).padding.top,
                child: SafeArea(child: Text("")),
              ),
              preferredSize: Size(0, 0)),
          body: isloading
              ? Stack(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: ListView(
                        controller: _scrollController,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            height: Ui.width(382.0),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                    top: 0,
                                    left: 0,
                                    child: this.banner.length > 0
                                        ? Container(
                                            height: Ui.width(382.0),
                                            width: Ui.width(750.0),
                                            child: Swiper(
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return InkWell(
                                                  onTap: () {
                                                    if (banner[index]['type']
                                                            ['value'] ==
                                                        1) {
                                                      disposevideo();
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/bannerwebview',
                                                          arguments: {
                                                            "url": banner[index]
                                                                ['link'],
                                                            "title":
                                                                banner[index]
                                                                    ['name']
                                                          });
                                                    } else if (banner[index]
                                                            ['type']['value'] ==
                                                        2) {
                                                      disposevideo();
                                                      Navigator.pushNamed(
                                                          context, '/stage',
                                                          arguments: {
                                                            'url': banner[index]
                                                                ["url"]
                                                          });
                                                    }
                                                  },
                                                  child: Image.network(
                                                    banner[index]["url"],
                                                    fit: BoxFit.fill,
                                                  ),
                                                );
                                              },
                                              itemCount: banner.length,
                                              autoplay: banner.length>1?true:false,
                                              autoplayDelay: 5000,
                                              // duration:5000,
                                              // autoplayDelay: 5,
                                              pagination: SwiperPagination(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  builder:
                                                      new SwiperCustomPagination(
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
                                                      count: banner.length,
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 0.4),
                                                      activeColor:
                                                          Color(0XFF111F37),
                                                      controller:
                                                          config.pageController,
                                                    );
                                                  })),
                                            ),
                                          )
                                        : Text('')),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: Ui.width(63.0),
                            color: Colors.white,
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(24.0), 0, Ui.width(24.0), 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'images/2.0x/hornnew.png',
                                  width: Ui.width(34),
                                  height: Ui.width(29),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    // width: Ui.width(460),
                                    padding: EdgeInsets.fromLTRB(
                                        Ui.width(16.0), 0, 0, 0),
                                    child:Text(
                                      "${this.str1}  ${this.str}",
                                          style: TextStyle(
                                          color: Color(0XFF111F37),
                                          fontSize: Ui.setFontSizeSetSp(26),
                                          fontWeight: FontWeight.w500,
                                          fontFamily:
                                              'PingFangSC-Regular,PingFang SC;'),
                                    )
                                    //  MarqueeWidget(
                                    //   // width: Ui.width(360),
                                    //   text: "${this.str1}  ${this.str}",
                                    //   textStyle: TextStyle(
                                    //       color: Color(0XFF111F37),
                                    //       fontSize: Ui.setFontSizeSetSp(26),
                                    //       fontWeight: FontWeight.w500,
                                    //       fontFamily:
                                    //           'PingFangSC-Regular,PingFang SC;'),
                                    //   scrollAxis: Axis.horizontal,
                                    // ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          borderwidth(16.0),
                          Container(
                            color: Color(0XFFFFFFFF),
                            padding: EdgeInsets.fromLTRB(Ui.width(62),
                                Ui.width(16), Ui.width(62), Ui.width(29)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    disposevideo();
                                    Navigator.pushNamed(context, '/volume');
                                  },
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'images/2.0x/volumes.png',
                                          width: Ui.width(74),
                                          height: Ui.width(74),
                                        ),
                                        SizedBox(
                                          height: Ui.width(12),
                                        ),
                                        Text(
                                          '销量排行',
                                          style: TextStyle(
                                              color: Color(0XFF111F37),
                                              fontSize: Ui.setFontSizeSetSp(24),
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    disposevideo();
                                    Navigator.pushNamed(
                                        context, '/findcarpage');
                                  },
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('images/2.0x/goodcar.png',
                                            width: Ui.width(74),
                                            height: Ui.width(74)),
                                        SizedBox(
                                          height: Ui.width(12),
                                        ),
                                        Text(
                                          '优选好车',
                                          style: TextStyle(
                                              color: Color(0XFF111F37),
                                              fontSize: Ui.setFontSizeSetSp(24),
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // InkWell(
                                //   onTap: () {
                                //     Toast.show('暂未开放此功能～', context,
                                //         backgroundColor: Color(0xff5b5956),
                                //         backgroundRadius: Ui.width(16),
                                //         duration: Toast.LENGTH_SHORT,
                                //         gravity: Toast.CENTER);
                                //   },
                                //   child: Container(
                                //     child: Column(
                                //       mainAxisAlignment:
                                //           MainAxisAlignment.start,
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.center,
                                //       children: <Widget>[
                                //         Image.asset(
                                //             'images/2.0x/calculation.png',
                                //             width: Ui.width(74),
                                //             height: Ui.width(74)),
                                //         SizedBox(
                                //           height: Ui.width(12),
                                //         ),
                                //         Text(
                                //           '购车计算',
                                //           style: TextStyle(
                                //               color: Color(0XFF111F37),
                                //               fontSize: Ui.setFontSizeSetSp(24),
                                //               fontWeight: FontWeight.w500,
                                //               fontFamily:
                                //                   'PingFangSC-Regular,PingFang SC;'),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                InkWell(
                                  onTap: () {
                                    // if (store != null) {
                                    disposevideo();
                                    Navigator.pushNamed(context, '/store',
                                        arguments: {'store': store});
                                    // } else {
                                    //   Toast.show('暂无门店详情', context,
                                    //       backgroundColor: Color(0xff5b5956),
                                    //       backgroundRadius: Ui.width(16),
                                    //       duration: Toast.LENGTH_SHORT,
                                    //       gravity: Toast.CENTER);
                                    // }
                                  },
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset('images/2.0x/store.png',
                                            width: Ui.width(74),
                                            height: Ui.width(74)),
                                        SizedBox(
                                          height: Ui.width(12),
                                        ),
                                        Text(
                                          '附近门店',
                                          style: TextStyle(
                                              color: Color(0XFF111F37),
                                              fontSize: Ui.setFontSizeSetSp(24),
                                              fontWeight: FontWeight.w500,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                              width: Ui.width(702),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(24), 0, Ui.width(24), 0),
                              height: Ui.width(86),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage('images/2.0x/sale.png'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Container(
                              child:
                                  topics.length > 0 ? gettopics() : Text('')),
                          Container(
                            padding: EdgeInsets.fromLTRB(Ui.width(24.0),
                                Ui.width(40.0), Ui.width(24.0), 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '汽车干货',
                                    style: TextStyle(
                                        color: Color(0XFF111F37),
                                        fontSize: Ui.setFontSizeSetSp(40),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Regular,PingFang SC;'),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    disposevideo();
                                    Navigator.pushNamed(context, '/dried');
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '更多',
                                          style: TextStyle(
                                              color: Color(0XFF6A7182),
                                              fontSize: Ui.setFontSizeSetSp(26),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                        SizedBox(
                                          width: Ui.width(10),
                                        ),
                                        Image.asset('images/2.0x/rightmore.png',
                                            width: Ui.width(13),
                                            height: Ui.width(26))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: articles.map((val) {
                                  return InkWell(
                                    onTap: () {
                                      disposevideo();
                                      Navigator.pushNamed(
                                          context, '/driedwebview',
                                          arguments: {'id': val['id']});
                                      // print(val['id']);
                                    },
                                    child: Container(
                                      height: Ui.width(227),
                                      width: Ui.width(690),
                                      margin: EdgeInsets.fromLTRB(
                                          Ui.width(24), 0, Ui.width(24), 0),
                                      padding: EdgeInsets.fromLTRB(
                                          0, Ui.width(20), 0, 0),
                                      decoration: BoxDecoration(
                                          //  color: Colors.red,
                                          // border: Border(
                                          //     bottom:
                                          //         BorderSide(width: 1, color: Color(0xffEAEAEA)))),
                                          ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(270),
                                            height: Ui.width(207),
                                            margin: EdgeInsets.fromLTRB(
                                                0, 0, Ui.width(20), 0),
                                            // color: Colors.red,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(
                                                            Ui.width(10.0))),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      '${val['picUrl']}?x-oss-process=image/resize,p_70'),
                                                  fit: BoxFit.fill,
                                                )),
                                            child: Stack(
                                              children: <Widget>[
                                                Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  child: val['isHot']
                                                      ? Container(
                                                          alignment:
                                                              Alignment.center,
                                                          width: Ui.width(70),
                                                          height: Ui.width(34),
                                                          decoration:
                                                              BoxDecoration(
                                                                  image:
                                                                      DecorationImage(
                                                            image: AssetImage(
                                                                'images/2.0x/hot.png'),
                                                            // fit: BoxFit.cover,
                                                          )),
                                                          child: Text(
                                                            '最热',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0XFFFFFFFF),
                                                                fontSize: Ui
                                                                    .setFontSizeSetSp(
                                                                        22),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Text(
                                                    '${val['title']}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF111F37),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                30.0)),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text(
                                                    '${val['content']}',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                      Image.asset(
                                                        'images/2.0x/loginnew.png',
                                                        width: Ui.width(26),
                                                        height: Ui.width(26),
                                                      ),
                                                      Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                Ui.width(5),
                                                                0,
                                                                0,
                                                                0),
                                                        child: Text(
                                                          '来自团个车',
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF9398A5),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontFamily:
                                                                  'PingFangSC-Medium,PingFang SC',
                                                              fontSize: Ui
                                                                  .setFontSizeSetSp(
                                                                      24.0)),
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
                                }).toList()),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(Ui.width(24.0),
                                Ui.width(40.0), Ui.width(24.0), Ui.width(20.0)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '热门视频',
                                    style: TextStyle(
                                        color: Color(0XFF111F37),
                                        fontSize: Ui.setFontSizeSetSp(40),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Regular,PingFang SC;'),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    disposevideo();
                                    Navigator.pushNamed(context, '/hotvideo');
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '更多',
                                          style: TextStyle(
                                              color: Color(0XFF6A7182),
                                              fontSize: Ui.setFontSizeSetSp(26),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                        SizedBox(
                                          width: Ui.width(10),
                                        ),
                                        Image.asset('images/2.0x/rightmore.png',
                                            width: Ui.width(13),
                                            height: Ui.width(26))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                              width: Ui.width(725),
                              height: Ui.width(340),
                              margin:
                                  EdgeInsets.fromLTRB(Ui.width(24), 0, 0, 0),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: videos.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: Ui.width(470),
                                    height: Ui.width(320),
                                    margin: EdgeInsets.fromLTRB(
                                        0, 0, Ui.width(20), 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            for (var i = 0, len = arr1.length;
                                                i < len;
                                                i++) {
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
                                                  left: Ui.width(190),
                                                  top: Ui.width(90),
                                                  child: !arr[index]
                                                          .value
                                                          .isPlaying
                                                      ? Image.asset(
                                                          'images/2.0x/bofang.png',
                                                          width: Ui.width(90),
                                                          height: Ui.width(90))
                                                      : Text(''),
                                                ),
                                                Positioned(
                                                    left: Ui.width(0),
                                                    bottom: Ui.width(60),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              Ui.width(30),
                                                              0,
                                                              0,
                                                              0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Image.asset(
                                                              'images/2.0x/pay.png',
                                                              width:
                                                                  Ui.width(19),
                                                              height:
                                                                  Ui.width(24)),
                                                          SizedBox(
                                                            width: Ui.width(10),
                                                          ),
                                                          Text(
                                                            '${videos[index]['playCount']}播放',
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
                                                                        24.0)),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.fromLTRB(
                                              0, Ui.width(5), 0, 0),
                                          child: Text(
                                            '${videos[index]['title']}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontSize:
                                                    Ui.setFontSizeSetSp(30),
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'PingFangSC-Regular,PingFang SC;'),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              )),
                          Container(
                            padding: EdgeInsets.fromLTRB(Ui.width(24.0),
                                Ui.width(40.0), Ui.width(24.0), 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '车主晒单',
                                    style: TextStyle(
                                        color: Color(0XFF111F37),
                                        fontSize: Ui.setFontSizeSetSp(40),
                                        fontWeight: FontWeight.w500,
                                        fontFamily:
                                            'PingFangSC-Regular,PingFang SC;'),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    disposevideo();
                                    Navigator.pushNamed(context, '/danshan');
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '更多',
                                          style: TextStyle(
                                              color: Color(0XFF6A7182),
                                              fontSize: Ui.setFontSizeSetSp(26),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                        SizedBox(
                                          width: Ui.width(10),
                                        ),
                                        Image.asset('images/2.0x/rightmore.png',
                                            width: Ui.width(13),
                                            height: Ui.width(26))
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                              width: Ui.width(725),
                              height: Ui.width(320),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(24), Ui.width(20), 0, Ui.width(20)),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: shows.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      disposevideo();
                                      Navigator.pushNamed(
                                          context, '/danshandtail', arguments: {
                                        'id': shows[index]['id']
                                      });
                                    },
                                    child: Container(
                                      width: Ui.width(300),
                                      height: Ui.width(320),
                                      margin: EdgeInsets.fromLTRB(
                                          0, 0, Ui.width(20), 0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: Ui.width(300),
                                            height: Ui.width(230),
                                            decoration: BoxDecoration(
                                                // color: Colors.red,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(
                                                            Ui.width(10.0))),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      '${shows[index]['picUrl']}?x-oss-process=image/resize,p_70'),
                                                  fit: BoxFit.fill,
                                                )),
                                          ),
                                          Container(
                                            margin: EdgeInsets.fromLTRB(
                                                0, Ui.width(10), 0, 0),
                                            child: Text(
                                              '${shows[index]['title']}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Color(0XFF111F37),
                                                  fontSize:
                                                      Ui.setFontSizeSetSp(30),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Regular,PingFang SC;'),
                                            ),
                                          ),
                                          // Container(
                                          //   margin: EdgeInsets.fromLTRB(
                                          //       0, Ui.width(3), 0, 0),
                                          //   child: Text(
                                          //     '${shows[index]['subtitle']}',
                                          //     maxLines: 1,
                                          //     overflow: TextOverflow.ellipsis,
                                          //     style: TextStyle(
                                          //         color: Color(0XFF9398A5),
                                          //         fontSize:
                                          //             Ui.setFontSizeSetSp(24),
                                          //         fontWeight: FontWeight.w400,
                                          //         fontFamily:
                                          //             'PingFangSC-Regular,PingFang SC;'),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ))
                        ],
                      ),
                    ),
                    Positioned(
                        top: 0,
                        // left: Ui.width(20),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              0,
                              isbool
                                  ? 0
                                  : Ui.width(
                                      MediaQuery.of(context).padding.top + 20),
                              0,
                              0),
                          width: Ui.width(750),
                          height: isbool
                              ? Ui.width(93)
                              : Ui.width(
                                      MediaQuery.of(context).padding.top + 20) +
                                  Ui.width(93), // color: Colors.red,
                          decoration: BoxDecoration(
                              color: isbool ? Colors.white : Colors.transparent,
                              image: isbool
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.fill,
                                      image: AssetImage(
                                        'images/2.0x/titlebg.png',
                                      ),
                                    )),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: Ui.width(90),
                                margin:
                                    EdgeInsets.fromLTRB(Ui.width(15), 0, 0, 0),
                                alignment: Alignment.center,
                                child: Text(
                                  '${city}',
                                  style: TextStyle(
                                      color: isbool
                                          ? Color(0XFF111F37)
                                          : Color(0XFFFFFFFF),
                                      fontSize: Ui.setFontSizeSetSp(28),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Regular,PingFang SC;'),
                                ),
                              ),
                              SizedBox(width: Ui.width(10)),
                              Image.asset(
                                isbool
                                    ? 'images/2.0x/homeadresstop.png'
                                    : 'images/2.0x/homeadress.png',
                                width: Ui.width(24),
                                height: Ui.width(29),
                              ),
                              SizedBox(width: Ui.width(15)),
                              InkWell(
                                onTap: () {
                                  disposevideo();
                                  Navigator.pushNamed(context, '/grabble');
                                },
                                child: Container(
                                  height: Ui.width(62),
                                  width: Ui.width(520),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(width: Ui.width(19)),
                                      Image.asset(
                                        'images/2.0x/searchnew.png',
                                        width: Ui.width(28),
                                        height: Ui.width(28),
                                      ),
                                      SizedBox(width: Ui.width(17)),
                                      Text(
                                        '您想购买什么车',
                                        style: TextStyle(
                                            color: Color(0XFFC4C9D3),
                                            fontSize: Ui.setFontSizeSetSp(28),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Regular,PingFang SC;'),
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      // color: Color(0XFFFFFFFF),
                                      // borderRadius: new BorderRadius.all(
                                      //     new Radius.circular(
                                      //         Ui.width(13.0))),
                                      image: DecorationImage(
                                    image: isbool
                                        ? AssetImage(
                                            'images/2.0x/searchbgtop.png')
                                        : AssetImage(
                                            'images/2.0x/searchbg.png'),
                                  )),
                                ),
                              ),
                              SizedBox(width: Ui.width(15)),
                              InkWell(
                                onTap: () async {
                                     Navigator.pushNamed(context, '/conversation',);
                                  // var tel = await Storage.getString('phone');
                                  // var url = 'tel:${tel.replaceAll(' ', '')}';
                                  // if (await canLaunch(url)) {
                                  //   await launch(url);
                                  // } else {
                                  //   throw '拨打失败';
                                  // }
                                },
                                child: Image.asset(
                                  isbool
                                      ? 'images/2.0x/call.png'
                                      : 'images/2.0x/callnew.png',
                                  width: Ui.width(38),
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
                    text: "加载中…",
                  ),
                ),
        ));
  }
}
