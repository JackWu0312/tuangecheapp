import 'package:flutter/material.dart';
import './common/NoSplash.dart';
import './router/router.dart';
import 'dart:io'; //提供Platform接口
import 'package:flutter/services.dart';
// import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:provider/provider.dart';
import 'provider/Successlogin.dart';
import 'provider/Addreslist.dart';
import 'provider/Addressselect.dart';
import 'provider/IsInfo.dart';
import 'provider/Iswechat.dart';
import 'provider/Backhome.dart';
import 'provider/Rollbag.dart';
import 'provider/Taskback.dart';
import 'provider/Backshare.dart';
import 'provider/Lovecar.dart';
import 'provider/Carnum.dart';
import 'provider/JumpToPage.dart';
import 'provider/Integral.dart';
import 'provider/Adopts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

// import 'dart:io';
// import 'package:amap_location/amap_location.dart';
// import 'package:flutter_amap_plugin/flutter_amap_plugin.dart';
// import 'package:amap_base/amap_base.dart';

import 'package:amap_location/amap_location.dart';

void main() async {
  runApp(MyApp());

  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前       MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String debugLable = 'Unknown';
  final JPush jpush = new JPush();

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      // AMap.init('810afd6d200f01c90313503cdeb5130e');
      // FlutterAmapPlugin.initAMapIOSKey('810afd6d200f01c90313503cdeb5130e');
      AMapLocationClient.setApiKey("810afd6d200f01c90313503cdeb5130e");
      //ios相关代码
    }
    if (Platform.isAndroid) {
      // requestPermiss();
    }
    // getamap();
  }
  // getamap()async{
  //   await AMapLocationClient.startup(new AMapLocationOption(
  //   desiredAccuracy: CLLocationAccuracy.kCLLocationAccuracyHundredMeters));

  // }

  requestPermiss() async {
    //请求权限
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions(
            [PermissionGroup.location, PermissionGroup.camera]);
    //校验权限
    // if(permissions[PermissionGroup.camera] != PermissionStatus.granted){
    //   print("无照相权限");
    // }
    if (permissions[PermissionGroup.location] != PermissionStatus.granted) {
      bool isOpened = await PermissionHandler().openAppSettings();
      print(isOpened);
    }
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
            print("flutter onReceiveNotification: $message");
              debugLable = "flutter onReceiveNotification: $message";
          }, onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
          debugLable = "flutter onOpenNotification: $message";
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
          debugLable = "flutter onReceiveMessage: $message";
      }, onReceiveNotificationAuthorization:
          (Map<String, dynamic> message) async {
        print("flutter onReceiveNotificationAuthorization: $message");
          debugLable = "flutter onReceiveNotificationAuthorization: $message";
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    jpush.setup(
      appKey: "31aff563efb07f649fbcf83a", //你自己应用的 AppKey
      channel: "developer-default",
      production: false,
      debug: true,
    );
    if(Platform.isIOS) {
      jpush.applyPushAuthority(
          new NotificationSettingsIOS(sound: true, alert: true, badge: true));
    }

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      print("flutter get registration id : $rid");
        debugLable = "flutter getRegistrationID: $rid";
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    debugLable = platformVersion;
    print("flutter debugLable: $debugLable");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Successlogin()),
        ChangeNotifierProvider(create: (_) => Addreslist()),
        ChangeNotifierProvider(create: (_) => Addressselect()),
        ChangeNotifierProvider(create: (_) => IsInfo()),
        ChangeNotifierProvider(create: (_) => Backhome()),
        ChangeNotifierProvider(create: (_) => Iswechat()),
        ChangeNotifierProvider(create: (_) => Rollbag()),
        ChangeNotifierProvider(create: (_) => Taskback()),
        ChangeNotifierProvider(create: (_) => Lovecar()),
        ChangeNotifierProvider(create: (_) => Backshare()),
        ChangeNotifierProvider(create: (_) => Carnum()),
        ChangeNotifierProvider(create: (_) => JumpToPage()),
        ChangeNotifierProvider(create: (_) => Integral()),
        ChangeNotifierProvider(create: (_) => Adopts()),
      ],
      child: MaterialApp(
        // home: Tabs(),
        title: '团个车',
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: onGenerateRoute,
        theme: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            splashFactory: const NoSplashFactory(),
            // primaryColor: Color(0XFFFFFFFF),
            platform: TargetPlatform.iOS,
            primaryColor: Colors.white),
      ),
    );
  }
}
