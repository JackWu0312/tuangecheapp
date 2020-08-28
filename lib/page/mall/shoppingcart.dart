import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import '../../common/Nofind.dart';
import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../provider/Carnum.dart';
import 'package:provider/provider.dart';

class Shoppingcart extends StatefulWidget {
  Shoppingcart({Key key}) : super(key: key);

  @override
  _ShoppingcartState createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  // var _initKeywordsController = new TextEditingController();
  int style = 1; //1 ios 2安卓
  List list = [];
  int type = 1;
  bool isall = false;
  var allSelect = 0;
  var money = 0.0;
  var specifications;
  var data;
  var productsgoods;
  var listAllimage;
  var price;
  var stringnum;
  var picUrl;
  var limit;
  var goodIds;
  var objkey;
  bool isloading = false;
  String nums = '1';
  var adress;
  var _initKeywordsController = new TextEditingController();
  final SlidableController slidableController = SlidableController();
  // _showSnackBar(String val, int idx) {
  //   setState(() {
  //     list.removeAt(idx);
  //   });
  // }

  // _showSnack(BuildContext context, type) {
  //   print(type);
  // }

  @override
  void initState() {
    super.initState();
    this._initKeywordsController.text = nums;
    getData();
    getAdress();
    getstyle();
    // this._initKeywordsController.text = '1';
  }

  getAdress() async {
    await HttpUtlis.get('wx/address/default', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          adress = value['data'];
        });
        // if (adress != null) {
        //   counter.increment(adress);
        // }
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  allmoney(id) async {
    if (id != '') {
      await HttpUtlis.get('wx/cart/calculate/${id}', success: (value) {
        if (value['errno'] == 0) {
          setState(() {
            money = value['data']['price'];
          });
        }
      }, failure: (error) {
        Toast.show('${error}', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      });
    } else {
      setState(() {
        money = 0.0;
      });
    }
  }

  getData() async {
    await HttpUtlis.get('wx/cart/list?page=1&limit=1000000000',
        success: (value) {
      if (value['errno'] == 0) {
        var listall = value['data']['list'];
        for (var i = 0, len = listall.length; i < len; i++) {
          listall[i]['stringnum'] = '';
          var keylist = [];
          for (var key in value['data']['list'][i]['specifications'].keys) {
            keylist.add(key);
          }
          value['data']['list'][i]['specifications'].forEach((key, value) {
            if (keylist.length > 1) {
              listall[i]['stringnum'] = value + '/${listall[i]['stringnum']}';
            } else {
              listall[i]['stringnum'] = value + '${listall[i]['stringnum']}';
            }
          });
          if (keylist.length > 1) {
            listall[i]['stringnum'] = listall[i]['stringnum']
                .substring(0, listall[i]['stringnum'].length - 1);
          }
        }
        setState(() {
          list = listall;
          isall = false;
        });
        getids();
        allmoney(getids());
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
    setState(() {
      isloading = true;
    });
  }

  getstyle() {
    if (Platform.isIOS) {
      setState(() {
        style = 1;
      });
    } else if (Platform.isAndroid) {
      setState(() {
        style = 2;
      });
    }
  }

  getcount(carnum) async {
    await HttpUtlis.get('wx/cart/count', success: (value) {
      if (value['errno'] == 0) {
        if (value['data']['count'] != null) {
          setState(() {
            carnum.increment(value['data']['count']);
          });
        } else {
          setState(() {
            carnum.increment(0);
          });
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

  shpingcar(id, productId, number, carnum) async {
    await HttpUtlis.post('wx/cart/save',
        params: {'id': id, 'productId': productId, 'number': number},
        success: (value) {
      // print(value);
      if (value['errno'] == 0) {
        setState(() {
          // isall=false;
          carnum.increment(value['data']['count']);
          // getData();
          allmoney(getids());
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

  dele(id, carnum) async {
    await HttpUtlis.post('wx/cart/delete/${id}', success: (value) {
      // print(value);
      if (value['errno'] == 0) {
        setState(() {
          isall = false;
        });
        getcount(carnum);
        getData();
        Toast.show('删除成功～', context,
            backgroundColor: Color(0xff5b5956),
            backgroundRadius: Ui.width(16),
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.CENTER);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  reset(type) {
    for (var i = 0, len = list.length; i < len; i++) {
      type == 1 ? list[i]['checked'] = false : list[i]['checked'] = true;
    }
  }

  isselectall() {
    var flage = true;
    for (var i = 0, len = list.length; i < len; i++) {
      if (list[i]['checked'] == false) {
        flage = false;
        break;
      }
    }
    flage
        ? setState(() {
            isall = true;
          })
        : setState(() {
            isall = false;
          });
  }

  getids() {
    var arr = '';
    var isselect = [];
    for (var i = 0, len = list.length; i < len; i++) {
      if (list[i]['checked']) {
        arr = arr + ',' + list[i]['id'];
        isselect.add(list[i]['id']);
      }
    }
    setState(() {
      allSelect = isselect.length;
    });
    // print(allSelect);
    if (isselect.length > 0) {
      return arr.substring(1, arr.length);
    } else {
      return '';
    }
  }

  getdom(setBottomState) {
    List<Widget> list = [];
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    specifications.forEach((key, value) {
      list.add(Container(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              Ui.width(0), Ui.width(0), Ui.width(0), Ui.width(50)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, Ui.width(20)),
                child: Text(
                  '${key}',
                  style: TextStyle(
                      color: Color(0xFF111F37),
                      fontWeight: FontWeight.w400,
                      fontFamily: 'PingFangSC-Medium,PingFang SC',
                      fontSize: Ui.setFontSizeSetSp(28.0)),
                ),
              ),
              Container(child: getchilddome(value, key, setBottomState))
            ],
          ),
        ),
      ));
    });
    content = new Column(
      children: list,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
    return content;
  }

  getchilddome(value, key, setBottomState) {
    List<Widget> tiles = []; //先建一个数组用于存放循环生成的widget
    Widget content; //单独一个widget组件，用于返回需要生成的内容widget
    for (int i = 0, len = value.length; i < len; i++) {
      tiles.add(InkWell(
          onTap: () {
            var data = specifications;
            for (int j = 0; j < data['${key}'].length; j++) {
              data['${key}'][j]['isSelect'] = false;
              data['${key}'][i]['isSelect'] = true;
            }
            getgoodIds();
            setBottomState(() {
              specifications = data;
            });
          },
          child: Container(
            // width: Ui.width(150),
            constraints: BoxConstraints(
              minWidth: Ui.width(150),
            ),
            // height: Ui.width(50),
            padding: EdgeInsets.fromLTRB(
                Ui.width(15), Ui.width(10), Ui.width(15), Ui.width(10)),
            // margin: EdgeInsets.fromLTRB(0, 0, Ui.width(20), 0),
            // alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  value[i]['isSelect'] ? Color(0xFFFFF4F6) : Color(0xFFF5F5F5),
              border: Border.all(
                  width: Ui.width(1),
                  color: value[i]['isSelect']
                      ? Color(0xFFD10123)
                      : Color(0xFFF5F5F5)),
            ),
            child: Text(
              '${value[i]['value']}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: value[i]['isSelect']
                      ? Color(0xFFD10123)
                      : Color(0xFF5E6578),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'PingFangSC-Medium,PingFang SC',
                  fontSize: Ui.setFontSizeSetSp(24.0)),
            ),
          )));
    }
    content = new Wrap(
      children: tiles,
      spacing: Ui.width(20),
      runSpacing: Ui.width(30),
    );
    return content;
  }

  getgoodIds() {
    var data = specifications;
    // var strings = '';
    var obj = {};
    for (var key in data.keys) {
      for (var s = 0; s < data['${key}'].length; s++) {
        if (data['${key}'][s]['isSelect']) {
          obj['${key}'] = data['${key}'][s]['value'];
        }
      }
    }
    // print(obj.toString());
    var keylist = [];
    for (var key in obj.keys) {
      keylist.add(key);
    }
    setState(() {
      objkey = obj;
    });
    stringnum = '';
    objkey.forEach((key, value) {
      if (keylist.length > 1) {
        stringnum = value + '/${stringnum}';
      } else {
        stringnum = value + '${stringnum}';
      }
    });
    if (keylist.length > 1) {
      stringnum = stringnum.substring(0, stringnum.length - 1);
    }
    // for (var key in obj.keys) {
    for (var w = 0, len = productsgoods.length; w < len; w++) {
      var flage = false;
      for (var i = 0; i < keylist.length; i++) {
        if (productsgoods[w]['specifications']['${keylist[i]}'] ==
            obj['${keylist[i]}']) {
          flage = true;
        } else {
          flage = false;
          break;
        }
      }
      if (flage) {
        setState(() {
          goodIds = productsgoods[w]['id'];
          price = productsgoods[w]['price'];
          // retailPrice = productsgoods[w]['price'];
          picUrl = productsgoods[w]['picUrl'];
          limit = productsgoods[w]['limit'];
        });
      }
    }
    // print(goodIds);
    // }
  }

  getDataid(id, commodityBottomSheet, carnum, carid) async {
    await HttpUtlis.get('wx/goods/${id}', success: (value) {
      if (value['errno'] == 0) {
        var datas = value['data']['specifications'];
        if (json.encode(value['data']['specifications']) != '{}') {
          for (var key in datas.keys) {
            for (int i = 0, len = datas['${key}'].length; i < len; i++) {
              if (i == 0) {
                datas['${key}'][i]['isSelect'] = true;
              } else {
                datas['${key}'][i]['isSelect'] = false;
              }
            }
          }
        }
        setState(() {
          listAllimage = value['data']['goods']['gallery'];
          data = value['data'];
          specifications = datas;
          productsgoods = value['data']['products'];
          // retailPrice = data['goods']['retailPrice'];
        });
        if (json.encode(value['data']['specifications']) != '{}') {
          getgoodIds();
          // setState(() {
          //   price = value['data']['products'][0]['price'];
          // });
        } else {
          setState(() {
            goodIds = value['data']['products'][0]['id'];
            price = value['data']['products'][0]['price'];
            //   retailPrice = value['data']['products'][0]['price'];
            picUrl = value['data']['products'][0]['picUrl'];
            limit = value['data']['products'][0]['limit'];
          });
          setState(() {
            objkey = {};
            stringnum = '';
          });
        }
        commodityBottomSheet(carnum, carid);
        //  print(goodIds);
      }
    }, failure: (error) {
      Toast.show('${error}', context,
          backgroundColor: Color(0xff5b5956),
          backgroundRadius: Ui.width(16),
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.CENTER);
    });
  }

  @override
  Widget build(BuildContext context) {
    final carnum = Provider.of<Carnum>(context);
    //商品选择弹窗
    commodityBottomSheet(carnum, id) {
      //type 1 加入购物车 2 立即购买
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (contex) {
            return StatefulBuilder(
              builder: (BuildContext context, setBottomState) {
                return GestureDetector(
                  //解决showModalBottomSheet点击消失的问题
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    return false;
                  },
                  child: Container(
                    height: Ui.width(900) +
                        MediaQuery.of(context).viewInsets.bottom,
                    color: Color(0xFFFFFFFF),
                    width: Ui.width(750),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(24), 0, Ui.width(24), 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  padding: EdgeInsets.fromLTRB(
                                      0, Ui.width(30), 0, Ui.width(30)),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              width: 1,
                                              color: Color(0xffEAEAEA)))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: Ui.width(245),
                                        height: Ui.width(245),
                                        child: CachedNetworkImage(
                                            width: Ui.width(390),
                                            height: Ui.width(220),
                                            fit: BoxFit.fill,
                                            imageUrl: picUrl != null
                                                ? '${picUrl}'
                                                : '${listAllimage[0]}'),
                                        // decoration: BoxDecoration(
                                        //     image: DecorationImage(
                                        //         fit: BoxFit.fill,
                                        //         image: NetworkImage(picUrl !=
                                        //                 null
                                        //             ? '${picUrl}'
                                        //             : '${listAllimage[0]}'))),
                                      ),
                                      SizedBox(
                                        width: Ui.width(30),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: Ui.width(65),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      '${price}',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFD10123),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  42.0)),
                                                    ),
                                                    SizedBox(
                                                      width: Ui.width(3),
                                                    ),
                                                    Text(
                                                      '元',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFD10123),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  24.0)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: Ui.width(10),
                                              ),
                                              Container(
                                                child: Text(
                                                  '${data['goods']['counterPrice']}元',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color: Color(0xFF9398A5),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: Ui.width(40),
                                              ),
                                              Container(
                                                child: Text(
                                                  '${stringnum}',
                                                  style: TextStyle(
                                                      color: Color(0xFF111F37),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              28.0)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )),
                              Container(
                                width: Ui.width(702),
                                height: Ui.width(470),
                                child: ListView(
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0, Ui.width(40), 0, 0),
                                        child: getdom(setBottomState)),
                                    Container(
                                      child: Text(
                                        '购买数量',
                                        style: TextStyle(
                                            color: Color(0xFF111F37),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(28.0)),
                                      ),
                                    ),
                                    SizedBox(
                                      height: Ui.width(10),
                                    ),
                                    Container(
                                      width: Ui.width(702),
                                      // padding: EdgeInsets.fromLTRB(
                                      //     Ui.width(40), 0, Ui.width(45), 0),
                                      // margin: EdgeInsets.fromLTRB(0, Ui.width(185), 0, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              '数量:',
                                              style: TextStyle(
                                                  color: Color(0xFF111F37),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      'PingFangSC-Medium,PingFang SC',
                                                  fontSize: Ui.setFontSizeSetSp(
                                                      26.0)),
                                            ),
                                          ),
                                          Container(
                                            // width: Ui.width(750),
                                            height: Ui.width(56),
                                            // margin:
                                            //     EdgeInsets.fromLTRB(0, Ui.width(110), 0, 0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  limit == 0
                                                      ? '不限购'
                                                      : '限购${limit}件',
                                                  style: TextStyle(
                                                      color: Color(0xFFD10123),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'PingFangSC-Medium,PingFang SC',
                                                      fontSize:
                                                          Ui.setFontSizeSetSp(
                                                              24.0)),
                                                ),
                                                SizedBox(
                                                  width: Ui.width(30),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    if (int.parse(nums) > 1) {
                                                      setBottomState(() {
                                                        nums =
                                                            (int.parse(nums) -
                                                                    1)
                                                                .toString();
                                                      });
                                                    } else {
                                                      setBottomState(() {
                                                        nums = '1';
                                                      });
                                                    }
                                                    setBottomState(() {
                                                      _initKeywordsController
                                                          .text = nums;
                                                    });
                                                    // calculate(setBottomState);
                                                  },
                                                  child: Container(
                                                    width: Ui.width(35),
                                                    height: Ui.width(35),
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: Ui.width(35),
                                                      height: Ui.width(3),
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                  'images/2.0x/reduce.png'))),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    width: Ui.width(100),
                                                    height: Ui.width(60),
                                                    color: Color(0xFFF4F4F4),
                                                    alignment: Alignment.center,
                                                    margin: EdgeInsets.fromLTRB(
                                                        Ui.width(27),
                                                        0,
                                                        Ui.width(27),
                                                        0),
                                                    child: TextField(
                                                      controller:
                                                          TextEditingController
                                                              .fromValue(
                                                        TextEditingValue(
                                                            // 设置内容
                                                            text:
                                                                _initKeywordsController
                                                                    .text,
                                                            // 保持光标在最后
                                                            selection: TextSelection.fromPosition(TextPosition(
                                                                affinity:
                                                                    TextAffinity
                                                                        .downstream,
                                                                offset:
                                                                    _initKeywordsController
                                                                        .text
                                                                        .length))),
                                                      ),

                                                      // controller: this._initKeywordsController,
                                                      autofocus: false,
                                                      textAlign:
                                                          TextAlign.center,
                                                      keyboardAppearance:
                                                          Brightness.light,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0XFF111F37),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  32)),
                                                      decoration: InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          contentPadding:
                                                              EdgeInsets.fromLTRB(
                                                                  0,
                                                                  Ui.width(16),
                                                                  0,
                                                                  style == 1
                                                                      ? Ui.width(
                                                                          26)
                                                                      : Ui.width(
                                                                          30))),
                                                      onChanged: (value) {
                                                        if (int.parse(value) <
                                                            1) {
                                                          setBottomState(() {
                                                            nums = '1';
                                                          });
                                                          Toast.show(
                                                              "数量不能低于1哦～",
                                                              context,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xff5b5956),
                                                              backgroundRadius:
                                                                  Ui.width(8),
                                                              duration: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  Toast.CENTER);
                                                          // Toast(context,msg:'数量不能低于1哦～');
                                                        } else if (int.parse(
                                                                    value) >
                                                                limit &&
                                                            limit != 0) {
                                                          setBottomState(() {
                                                            nums = limit
                                                                .toString();
                                                          });
                                                          // Toast.info(`超过限购数量哦～`);
                                                          Toast.show("超过限购数量哦～",
                                                              context,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xff5b5956),
                                                              backgroundRadius:
                                                                  Ui.width(8),
                                                              duration: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  Toast.CENTER);
                                                        } else if (value ==
                                                            '') {
                                                          setBottomState(() {
                                                            nums = '1';
                                                          });
                                                        } else {
                                                          setBottomState(() {
                                                            nums = value;
                                                          });
                                                        }
                                                        // if (1 <= int.parse(value)) {
                                                        //   setBottomState(() {
                                                        //     nums = value;
                                                        //   });
                                                        // } else {
                                                        //   setBottomState(() {
                                                        //     nums = '1';
                                                        //   });
                                                        // }
                                                        setBottomState(() {
                                                          _initKeywordsController
                                                              .text = nums;
                                                        });
                                                        // this.calculate(
                                                        //     setBottomState);
                                                      },
                                                    )),
                                                InkWell(
                                                  onTap: () {
                                                    if (int.parse(nums) >=
                                                            limit &&
                                                        limit != 0) {
                                                      setBottomState(() {
                                                        nums = limit.toString();
                                                      });
                                                    } else {
                                                      setBottomState(() {
                                                        nums =
                                                            (int.parse(nums) +
                                                                    1)
                                                                .toString();
                                                      });
                                                    }
                                                    setBottomState(() {
                                                      _initKeywordsController
                                                          .text = nums;
                                                    });

                                                    // calculate(setBottomState);
                                                  },
                                                  child: Container(
                                                    width: Ui.width(35),
                                                    height: Ui.width(35),
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                                'images/2.0x/add.png'))),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            top: Ui.width(30),
                            right: Ui.width(24),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset(
                                'images/2.0x/clonse.png',
                                width: Ui.width(32),
                                height: Ui.width(32),
                              ),
                            )),
                        Positioned(
                            bottom: Ui.width(20),
                            left: Ui.width(24),
                            child: InkWell(
                              onTap: () async {
                                await shpingcar(id, goodIds, nums, carnum);
                                await getData();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: Ui.width(702),
                                height: Ui.width(76),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Ui.width(8.0))),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFFEA4802),
                                      Color(0xFFD10123),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  '确定',
                                  style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(32.0)),
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                );
              },
            );
          });
    }

    Ui.init(context);
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(
                '购物车',
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
              actions: <Widget>[
                InkWell(
                    onTap: () async {
                      reset(1);
                      allmoney(getids());
                      // getids();
                      setState(() {
                        isall = false;
                        type = type == 1 ? 2 : 1;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(0, 0, Ui.width(40), 0),
                      child: Text(
                        type == 1 ? '编辑' : '完成',
                        style: TextStyle(
                            color: Color(0xFF111F37),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'PingFangSC-Medium,PingFang SC',
                            fontSize: Ui.setFontSizeSetSp(28.0)),
                      ),
                    ))
              ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: Color(0xFFF8F9FB),
              child: isloading
                  ? Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              Ui.width(24), 0, Ui.width(24), 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: Ui.width(750),
                                padding: EdgeInsets.fromLTRB(
                                    0, Ui.width(30), 0, Ui.width(30)),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  adress != null
                                      ? '共${list.length}件宝贝    收货地址：${adress['fullAddress']}'
                                      : '共${list.length}件宝贝    暂无收货地址',
                                  style: TextStyle(
                                      color: Color(0xFF5E6578),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(26.0)),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: list.length > 0
                                    ? Container(
                                        padding: EdgeInsets.fromLTRB(
                                            0, 0, 0, Ui.width(130)),
                                        child: ListView.builder(
                                          itemCount: list.length,
                                          itemBuilder: (context, index) {
                                            var initKeywordsController =
                                                new TextEditingController();
                                            initKeywordsController.text =
                                                list[index]['number']
                                                    .toString();
                                            return Slidable(
                                              key: Key(list[index]['id']),
                                              controller: slidableController,
                                              actionPane:
                                                  SlidableStrechActionPane(), // 侧滑菜单出现方式 SlidableScrollActionPane SlidableDrawerActionPane SlidableStrechActionPane
                                              actionExtentRatio:
                                                  0.20, // 侧滑按钮所占的宽度
                                              enabled: true, // 是否启用侧滑 默认启用
                                              dismissal: SlidableDismissal(
                                                child:
                                                    SlidableDrawerDismissal(),
                                                onDismissed: (actionType) {
                                                  print('黄瓜大傻逼');
                                                  dele(list[index]['id'],
                                                      carnum);
                                                  setState(() {
                                                    list.removeAt(index);
                                                  });
                                                  // _showSnack(
                                                  //     context,
                                                  //     actionType == SlideActionType.primary
                                                  //         ? 'Dismiss Archive'
                                                  //         : 'Dimiss Delete');
                                                  // setState(() {
                                                  //   list.removeAt(0);
                                                  // });
                                                },
                                                onWillDismiss: (actionType) {
                                                  return showDialog<bool>(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text('删除'),
                                                        content: Text('确定是否删除'),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('取消'),
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(false),
                                                          ),
                                                          FlatButton(
                                                            child: Text('确定'),
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),

                                              child: Container(
                                                  width: Ui.width(702),
                                                  height: Ui.width(280),
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 0, 0, Ui.width(20)),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFFFFFFF),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                Ui.width(8))),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        width: double.infinity,
                                                        height: Ui.width(210),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                Ui.width(20),
                                                                Ui.width(30),
                                                                Ui.width(25),
                                                                0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  list[index][
                                                                      'checked'] = !list[
                                                                          index]
                                                                      [
                                                                      'checked'];
                                                                });
                                                                isselectall();
                                                                // getids();
                                                                allmoney(
                                                                    getids());
                                                              },
                                                              child: Container(
                                                                width: Ui.width(
                                                                    38),
                                                                height:
                                                                    Ui.width(
                                                                        30),
                                                                child: Image.asset(
                                                                    list[index]
                                                                            [
                                                                            'checked']
                                                                        ? 'images/2.0x/select.png'
                                                                        : 'images/2.0x/unselect.png',
                                                                    width: Ui
                                                                        .width(
                                                                            38),
                                                                    height: Ui
                                                                        .width(
                                                                            38)),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  Ui.width(20),
                                                            ),
                                                            Container(
                                                              width:
                                                                  Ui.width(180),
                                                              height:
                                                                  Ui.width(180),
                                                              child: CachedNetworkImage(
                                                                  width:
                                                                      Ui.width(
                                                                          180),
                                                                  height:
                                                                      Ui.width(
                                                                          180),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  imageUrl:
                                                                      '${list[index]['picUrl']}'),
                                                              // decoration: BoxDecoration(
                                                              //     image: DecorationImage(
                                                              //         fit: BoxFit
                                                              //             .fill,
                                                              //         image: NetworkImage(
                                                              //             '${list[index]['picUrl']}'))),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  Ui.width(30),
                                                            ),
                                                            Container(
                                                              height:
                                                                  Ui.width(190),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Container(
                                                                    width: Ui
                                                                        .width(
                                                                            385),
                                                                    child: Text(
                                                                      '${list[index]['goodsName']}',
                                                                      maxLines:
                                                                          3,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          color: Color(
                                                                              0xFF111F37),
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          fontFamily:
                                                                              'PingFangSC-Medium,PingFang SC',
                                                                          fontSize:
                                                                              Ui.setFontSizeSetSp(28.0)),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                      onTap:
                                                                          () {
                                                                        getDataid(
                                                                            list[index]['goodsId'],
                                                                            commodityBottomSheet,
                                                                            carnum,
                                                                            list[index]['id']);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          Ui.width(
                                                                              10),
                                                                        ),
                                                                        height:
                                                                            Ui.width(45),
                                                                        color: Color(
                                                                            0xFFF5F5F5),
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            Ui.width(25),
                                                                            0,
                                                                            Ui.width(25),
                                                                            0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            Text(
                                                                              '${list[index]['stringnum']}',
                                                                              style: TextStyle(color: Color(0xFF9398A5), fontWeight: FontWeight.w400, fontFamily: 'PingFangSC-Medium,PingFang SC', fontSize: Ui.setFontSizeSetSp(24.0)),
                                                                            ),
                                                                            SizedBox(
                                                                              width: Ui.width(26),
                                                                            ),
                                                                            Image.asset('images/2.0x/btm.png',
                                                                                width: Ui.width(20),
                                                                                height: Ui.width(12))
                                                                          ],
                                                                        ),
                                                                      ))
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                Ui.width(288),
                                                                0,
                                                                Ui.width(20),
                                                                0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                              child: Text(
                                                                '￥${list[index]['price']}',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFFD10123),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontFamily:
                                                                        'PingFangSC-Medium,PingFang SC',
                                                                    fontSize: Ui
                                                                        .setFontSizeSetSp(
                                                                            26.0)),
                                                              ),
                                                            ),
                                                            Container(
                                                              height:
                                                                  Ui.width(56),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (list[index]
                                                                              [
                                                                              'number'] >
                                                                          1) {
                                                                        setState(
                                                                            () {
                                                                          list[index]
                                                                              [
                                                                              'number'] = (list[index]
                                                                                  ['number'] -
                                                                              1);
                                                                          shpingcar(
                                                                              list[index]['id'],
                                                                              list[index]['productId'],
                                                                              list[index]['number'],
                                                                              carnum);
                                                                        });
                                                                        //  allmoney(getids());
                                                                      } else {
                                                                        Toast.show(
                                                                            "数量不能低于1哦～",
                                                                            context,
                                                                            backgroundColor:
                                                                                Color(0xff5b5956),
                                                                            backgroundRadius: Ui.width(8),
                                                                            duration: Toast.LENGTH_SHORT,
                                                                            gravity: Toast.CENTER);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: Ui
                                                                          .width(
                                                                              25),
                                                                      height: Ui
                                                                          .width(
                                                                              25),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Container(
                                                                        width: Ui.width(
                                                                            35),
                                                                        height:
                                                                            Ui.width(3),
                                                                        decoration:
                                                                            BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: AssetImage('images/2.0x/reduce.png'))),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                      width: Ui
                                                                          .width(
                                                                              66),
                                                                      height: Ui
                                                                          .width(
                                                                              40),
                                                                      color: Color(
                                                                          0xFFF4F4F4),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      margin: EdgeInsets.fromLTRB(
                                                                          Ui.width(
                                                                              20),
                                                                          0,
                                                                          Ui.width(
                                                                              20),
                                                                          0),
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            TextEditingController.fromValue(
                                                                          TextEditingValue(
                                                                              // 设置内容
                                                                              text: initKeywordsController.text,
                                                                              // 保持光标在最后
                                                                              selection: TextSelection.fromPosition(TextPosition(affinity: TextAffinity.downstream, offset: initKeywordsController.text.length))),
                                                                        ),
                                                                        autofocus:
                                                                            false,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        keyboardAppearance:
                                                                            Brightness.light,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Color(0XFF111F37),
                                                                            fontWeight: FontWeight.w400,
                                                                            fontSize: Ui.setFontSizeSetSp(24)),
                                                                        decoration: InputDecoration(
                                                                            border: InputBorder
                                                                                .none,
                                                                            contentPadding: EdgeInsets.fromLTRB(
                                                                                Ui.width(3),
                                                                                Ui.width(16),
                                                                                0,
                                                                                style == 1 ? Ui.width(23) : Ui.width(30))),
                                                                        onChanged:
                                                                            (value) {
                                                                          if (int.parse(value) <
                                                                              1) {
                                                                            setState(() {
                                                                              list[index]['number'] = 1;
                                                                            });
                                                                            Toast.show("数量不能低于1哦～",
                                                                                context,
                                                                                backgroundColor: Color(0xff5b5956),
                                                                                backgroundRadius: Ui.width(8),
                                                                                duration: Toast.LENGTH_SHORT,
                                                                                gravity: Toast.CENTER);
                                                                          } else if (int.parse(value) > list[index]['limit'] &&
                                                                              list[index]['limit'] != 0) {
                                                                            Toast.show("超过限购数量哦～",
                                                                                context,
                                                                                backgroundColor: Color(0xff5b5956),
                                                                                backgroundRadius: Ui.width(8),
                                                                                duration: Toast.LENGTH_SHORT,
                                                                                gravity: Toast.CENTER);
                                                                            setState(() {
                                                                              list[index]['number'] = list[index]['limit'];
                                                                            });
                                                                          } else if (value ==
                                                                              '') {
                                                                            setState(() {
                                                                              list[index]['number'] = 1;
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              list[index]['number'] = int.parse(value);
                                                                              // shpingcar(list[index]['id'], list[index]['productId'], int.parse(value), carnum);
                                                                            });
                                                                          }
                                                                          shpingcar(
                                                                              list[index]['id'],
                                                                              list[index]['productId'],
                                                                              list[index]['number'],
                                                                              carnum);
                                                                          //  allmoney(getids());
                                                                        },
                                                                      )),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      if (list[index]['number'] >=
                                                                              list[index][
                                                                                  'limit'] &&
                                                                          list[index]['limit'] !=
                                                                              0) {
                                                                        Toast.show(
                                                                            "超过限购数量哦～",
                                                                            context,
                                                                            backgroundColor:
                                                                                Color(0xff5b5956),
                                                                            backgroundRadius: Ui.width(8),
                                                                            duration: Toast.LENGTH_SHORT,
                                                                            gravity: Toast.CENTER);
                                                                        setState(
                                                                            () {
                                                                          list[index]
                                                                              [
                                                                              'number'] = list[
                                                                                  index]
                                                                              [
                                                                              'limit'];
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          list[index]
                                                                              [
                                                                              'number'] = list[index]
                                                                                  ['number'] +
                                                                              1;
                                                                        });
                                                                      }
                                                                      shpingcar(
                                                                          list[index]
                                                                              [
                                                                              'id'],
                                                                          list[index]
                                                                              [
                                                                              'productId'],
                                                                          list[index]
                                                                              [
                                                                              'number'],
                                                                          carnum);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: Ui
                                                                          .width(
                                                                              25),
                                                                      height: Ui
                                                                          .width(
                                                                              25),
                                                                      decoration: BoxDecoration(
                                                                          image: DecorationImage(
                                                                              fit: BoxFit.cover,
                                                                              image: AssetImage('images/2.0x/add.png'))),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )),
                                              secondaryActions: <Widget>[
                                                InkWell(
                                                  onTap: () {
                                                    dele(list[index]['id'],
                                                        carnum);
                                                    setState(() {
                                                      list.removeAt(index);
                                                    });
                                                    // getData();
                                                  },
                                                  child: Container(
                                                    width: Ui.width(110),
                                                    height: Ui.width(280),
                                                    margin: EdgeInsets.fromLTRB(
                                                        0, 0, 0, Ui.width(20)),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFD10123),
                                                      borderRadius: BorderRadius
                                                          .horizontal(
                                                              right: Radius
                                                                  .circular(
                                                                      Ui.width(
                                                                          8))),
                                                    ),
                                                    child: Text(
                                                      '删除',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFF5F5F5),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily:
                                                              'PingFangSC-Medium,PingFang SC',
                                                          fontSize: Ui
                                                              .setFontSizeSetSp(
                                                                  26.0)),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ))
                                    : Nofind(
                                        text: "暂无商品哦～",
                                      ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: Ui.width(750),
                            height: Ui.width(110),
                            padding: EdgeInsets.fromLTRB(
                                Ui.width(30), 0, Ui.width(24), 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0XFFDFE3EC),
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isall = !isall;
                                    });
                                    isall ? reset(2) : reset(1);
                                    allmoney(getids());
                                  },
                                  child: Container(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Image.asset(
                                          isall
                                              ? 'images/2.0x/select.png'
                                              : 'images/2.0x/unselect.png',
                                          width: Ui.width(38),
                                          height: Ui.width(38),
                                        ),
                                      ),
                                      SizedBox(
                                        width: Ui.width(20),
                                      ),
                                      Text(
                                        '全选',
                                        style: TextStyle(
                                            color: Color(0xFF5E6578),
                                            fontWeight: FontWeight.w400,
                                            fontFamily:
                                                'PingFangSC-Medium,PingFang SC',
                                            fontSize:
                                                Ui.setFontSizeSetSp(26.0)),
                                      ),
                                    ],
                                  )),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: type == 2
                                            ? Text('')
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    '合计：',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF111F37),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                26.0)),
                                                  ),
                                                  SizedBox(
                                                    width: Ui.width(5),
                                                  ),
                                                  Text(
                                                    '￥${money}',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFD10123),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'PingFangSC-Medium,PingFang SC',
                                                        fontSize:
                                                            Ui.setFontSizeSetSp(
                                                                34.0)),
                                                  ),
                                                  SizedBox(
                                                    width: Ui.width(30),
                                                  ),
                                                ],
                                              ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          //  getids();
                                          if (type == 2) {
                                            dele(getids(), carnum);
                                          } else {
                                            if (allSelect != 0) {
                                              Navigator.pushNamed(
                                                  context, "/shoppingorder",
                                                  arguments: {'id': getids()});
                                            } else {
                                              Toast.show('请选择下单商品～', context,
                                                  backgroundColor:
                                                      Color(0xff5b5956),
                                                  backgroundRadius:
                                                      Ui.width(16),
                                                  duration: Toast.LENGTH_SHORT,
                                                  gravity: Toast.CENTER);
                                            }
                                          }
                                        },
                                        child: Container(
                                          height: Ui.width(74),
                                          width: Ui.width(230),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            borderRadius: new BorderRadius.all(
                                                new Radius.circular(
                                                    Ui.width(8.0))),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFFEA4802),
                                                Color(0xFFD10123),
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            type == 2
                                                ? '删除（${allSelect}）'
                                                : '结算（${allSelect}）',
                                            style: TextStyle(
                                                color: Color(0xFFFFFFFF),
                                                fontWeight: FontWeight.w400,
                                                fontFamily:
                                                    'PingFangSC-Medium,PingFang SC',
                                                fontSize:
                                                    Ui.setFontSizeSetSp(28.0)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(
                      margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                      child: LoadingDialog(
                        text: "加载中…",
                      ),
                    ),
            )));
  }
}
