
import 'dart:ui';

import 'package:flutter_tuangeche/ui/ui.dart';
import 'package:toast/toast.dart';

import 'index.dart';

class HttpHelper{
  /// title 浏览数据标题 dataId 浏览数据ID type 4软文、5视频
  static saveFootprint(title,dataId,type,context) {
    HttpUtlis.post("wx/user/saveFootprint",
        params: {'title': title, 'dataId': dataId, 'type': type},
        success: (value) async {
          if (value['errno'] == 0) {
            //任务数据刷新
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