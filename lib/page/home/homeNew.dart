import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/ui.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import '../mall/test.dart';
import '../../common/Storage.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/LoadingDialog.dart';
import 'package:amap_location/amap_location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import './download_progress_dialog.dart';
import 'dart:io'; //提供Platform接口
import 'package:talkingdata_appanalytics_plugin/talkingdata_appanalytics_plugin.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeNew extends StatefulWidget {
  HomeNew({Key key}) : super(key: key);

  @override
  _HomeNewState createState() => _HomeNewState();
}

class _HomeNewState extends State<HomeNew> with AutomaticKeepAliveClientMixin{
  @override bool get wantKeepAlive => true;
  ScrollController _scrollController = new ScrollController();
  bool isbool = false;
  List banner = [];
  bool isloading = false;
  String city = '太原市';
  List tags = [];
  Map agent = {};
  List topics = [];
  List tops = [];
  List sales = [];
  var versions;
  var versionUrl;
  bool isAgree = false;
  var ad;
  @override
  void initState() {
    super.initState();
    TalkingDataAppAnalytics.onPageStart('首页'); //埋点使用
    getinitagree();
    getappinfo();
    getData();
    _scrollController.addListener(() {
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
    Future.delayed(Duration(milliseconds: 200)).then((e) {
      getlocation();
    });
  }

  getjxs(longitude, latitude) async {
    await HttpUtlis.post("wx/agent/nearest",
        params: {'longitude': longitude, 'latitude': latitude},
        success: (value) async {
      if (value['errno'] == 0) {
        setState(() {
          agent = value['data'];
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

  getData() async {
    await HttpUtlis.get('wx/home/index', success: (value) {
      if (value['errno'] == 0) {
        var list = value['data']['mall'];
        for (var i = 0, len = list.length; i < len; i++) {
          if (list[i]['key'] == 'MALL_PHONE') {
            Storage.setString('phone', list[i]['value']);
            break;
          }
        }
        setState(() {
          banner = value['data']['banner'];
          tags = value['data']['tags'];
          // agent = value['data']['agent'];
          topics = value['data']['topics'];
          tops = value['data']['tops'];
          sales = value['data']['sales'];
          ad = value['data']['ad'];
        });
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

  getlocation() async {
    await AMapLocationClient.startup(new AMapLocationOption(
        desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));

    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler()
            .requestPermissions([PermissionGroup.location]);
    if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
      // bool isOpened = await PermissionHandler().openAppSettings();
      Toast.show('无法获取当前位置', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    } else {
      var res = await AMapLocationClient.getLocation(true);
      await Storage.setString('city', res.city);
      await Storage.setString('province', res.province);
      await Storage.setString('longitude', res.longitude.toString());
      await Storage.setString('latitude', res.latitude.toString());
      getjxs(res.longitude, res.latitude);
      setState(() {
        city = res.city;
      });

      // AMapLocationClient.onLocationUpate.listen((AMapLocation res) async {
      //   if (!mounted) return;
      //   await Storage.setString('city', res.city);
      //   await Storage.setString('longitude', res.longitude.toString());
      //   await Storage.setString('latitude', res.latitude.toString());
      //   getData(res.longitude, res.latitude);
      //   setState(() {
      //     city = res.city;
      //   });
      // });
      // if (city != '') {
      //   AMapLocationClient.startLocation();
    }
    // }
  }

  getappinfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    if (Platform.isAndroid) {
      getversion(2, version);
    }
    if (Platform.isIOS) {
      getversion(3, version);
    }
  }

  getversion(platform, version) async {
//  bool isOpened = await PermissionHandler().openAppSettings();
    // platform 2 安卓  3ios
    await HttpUtlis.get('wx/system/app/update?platform=${platform}',
        success: (value) {
      if (value['errno'] == 0) {
        if (value['data'] != null) {
          if (version != value['data']['version']) {
            setState(() {
              versions = value['data']['version'];
              versionUrl = value['data']['url'];
            });

            _showNewVersionAppDialog(!value['data']['forcible']);
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

  getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
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

  @override
  void dispose() {
    super.dispose();
    AMapLocationClient.shutdown();
    TalkingDataAppAnalytics.onPageEnd('首页');
  }

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
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          Ui.width(20)))),
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
                                              doUpdate(versions, versionUrl);
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        bottom: Radius.circular(
                                                            Ui.width(20)))),
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
                                              doUpdate(versions, versionUrl);
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

  getsalesWidget() {
    List<Widget> list = [];
    Widget content;
    for (var item in sales) {
      list.add(InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/special',
              arguments: {'id': item['id']});
        },
        child: Container(
          width: Ui.width(702),
          height: Ui.width(300),
          margin: EdgeInsets.fromLTRB(0, Ui.width(10), 0, 0),
          child: Stack(
            children: <Widget>[
              Container(
                child: ClipRRect(
                  borderRadius:
                      new BorderRadius.all(new Radius.circular(Ui.width(4.0))),
                  child: CachedNetworkImage(
                      width: Ui.width(702),
                      height: Ui.width(300),
                      fit: BoxFit.fill,
                      imageUrl: '${item['extra']['pic']}'),
                ),
              ),
              Positioned(
                left: Ui.width(60),
                top: Ui.width(90),
                child: Text(
                  '${item['label']}',
                  style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: Ui.setFontSizeSetSp(46),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                ),
              ),
              Positioned(
                left: Ui.width(60),
                top: Ui.width(160),
                child: Text(
                  '${item['value']}',
                  style: TextStyle(
                      color: Color(0XFFFFFFFF),
                      fontSize: Ui.setFontSizeSetSp(26),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                ),
              )
            ],
          ),
        ),
      ));
    }
    content = new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
    return content;
  }

  gettagsWidget() {
    List<Widget> list = [];
    Widget content;
    for (var item in tags) {
      list.add(InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/ification', arguments: {
            'title': item['label'],
            'query': item['extra']['query'],
          });
        },
        child: Container(
          width: Ui.width(100),
          height: Ui.width(160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: Ui.width(100),
                height: Ui.width(100),
                alignment: Alignment.center,
                child: Container(
                  child: ClipRRect(
                    borderRadius: new BorderRadius.all(
                        new Radius.circular(Ui.width(100.0))),
                    child: CachedNetworkImage(
                        width: Ui.width(100),
                        height: Ui.width(100),
                        fit: BoxFit.fill,
                        imageUrl: '${item['value']}'),
                  ),
                ),
              ),
              SizedBox(
                height: Ui.width(20),
              ),
              Text(
                '${item['label']}',
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xFF111F37),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PingFangSC-Medium,PingFang SC',
                    fontSize: Ui.setFontSizeSetSp(24.0)),
              ),
            ],
          ),
        ),
      ));
    }
    content = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
    return content;
  }

  gettopsItemWidget(goodlist) {
    List<Widget> list = [];
    Widget content;
    for (var item in goodlist) {
      list.add(InkWell(
        onTap: () {
          TalkingDataAppAnalytics.onEvent(
              eventID: 'cardetail',
              eventLabel: '汽车详情',
              params: {"goodsSn": item['goodsSn']});
          Navigator.pushNamed(context, '/cardetail', arguments: {
            "id": item['id'],
          });
        },
        child: Container(
          width: Ui.width(182),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: Ui.width(182),
                height: Ui.width(139),
                child: CachedNetworkImage(
                  fit: BoxFit.fill,
                  imageUrl: '${item['picUrl']}',
                ),
              ),
              SizedBox(
                height: Ui.width(2),
              ),
              Text(
                '${item['name']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0XFF111F37),
                    fontSize: Ui.setFontSizeSetSp(24),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'PingFangSC-Regular,PingFang SC;'),
              ),
            ],
          ),
        ),
      ));
    }
    content = new Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
    return content;
  }

  gettopsWidget() {
    List<Widget> list = [];
    Widget content;
    for (var item in tops) {
      list.add(Container(
        width: Ui.width(702),
        height: Ui.width(323),
        margin:
            EdgeInsets.fromLTRB(Ui.width(24), Ui.width(30), Ui.width(24), 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Ui.width(4)),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              child: ClipRRect(
                borderRadius:
                    new BorderRadius.all(new Radius.circular(Ui.width(4.0))),
                child: CachedNetworkImage(
                    width: Ui.width(702),
                    height: Ui.width(323),
                    fit: BoxFit.fill,
                    imageUrl: '${item['image']}'),
              ),
            ),
            Positioned(
              left: Ui.width(30),
              top: Ui.width(40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${item['num']}',
                    style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: Ui.setFontSizeSetSp(44),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                  ),
                  Text(
                    '${item['label']}',
                    style: TextStyle(
                        color: Color(0XFFFFFFFF),
                        fontSize: Ui.setFontSizeSetSp(32),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PingFangSC-Regular,PingFang SC;'),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: Ui.width(10),
              left: Ui.width(10),
              child: Container(
                width: Ui.width(682),
                decoration: BoxDecoration(
                  color: Color(0XFFFFFFFF),
                  borderRadius: BorderRadius.circular(Ui.width(4)),
                ),
                padding: EdgeInsets.fromLTRB(Ui.width(24), 0, Ui.width(24), 0),
                height: Ui.width(183),
                child: gettopsItemWidget(item['goods']),
              ),
            ),
            Positioned(
              left: Ui.width(36),
              top: Ui.width(110),
              child: Image.asset(
                'images/2.0x/one.png',
                width: Ui.width(58),
                height: Ui.width(63),
              ),
            ),
            Positioned(
              left: Ui.width(247),
              top: Ui.width(110),
              child: Image.asset(
                'images/2.0x/two.png',
                width: Ui.width(58),
                height: Ui.width(63),
              ),
            ),
            Positioned(
              left: Ui.width(459),
              top: Ui.width(110),
              child: Image.asset(
                'images/2.0x/three.png',
                width: Ui.width(58),
                height: Ui.width(63),
              ),
            ),
          ],
        ),
      ));
    }
    content = new Column(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
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
                                            child: Text(' 隐私政策  用户协议',
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
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: Ui.width(300),
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          Ui.width(20)))),
                                          alignment: Alignment.center,
                                          child: Text('拒绝',
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      32.0))),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Storage.setString('agree', 'agree');
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          width: Ui.width(300),
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      bottom: Radius.circular(
                                                          Ui.width(20)))),
                                          child: Text('同意',
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Color(0xFF3895FF),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      32.0))),
                                        ),
                                      )
                                    ],
                                  ),
                                  // child: Container(
                                  //   width: double.infinity,
                                  //   height: double.infinity,
                                  //   alignment: Alignment.center,
                                  //   child: Text('我知道了',
                                  //       style: TextStyle(
                                  //           decoration: TextDecoration.none,
                                  //           color: Color(0xFF3895FF),
                                  //           fontWeight: FontWeight.w400,
                                  //           fontFamily:
                                  //               'PingFangSC-Medium,PingFang SC',
                                  //           fontSize:
                                  //               Ui.setFontSizeSetSp(32.0))),
                                  // )
                                ),
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
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(
                                                  Ui.width(20)))),
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
                            width: Ui.width(750),
                            height: Ui.width(470),
                            child: Swiper(
                              itemBuilder: (BuildContext context, int index) {
//  NORMAL(0, "无"),
//  EXTERNAL(1, "外链"),
//  INTERNAL(2, "内链"),
//  VIDEO(3, "视频"),
//  RICHTEXT(4, "富文本");
                                return InkWell(
                                    onTap: () async {
                                      // TalkingDataAppAnalytics.setGlobalKV('bannner',index+1);
                                      TalkingDataAppAnalytics.onEvent(
                                          eventID: 'bannner',
                                          eventLabel: '轮播图',
                                          params: {"index": index + 1});
                                      // print(banner[index]);
                                      if (banner[index]['type']['value'] == 1) {
                                        Navigator.pushNamed(
                                            context, '/bannerwebview',
                                            arguments: {
                                              "url": banner[index]['link'],
                                              "title": banner[index]['name']
                                            });
                                      } else if (banner[index]['type']
                                              ['value'] ==
                                          3) {
                                        // String url = 'http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4';
                                        // if (await canLaunch(url)) {
                                        //   await launch(url);
                                        // } else {
                                        //   print('不能访问');
                                        // }
                                        Navigator.pushNamed(
                                            context, '/bannervideo',
                                            arguments: {
                                              "url": banner[index]['link'],
                                              "title": banner[index]['name']
                                            });
                                      } else if (banner[index]['type']
                                              ['value'] ==
                                          2) {
                                        Navigator.pushNamed(
                                          context,
                                          '${banner[index]['link']}',
                                        );
                                      }
                                    },
                                    child: Container(
                                        width: Ui.width(750),
                                        height: Ui.width(470),
                                        alignment: Alignment.center,
                                        // decoration: BoxDecoration(
                                        //   image: DecorationImage(
                                        //     image: NetworkImage(
                                        //         '${banner[index]['background']}'),
                                        //     fit: BoxFit.fill,
                                        //   ),
                                        // ),
                                        child: Stack(
                                          children: <Widget>[
                                            CachedNetworkImage(
                                                width: Ui.width(750),
                                                height: Ui.width(470),
                                                fit: BoxFit.fill,
                                                imageUrl:
                                                    '${banner[index]['background']}'),
                                            Container(
                                              width: Ui.width(700),
                                              height: Ui.width(300),
                                              margin: EdgeInsets.fromLTRB(
                                                  Ui.width(25),
                                                  Ui.width(170),
                                                  0,
                                                  0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(
                                                            Ui.width(8.0))),
                                                child: CachedNetworkImage(
                                                    width: Ui.width(700),
                                                    height: Ui.width(300),
                                                    fit: BoxFit.fill,
                                                    imageUrl:
                                                        '${banner[index]["url"]}'),
                                              ),
                                            ),
                                          ],
                                        )));
                              },
                              itemCount: banner.length,
                              autoplay: banner.length > 1 ? true : false,
                              autoplayDelay: 5000,
                              // duration:5000,
                              // autoplayDelay: 5,
                              pagination: SwiperPagination(
                                  alignment: Alignment.bottomCenter,
                                  builder: new SwiperCustomPagination(builder:
                                      (BuildContext context,
                                          SwiperPluginConfig config) {
                                    return new PageIndicator(
                                      layout: PageIndicatorLayout.NIO,
                                      size: 8.0,
                                      space: 15.0,
                                      count: banner.length,
                                      color: Color.fromRGBO(255, 255, 255, 0.4),
                                      activeColor: Color(0XFF111F37),
                                      controller: config.pageController,
                                    );
                                  })),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(24), Ui.width(70), Ui.width(24), 0),
                              child: gettagsWidget()),
                          Container(
                            width: Ui.width(702),
                            constraints: BoxConstraints(
                              minHeight: Ui.width(120),
                            ),
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(24), Ui.width(50), Ui.width(24), 0),
                            padding: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(30)),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Color(0xffEAEAEA)))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    TalkingDataAppAnalytics.onEvent(
                                        eventID: 'store',
                                        eventLabel: '门店',
                                        params: {"name": agent['name']});
                                    Navigator.pushNamed(context, '/store',
                                        arguments: {'store': agent});
                                  },
                                  child: Container(
                                    width: Ui.width(530),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          agent['name'] == null
                                              ? ''
                                              : '${agent['name']}',
                                          style: TextStyle(
                                              color: Color(0XFF111F37),
                                              fontSize: Ui.setFontSizeSetSp(30),
                                              fontWeight: FontWeight.w400,
                                              fontFamily:
                                                  'PingFangSC-Regular,PingFang SC;'),
                                        ),
                                        SizedBox(
                                          height: Ui.width(15),
                                        ),
                                        Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Image.asset(
                                                'images/2.0x/position.png',
                                                width: Ui.width(27),
                                                height: Ui.width(27),
                                              ),
                                              SizedBox(
                                                width: Ui.width(10),
                                              ),
                                              Container(
                                                width: Ui.width(450),
                                                child: Text(
                                                  agent['distance'] == null
                                                      ? ''
                                                      : '${agent['distance']}KM | ${agent['address']}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Color(0XFF9398A5),
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Regular,PingFang SC;'),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () async {
                                        var tel =
                                            await Storage.getString('phone');
                                        var url =
                                            'tel:${tel.replaceAll(' ', '')}';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw '拨打失败';
                                        }
                                      },
                                      child: Container(
                                          margin: EdgeInsets.fromLTRB(
                                              0, Ui.width(15), 0, 0),
                                          width: Ui.width(150),
                                          height: Ui.width(60),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: Ui.width(1),
                                                  color: Color(0XFF111F37))),
                                          child: Text(
                                            '预约咨询',
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontSize:
                                                    Ui.setFontSizeSetSp(26),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Regular,PingFang SC;'),
                                          )),
                                    ))
                              ],
                            ),
                          ),
                          Container(
                            width: Ui.width(702),
                            height: Ui.width(410),
                            margin: EdgeInsets.fromLTRB(
                                Ui.width(24), Ui.width(30), Ui.width(24), 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/special',
                                        arguments: {'id': topics[0]['id']});

                                    //  
                                  },
                                  child: Container(
                                    width: Ui.width(346),
                                    height: Ui.width(410),
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          child: ClipRRect(
                                            borderRadius: new BorderRadius.all(
                                                new Radius.circular(
                                                    Ui.width(4.0))),
                                            child: CachedNetworkImage(
                                                width: Ui.width(346),
                                                height: Ui.width(410),
                                                fit: BoxFit.fill,
                                                imageUrl:
                                                    '${topics[0]['extra']['pic']}'),
                                          ),
                                        ),
                                        Positioned(
                                          left: Ui.width(30),
                                          top: Ui.width(36),
                                          child: Text(
                                            '${topics[0]['label']}',
                                            style: TextStyle(
                                                color: Color(0XFF111F37),
                                                fontSize:
                                                    Ui.setFontSizeSetSp(36),
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    'PingFangSC-Regular,PingFang SC;'),
                                          ),
                                        ),
                                        Positioned(
                                          left: Ui.width(30),
                                          top: Ui.width(88),
                                          child: Text(
                                            '${topics[0]['value']}',
                                            style: TextStyle(
                                                color: Color(0XFF9398A5),
                                                fontSize:
                                                    Ui.setFontSizeSetSp(24),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Regular,PingFang SC;'),
                                          ),
                                        ),
                                        Positioned(
                                          left: Ui.width(26),
                                          top: Ui.width(152),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '￥${topics[0]['extra']['price']}万',
                                                style: TextStyle(
                                                    color: Color(0XFFD10123),
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(30),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Regular,PingFang SC;'),
                                              ),
                                              Text(
                                                '起',
                                                style: TextStyle(
                                                    color: Color(0XFFD10123),
                                                    fontSize:
                                                        Ui.setFontSizeSetSp(24),
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily:
                                                        'PingFangSC-Regular,PingFang SC;'),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                    width: Ui.width(346),
                                    height: Ui.width(410),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/special',
                                                arguments: {
                                                  'id': topics[1]['id']
                                                });
                                            // Navigator.pushNamed(
                                            //     context, '/explosive',
                                            //     arguments: {
                                            //       'id': topics[1]['id'],
                                            //       'title': topics[1]['title'],
                                            //     });
                                          },
                                          child: Container(
                                            width: Ui.width(346),
                                            height: Ui.width(200),
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            new Radius.circular(
                                                                Ui.width(4.0))),
                                                    child: CachedNetworkImage(
                                                        width: Ui.width(346),
                                                        height: Ui.width(200),
                                                        fit: BoxFit.fill,
                                                        imageUrl:
                                                            '${topics[1]['extra']['pic']}'),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: Ui.width(24),
                                                  top: Ui.width(26),
                                                  child: Text(
                                                    '${topics[1]['label']}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0XFF111F37),
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                32),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'PingFangSC-Regular,PingFang SC;'),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: Ui.width(24),
                                                  top: Ui.width(76),
                                                  child: Text(
                                                    '${topics[1]['value']}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0XFF9398A5),
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                20),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Regular,PingFang SC;'),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: Ui.width(20),
                                                  top: Ui.width(124),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        '￥${topics[1]['extra']['price']}万',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0XFFD10123),
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    30),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Regular,PingFang SC;'),
                                                      ),
                                                      Text(
                                                        '起',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0XFFD10123),
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Regular,PingFang SC;'),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/special',
                                                arguments: {
                                                  'id': topics[2]['id']
                                                });
                                            // Navigator.pushNamed(
                                            //     context, '/explosive',
                                            //     arguments: {
                                            //       'id': topics[2]['id'],
                                            //       'title': topics[2]['title'],
                                            //     });
                                          },
                                          child: Container(
                                            width: Ui.width(346),
                                            height: Ui.width(200),
                                            child: Stack(
                                              children: <Widget>[
                                                Container(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            new Radius.circular(
                                                                Ui.width(4.0))),
                                                    child: CachedNetworkImage(
                                                        width: Ui.width(346),
                                                        height: Ui.width(200),
                                                        fit: BoxFit.fill,
                                                        imageUrl:
                                                            '${topics[2]['extra']['pic']}'),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: Ui.width(24),
                                                  top: Ui.width(26),
                                                  child: Text(
                                                    '${topics[2]['label']}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0XFF111F37),
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                32),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            'PingFangSC-Regular,PingFang SC;'),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: Ui.width(24),
                                                  top: Ui.width(76),
                                                  child: Text(
                                                    '${topics[2]['value']}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0XFF9398A5),
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                20),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Regular,PingFang SC;'),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: Ui.width(20),
                                                  top: Ui.width(124),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        '￥${topics[2]['extra']['price']}万',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0XFFD10123),
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    30),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Regular,PingFang SC;'),
                                                      ),
                                                      Text(
                                                        '起',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0XFFD10123),
                                                            fontSize: Ui
                                                                .setFontSizeSetSp(
                                                                    24),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily:
                                                                'PingFangSC-Regular,PingFang SC;'),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Container(
                              width: Ui.width(702),
                              height: Ui.width(140),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(24), Ui.width(30), Ui.width(24), 0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(Ui.width(4)),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  if (await getToken() != null) {
                                    Navigator.pushNamed(context, '/coupon');
                                  } else {
                                    showtosh();
                                  }
                                },
                                child: Container(
                                  width: Ui.width(702),
                                  height: Ui.width(140),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: '${ad['url']}',
                                  ),
                                ),
                              )),
                          Container(
                            child: gettopsWidget(),
                          ),
                          Container(
                            width: Ui.width(702),
                            margin: EdgeInsets.fromLTRB(Ui.width(24),
                                Ui.width(45), Ui.width(24), Ui.width(15)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '精选特卖',
                                  style: TextStyle(
                                      color: Color(0XFF111F37),
                                      fontSize: Ui.setFontSizeSetSp(36),
                                      fontWeight: FontWeight.w500,
                                      fontFamily:
                                          'PingFangSC-Regular,PingFang SC;'),
                                ),
                                Text(
                                  ' / 选品严苛 定位高质',
                                  style: TextStyle(
                                      color: Color(0XFF111F37),
                                      fontSize: Ui.setFontSizeSetSp(24),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Regular,PingFang SC;'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              width: Ui.width(702),
                              margin: EdgeInsets.fromLTRB(
                                  Ui.width(24), 0, Ui.width(24), Ui.width(30)),
                              child: getsalesWidget())
                        ],
                      ),
                    ),
                    Positioned(
                        top: 0,
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
                          ),
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
                                  city == null ? '太原市' : '${city}',
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
                                  // if (await getToken() != null) {
                                  //   Navigator.pushNamed(
                                  //       context, '/tokenwebview',
                                  //       arguments: {'url': 'appquestions'});
                                  // } else {
                                  //   showtosh();
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
                    text: "加载中...",
                  ),
                ),
        ));
  }
}
