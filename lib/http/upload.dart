// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';

// class ShopPaperImgDao {
//   // 上传图片
//   static Future uploadImg(imgfile) async{
//     String path = imgfile.path;
//     var name = path.substring(path.lastIndexOf("/") + 1, path.length);
//     FormData formData = new FormData.from({
//       "file": await MultipartFile.fromFile(imgfile,filename: "upload.png"),
//     });
//     Response response;
//     Dio dio =new Dio();
//     response =await dio.post('后端接口',data: formData);
//     if(response.statusCode == 200){
//       return response.data;
//     }else{
//       throw Exception('后端接口异常');
//     }
//   }
// }