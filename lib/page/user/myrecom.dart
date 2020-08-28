import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import 'package:toast/toast.dart';
import '../../common/Nofind.dart';
class Myrecom extends StatefulWidget {
  Myrecom({Key key}) : super(key: key);

  @override
  _MyrecomState createState() => _MyrecomState();
}

class _MyrecomState extends State<Myrecom> {
  ScrollController _scrollController = new ScrollController();
  bool nolist = true;
  bool isMore = true;
  int page = 1;
  int limit = 10;
  List list = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 60) {
        if (nolist) {
          getData();
        }
        setState(() {
          isMore = false;
        });
      }
    });
    getData();
  }

  getData() async {
    if (isMore) {
      await HttpUtlis.get(
          'wx/user/recommends?&page=${this.page}&limit=${this.limit}',
          success: (value) {
        if (value['errno'] == 0) {
          if (value['data']['list'].length < limit) {
            setState(() {
              nolist = false;
              this.isMore = true;
              list.addAll(value['data']['list']);
            });
          } else {
            setState(() {
              page++;
              nolist = true;
              this.isMore = true;
              list.addAll(value['data']['list']);
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
  }

  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '好友推荐',
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
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Color(0xFFFFFFFF),
          padding: EdgeInsets.fromLTRB(Ui.width(30), 0, Ui.width(30), 0),
          child: list.length > 0
              ? ListView.builder(
                  controller: _scrollController,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: Ui.width(690),
                      height: Ui.width(120),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Color(0XFFEAEAEA), width: Ui.width(1)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${list[index]['name']}',
                            style: TextStyle(
                                color: Color(0xFF111F37),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(30.0)),
                          ),
                          Text(
                            '${list[index]['mobile']}',
                            style: TextStyle(
                                color: Color(0xFF9398A5),
                                fontWeight: FontWeight.w400,
                                fontFamily: 'PingFangSC-Medium,PingFang SC',
                                fontSize: Ui.setFontSizeSetSp(30.0)),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Nofind(
                  text: "没有更多推荐人哦～",
                ),
        ));
  }
}
