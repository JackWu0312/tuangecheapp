import 'package:flutter/material.dart';
import '../../ui/ui.dart';
import '../../http/index.dart';
import '../../common/LoadingDialog.dart';
import 'package:toast/toast.dart';
// import 'package:flutter_html/flutter_html.dart';

class Integralrule extends StatefulWidget {
  Integralrule({Key key}) : super(key: key);

  @override
  _IntegralruleState createState() => _IntegralruleState();
}

class _IntegralruleState extends State<Integralrule> {
  bool isloading = false;
  var rule;
  @override
  void initState() {
    super.initState();
    // _controller = EasyRefreshController();
    getData();
  }

  getData() async {
    await HttpUtlis.get('wx/points/lottery/rule', success: (value) {
      if (value['errno'] == 0) {
        setState(() {
          rule = value['data']['value'];
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
    Ui.init(context);
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '积分规则',
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
        body: isloading
            ? Container(
                color: Color(0xFFFFFFFF),
                padding: EdgeInsets.fromLTRB(
                    Ui.width(24), Ui.width(30), Ui.width(24), Ui.width(30)),
                child: ListView(
                  children: <Widget>[
                    // Html(
                    //   data:
                    //       '<div>${this.rule.replaceAll('height="', '')}</div>',
                    // ),
                    Text(
                      '${this.rule}',
                      style: TextStyle(
                          color: Color(0xFF111F37),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'PingFangSC-Medium,PingFang SC',
                          fontSize: Ui.setFontSizeSetSp(30.0)),
                    )
                  ],
                ))
            : Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: LoadingDialog(
                  text: "加载中…",
                ),
              ),
      ),
    );
  }
}
