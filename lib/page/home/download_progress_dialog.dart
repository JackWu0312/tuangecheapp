import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:install_plugin/install_plugin.dart';
// import 'package:install_apk_plugin/install_apk_plugin.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';

///自定义dialog
///执行下载操作
///显示下载进度
///下载完成后执行安装操作
///[version]新版本的版本号,[url]新版本app下载地址
class DownloadProgressDialog extends StatefulWidget {
  DownloadProgressDialog(this.version, this.url, {Key key}) : super(key: key);

  final String version;
  final String url;

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  //下载进度
  var progress;
  String taskId;
  bool falge=true;
  @override
  void initState() {
    super.initState();
    //初始化下载进度
    progress = '0';

    //开始下载
    var download = executeDownload(widget.url);
    download.then((value) {
      taskId = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    //显示下载进度
    return AlertDialog(
      title: Text('更新中'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(widget.version),
            Text(''),
            Text('下载进度 $progress%'),
          ],
        ),
      ),
      // actions: <Widget>[
      //   FlatButton(
      //     child: Text('取消'),
      //     onPressed: () {
      //       // //取消当前下载
      //       // if(this.taskId != null){
      //       //   BackUpdate().cancelDownload(this.taskId);
      //       // }
      //       // //执行后台下载
      //       // BackUpdate().executeDownload(widget.url);
      //       //关闭下载进度窗口
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ],
    );
  }

  /// 下载
  executeDownload(String url) async {
    Dio dio = Dio();
    final path = await _apkLocalPath();

    // final path ='/storage/emulated/0/Android/data/cn.com.tuangeche.api.flutter_tuangeche/files'+'/release.apk';
//    dio.options.baseUrl = "https://123.sogou.com";
    //设置连接超时时间
    dio.options.connectTimeout = 100000;
    //设置数据接收超时时间
    dio.options.receiveTimeout = 100000;
//    await dio.download(
//        "https://raw.githubusercontent.com/xuelongqy/flutter_easyrefresh/master/art/pkg/EasyRefresh.apk",
//        "/storage/emulated/0/AAAAAA.apk");
    CancelToken cancelToken = CancelToken();
    try {
      await dio.download(url, path + '/release.apk',
          onReceiveProgress: (received, total) {
        if (total != -1) {
          var receiveds = (received / total * 100).toStringAsFixed(0);

          setState(() {
            progress = receiveds;
          });
          print((received / total * 100).toStringAsFixed(0) + "%");
          if (receiveds == '100') {
            if(falge){
              _installApk();
              setState(() {
                falge=false;
              });
            }
          }
        }
      }, cancelToken: cancelToken);
    } catch (e) {
      print(e);
    }
    // Response response = await dio.download(url, path + '/release.apk');
    // var json = response.data;
    // print(json);
    // //  if (json['errno'] == 0 ) {
    // print('艰难困苦');

    // print('下载请求成功');

    // }

    // await FlutterDownloader.initialize();
    // final path = await BackUpdate()._apkLocalPath();
    // print(path);
    // print(url);
    // taskId = await FlutterDownloader.enqueue(
    //     url: url,
    //     // headers: {"auth": "test_for_sql_encoding"},
    //     savedDir: path,
    //     showNotification: true,
    //     openFileFromNotification: true);
    //发起请求
    // final taskId = await FlutterDownloader.enqueue(

    //     url: url,
    //     fileName: 'update.apk',
    //     savedDir: path,
    //     showNotification: false,
    //     openFileFromNotification: false);

    // FlutterDownloader.registerCallback((id, status, progress) {
    //   //更新下载进度
    //   setState(() => this.progress = progress);

    //   // 当下载完成时，调用安装
    //   if (taskId == id && status == DownloadTaskStatus.complete) {
    //     //关闭更新进度框
    //     Navigator.of(context).pop();
    //     //安装下载完的apk
    //     BackUpdate()._installApk();
    //   }
    // });

    // return taskId;
    // }
  }

// ///后台下载
// class BackUpdate{

//   /// 下载
//   Future<void> executeDownload(String url) async {
//     final path = await _apkLocalPath();

//     //发起请求
//     final taskId = await FlutterDownloader.enqueue(
//         url: url,
//         fileName: 'update.apk',
//         savedDir: path,
//         showNotification: true,
//         openFileFromNotification: false);

//     FlutterDownloader.registerCallback((id, status, progress) {
//       //更新下载进度

//       // 当下载完成时，调用安装
//       if (taskId == id && status == DownloadTaskStatus.complete) {
//         //安装下载完的apk
//         _installApk();
//       }
//     });
//   }

  ///取消下载
  // cancelDownload(String taskId) async{
  //   FlutterDownloader.cancel(taskId: taskId);
  // }

  /// 安装
  _installApk() async {
     final path = await _apkLocalPath();
    //  if (path.isEmpty) {
    //   print('make sure the apk file is set');
    //   return;
    // }
    OpenFile.open("${path}/release.apk",type:"application/vnd.android.package-archive",);
    // try {
    //   InstallPlugin.installApk(path + '/release.apk', 'cn.com.tuangeche.api.flutter_tuangeche').then((result) {
    //     print('install apk $result');
    //   }).catchError((error) {
    //     print('install apk error: $error');
    //   });
    // } on PlatformException catch (_) {}
  }

  /// 获取存储路径
  _apkLocalPath() async {
    //获取根目录地址
    final dir = await getExternalStorageDirectory();
    //自定义目录路径(可多级)
    String path = dir.path;
    var directory = await new Directory(path).create(recursive: true);
    return directory.path;
  }
}
