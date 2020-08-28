import 'package:flutter/material.dart';
import '../page/index.dart';
import '../page/more/index.dart';
import '../page/test/index.dart';
import '../page/login/index.dart';
import '../page/mall/integral.dart';
import '../page/mall/record.dart';
import '../page/mall/exchange.dart';
import '../page/mall/commodity.dart';
import '../common/bannerwebview.dart';
import '../common/goodswebview.dart';
import '../page/mall/detailslist.dart';
import '../page/mall/integrallist.dart';
import '../common/tokenwebview.dart';
import '../common/easywebview.dart';
import '../page/mall/payment.dart';
import '../page/mall/paysuccess.dart';
import '../page/mall/goodsdetail.dart';
import '../page/mall/ordercom.dart';
import '../page/mall/goodspayment.dart';
import '../page/mall/addresslist.dart';
import '../page/mall/addressadd.dart';
import '../page/mall/adresseditor.dart';
import '../page/mall/addresslistnew.dart';
import '../page/mall/paysuccessgood.dart';
import '../page/findcar/vehicletype.dart';
import '../page/findcar/cardetail.dart';
import '../page/findcar/carorder.dart';
import '../page/findcar/sure.dart';
import '../page/findcar/paymentcar.dart';
import '../page/user/info.dart';
import '../page/user/modifyname.dart';
import '../page/user/modifyphone.dart';
import '../page/user/modifyphonenew.dart';
import '../page/home/grabble.dart';
import '../page/home/explosive.dart';
import '../page/home/dried.dart';
import '../page/home/danshan.dart';
import '../page/home/hotvideo.dart';
import '../page//home/video.dart';
import '../page/home/danshandtail.dart';
import '../page/home/appointment.dart';
import '../page/home/stage.dart';
import '../page/findcar/findcarpage.dart';
import '../common/driedwebview.dart';
import '../page/user/listorder.dart';
import '../page/home//volume.dart';
import '../page/home/store.dart';
import '../page/user/spell.dart';
import '../page/home/fication.dart';
import '../page/home/special.dart';
import '../page/user/task.dart';
import '../page/user/coupon.dart';
import '../page/user/usecoupon.dart';
import '../page/user/rollbag.dart';
import '../page/mall/goods.dart';
import '../page/mall/ordercomgoods.dart';
import '../page/mall/mallseach.dart';
import '../page/home/bannervideo.dart';
import '../page/user/recommend.dart';
import '../page/user/myrecom.dart';
import '../common/registerwebview.dart';
import '../page/mall/integralrule.dart';
import '../page/mall/shoppingcart.dart';
import '../page/mall/ordernew.dart';
import '../page/findcar/secondhand.dart';
import '../page/mall/shoppingorder.dart';
import '../common/tuanyou.dart';
import '../common/location.dart';
import '../common/conversation.dart';
import '../page/findcar/loan.dart';
import '../common/loanwebview.dart';
import '../common/authentication.dart';
import '../page//user/adopts.dart';
import '../page/user/about.dart';
//配置路由
final routes = {
  '/': (context) => IndexPages(),
  '/video': (context) => ChewieDemo(),
  '/location': (context) => Location(),
  '/conversation': (context) => Conversation(),
  '/loan': (context) => Loan(),
  '/more': (context) => MorePage(),
  '/test': (context) => Testnew(),
  '/login': (context) => LoginPage(),
  '/integral': (context) => Integral(),
  '/record': (context) => Record(),
  '/exchange': (context) => Exchange(),
  '/addresslist': (context) => Addresslist(),
  '/addresslistnew': (context) => Addresslistnew(),
  '/addressadd': (context) => Addressadd(),
  '/paymentcar': (context) => Paymentcar(),
  '/info': (context) => Info(),
  '/grabble': (context) => Grabble(),
  '/modifyphone': (context) => Modifyphone(),
  '/modifyname': (context) => Modifyname(),
  '/dried': (context) => Dried(),
  '/danshan': (context) => Danshan(),
  '/hotvideo': (context) => Hotvideo(),
  '/listorder': (context) => Listorder(),
  '/findcarpage': (context) => Findcarpage(),
  '/volume': (context) => Volume(),
  '/task': (context) => Task(),
  '/coupon': (context) => Coupon(),
  '/rollbag': (context) => Rollbag(),
  '/recommend': (context) => Recommend(),
  '/myrecom': (context) => Myrecom(),
  '/integralrule': (context) => Integralrule(),
  '/shoppingcart': (context) => Shoppingcart(),
  '/secondhand': (context) => Secondhand(),
  '/about': (context) => About(),
  '/adopt': (context,{arguments})  => Adopt(arguments:arguments),
  '/authentication':(context,{arguments}) => Authentication(arguments:arguments),
  '/stage':(context,{arguments}) => Stage(arguments:arguments),
  '/loanwebview':(context,{arguments}) => Loanwebview(arguments:arguments),
  '/shoppingorder':(context,{arguments}) => Shoppingorder(arguments:arguments),
  '/ordernew':(context,{arguments}) => Ordernew(arguments:arguments),
  '/registerwebview':(context,{arguments}) => Registerwebview(arguments:arguments),
  '/mallseach':(context,{arguments}) => Mallseach(arguments:arguments),
  '/usecoupon': (context,{arguments}) => Usecoupon(arguments:arguments),
  '/special':(context,{arguments}) => Special(arguments:arguments),
  '/ification':(context,{arguments}) => Ification(arguments:arguments),
  '/spell': (context,{arguments})  => Spell(arguments:arguments),
  '/bannervideo': (context,{arguments})  => Bannervideo(arguments:arguments),
  '/driedwebview':(context,{arguments}) => Driedwebview(arguments:arguments),
  '/store':(context,{arguments}) => Store(arguments:arguments),
  '/explosive':(context,{arguments}) => Explosive(arguments:arguments),
  '/tokenwebview': (context,{arguments})=> Tokenwebview(arguments:arguments),
  '/easywebview':  (context,{arguments})=> Easywebview(arguments:arguments),
  '/appointment':  (context,{arguments}) => Appointment(arguments:arguments),
  '/modifyphonenew':  (context,{arguments}) => Modifyphonenew(arguments:arguments),
  '/danshandtail':  (context,{arguments}) => Danshandtail(arguments:arguments),
  '/vehicletype':  (context,{arguments}) => Vehicletype(arguments:arguments),
  '/sure':  (context,{arguments}) => Sure(arguments:arguments),
  '/carorder':  (context,{arguments}) => Carorder(arguments:arguments),
  '/cardetail':  (context,{arguments}) => Cardetail(arguments:arguments),
  '/adresseditor': (context,{arguments})=> Adresseditor(arguments:arguments),
  '/paysuccess': (context,{arguments}) => Paysuccess(arguments:arguments),
  '/paysuccessgood': (context,{arguments}) => Paysuccessgood(arguments:arguments),
  '/ordercom': (context,{arguments}) => Ordercom(arguments:arguments),
  '/ordercomgoods': (context,{arguments}) => Ordercomgoods(arguments:arguments),
  '/goodsdetail': (context,{arguments}) => Goodsdetail(arguments:arguments),
  '/goods': (context,{arguments}) => Goods(arguments:arguments),
  '/detailslist': (context,{arguments}) => Detailslist(arguments:arguments),
  '/payment': (context,{arguments}) => Payment(arguments:arguments),
  '/goodspayment': (context,{arguments}) => Goodspayment(arguments:arguments),
  '/integrallist': (context,{arguments}) => Integrallist(arguments:arguments),
  '/bannerwebview': (context,{arguments}) => Bannerwebview(arguments:arguments),
  '/tuanyou': (context,{arguments}) => Tuanyou(arguments:arguments),
  '/goodswebview': (context,{arguments}) => Goodswebview(arguments:arguments),
  '/commodity': (context,{arguments}) => Commodity(arguments:arguments),
};

//固定写法
var onGenerateRoute = (RouteSettings settings) {
// 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
