import 'package:dio/dio.dart';
import '../common/Storage.dart';

class HttpUtlis {
  static String _domain = 'https://api.tuangeche.com.cn/';
//   static String _domain = 'http://192.168.1.51:8080/';
  static getToken() async {
    try {
      String token = await Storage.getString('token');
      return token;
    } catch (e) {
      return '';
    }
  }

  static Dio _dio;
  static BaseOptions _options;
  // =
  //     new BaseOptions(connectTimeout: 5000, receiveTimeout: 3000, headers: {
  //      'Content-Type': 'application/json',
  //   'Wechat-Auth-Token': getToken()
  //  'Wechat-Auth-Token':
  // });

  static getoption() async {
    _options =
        new BaseOptions(connectTimeout: 50000, receiveTimeout: 3000, headers: {
      'Content-Type': 'application/json',
      'Wechat-Auth-Token':await getToken(),
      // 'Wechat-Auth-Token':'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTE4OTc4NTk2NDMyNTUyMzQ1OCwiaWF0IjoxNTczNzg5MDAzLCJwbGF0Zm9ybSI6M30.mBum3vEkVb1n_Rbt_OhDgPvYgksv_e0kYUaabcBQFgc'
    });
  }

  static get(String url, {options, Function success, Function failure}) async {
    await getoption();
    Dio dio = buildDio();
    try {
      Response response = await dio.get(_domain + url, options: options);
      var json = response.data;
      if (json['errno'] == 0 || json['errno'] == 401) {
        success(json);
      } else {
        failure(json['errmsg']);
      }
    } catch (exception) {
      print(exception);
    }
  }

  static post(String url,
      {params, options, Function success, Function failure}) async {
    await getoption();
    Dio dio = buildDio();
    try {
      Response response =
          await dio.post(_domain + url, data: params, options: options);
      var json = response.data;
      if (json['errno'] == 0 || json['errno'] == 401) {
        success(json);
      } else {
        failure(json['errmsg']);
      }
      // success(response.data);
    } catch (exception) {
      failure(exception);
    }
  }

  static Dio buildDio() {
    // if (_dio == null) {
    _dio = new Dio(_options);
    // Dio dio = new Dio();
    //    
    // }
    return _dio;
  }
}
