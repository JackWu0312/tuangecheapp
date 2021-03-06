import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
import '../../common/Nofind.dart';
import 'package:provider/provider.dart';
import '../../provider/Addreslist.dart';
class Addresslist extends StatefulWidget {
  Addresslist({Key key}) : super(key: key);

  @override
  _AddresslistState createState() => _AddresslistState();
}

class _AddresslistState extends State<Addresslist> {
  bool moren=true;
  bool isloading =false;
  List list=[];
 void initState() {
    super.initState();
    getData();
  }
  getData() async {
    await HttpUtlis.get('wx/address/list',
        success: (value) {
      if (value['errno'] == 0) {
        setState(() {
           list = value['data'];
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
  @override
  Widget build(BuildContext context) {
     final counter = Provider.of<Addreslist>(context);
    if (counter.count) {
       Future.delayed(Duration(milliseconds: 200)).then((e) {
        counter.increment(false);
      });
    
      getData();
    }
    Ui.init(context);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '我的收货地址',
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
            onTap: (){
               Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              child: Image.asset('images/2.0x/back.png',width: Ui.width(21),height: Ui.width(37),),
            ),
          ),
          actions: <Widget>[
            InkWell(
                onTap: (){
                  Navigator.pushNamed(context, '/addressadd');
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 0, Ui.width(40), 0),
                  child: Text(
                    '新增地址',
                    style: TextStyle(
                        color: Color(0xFF111F37),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'PingFangSC-Medium,PingFang SC',
                        fontSize: Ui.setFontSizeSetSp(30.0)),
                  ),
                ))
          ],
        ),
        body:isloading? Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(Ui.width(40), 0, Ui.width(40), 0),
          child: list.length>0? 
            ListView.builder(
              itemCount: list.length,
              itemBuilder: (context,index){
                return Container(
                width: Ui.width(670),
                padding: EdgeInsets.fromLTRB(0, Ui.width(30), 0, Ui.width(30)),
                decoration: BoxDecoration(
                  border: Border(
                                  bottom: BorderSide(
                                      width: 1, color: Color(0xffEAEAEA)))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: Ui.width(570),
                      // height: Ui.width(300),
                       alignment: Alignment.centerLeft,
                      child: Column(
                        children: <Widget>[
                          Container(
                              child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: Ui.width(5),
                                left: 0,
                                child:list[index]['defaulted']? Container(
                                  width: Ui.width(54),
                                  height: Ui.width(34),
                                  color: Color(0xFFFCE5E9),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '默认',
                                    style: new TextStyle(
                                      color: Color(0xFFD10123),
                                      fontSize: Ui.setFontSizeSetSp(22.0),
                                      decoration: TextDecoration.none,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                    ),
                                  ),
                                ):Text(''),
                              ),
                              Container(
                               alignment: Alignment.centerLeft,
                                child: Text(
                                  list[index]['defaulted']?'        ${list[index]['fullAddress']}':'${list[index]['fullAddress']}',
                                  style: TextStyle(
                                      color: Color(0xFF111F37),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(30.0)),
                                ),
                              )
                            ],
                          )),
                          SizedBox(
                            height: Ui.width(25),
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Text(
                                  '${list[index]['name']}',
                                  style: TextStyle(
                                      color: Color(0xFF9398A5),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                ),
                                SizedBox(
                                  width: Ui.width(40),
                                ),
                                Text(
                                  '${list[index]['tel']}',
                                  style: TextStyle(
                                      color: Color(0xFF9398A5),
                                      fontWeight: FontWeight.w400,
                                      fontFamily:
                                          'PingFangSC-Medium,PingFang SC',
                                      fontSize: Ui.setFontSizeSetSp(28.0)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: (){
                          Navigator.pushNamed(context, '/adresseditor' ,arguments: {
                                  "id": list[index]['id'],
                                });
                        },
                        child: Container(
                        alignment: Alignment.center,
                        child:Image.asset('images/2.0x/editer.png',width:Ui.width(32),height:Ui.width(32)),
                      ),
                      )
                    )
                  ],
                ),
              );
              },
            ):Nofind(
                    text: "暂无收货地址哦～ 请添加",
                  ),
        ): Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: LoadingDialog(
                text: "加载中…",
              ),
            ),
      ),
    );
  }



}
