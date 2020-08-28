import 'dart:async';
// import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import '../ui/ui.dart';
// import './home/homepage.dart';
import './home/homeNew.dart';
// import './mall/mallpage.dart';
import './mall/mallnew.dart';
// import './user/userpage.dart';
import 'package:provider/provider.dart';
import '../provider/Backhome.dart';
import '../provider/JumpToPage.dart';
import './findcar/findcarpage.dart';
import './information/information.dart';
import '../page/user/myinfo.dart';
import 'package:uni_links/uni_links.dart';

class IndexPages extends StatefulWidget {
  IndexPages({Key key}) : super(key: key);

  @override
  _IndexPagesState createState() => _IndexPagesState();
}
// class _IndexPagesState extends State<IndexPages> with AutomaticKeepAliveClientMixin{ @override bool get wantKeepAlive => true; }
class _IndexPagesState extends State<IndexPages> with WidgetsBindingObserver{
  StreamSubscription _sub;
  // List<Widget> list = [
  //     HomeNew(),
  //     Findcarpage(),
  //     Mallnew(),
  //     Information(),
  //     Myinfo(),
  // ];
  // var _pageController;
  // int _currentIndex = 0;
  @override
  void dispose() {
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _pageController = new PageController(initialPage : _currentIndex);
    initPlatformState();
  }
 
  Future<void> initPlatformState() async {
    _sub = getLinksStream().listen((String link) {
      if (!mounted) return;
      if (link.length > 19) {
        var arr = link.substring(19, link.length).split('/');
        if (arr[0] == 'videos') {
          final counter = Provider.of<Backhome>(context);
          final counters = Provider.of<JumpToPage>(context);
          counter.increment(3);
          // _pageController.jumpToPage(3);
          counters.increment(66);
        } else if (arr[0] == 'secondhand') {
          Navigator.pushNamed(context, '/${arr[0]}');
        } else {
          Navigator.pushNamed(context, '/${arr[0]}', arguments: {
            "id": arr[1],
          });
        }
      }
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        // _latestLink = 'Failed to get latest link: $err.';
        // _latestUri = null;
      });
    });
  }

  // int _currentIndex = 3;
  // List list = [Homepage(), Mallpage(), Userpage()];
  // List listTitle = ['团个车', '商城', '我的'];
  @override
  Widget build(BuildContext context) {
    Ui.init(context);
    final counter = Provider.of<Backhome>(context);
    return Scaffold(

        // appBar: AppBar(
        //   title: Text(listTitle[_currentIndex],style: TextStyle(
        //     color:  Color(0xFF111F37),
        //     fontWeight: FontWeight.w500,
        //     fontFamily: 'PingFangSC-Medium,PingFang SC',
        //     fontSize: Ui.setFontSizeSetSp(36.0)
        //   ),),
        //   centerTitle:true,
        //   elevation:0,
        //   brightness: Brightness.light,
        // ),
        body: 
        // list[counter.count],
        // PageView(controller: _pageController, children: this.list,),
        
        IndexedStack(
          index: counter.count,
          // index:3,
          children: <Widget>[
            HomeNew(),
            Findcarpage(),
            // Mallpage(),
            Mallnew(),
            Information(),
            // Userpage()
            Myinfo()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          // iconSize:12,
          backgroundColor: Color(0xFFFFFFFF),
          currentIndex: counter.count,
          // currentIndex: 3,
          unselectedItemColor: Color(0xFF9398A5),
          selectedItemColor: Color(0xFF111F37),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: Ui.setFontSizeSetSp(20.0),
          unselectedFontSize: Ui.setFontSizeSetSp(20.0),
          // elevation:4,
          onTap: (int index) {
            counter.increment(index);
            // _pageController.jumpToPage(index);
            // setState(() {
            //   this._currentIndex = index;
            // });
          },
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'images/2.0x/homepage.png',
                width: Ui.width(55.0),
                height: Ui.width(55.0),
              ),
              activeIcon: Image.asset(
                'images/2.0x/homepageselect.png',
                width: Ui.width(55.0),
                height: Ui.width(55.0),
              ),
              title: Text("首页"),
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'images/2.0x/findcar.png',
                width: Ui.width(55.0),
                height: Ui.width(55.0),
              ),
              activeIcon: Image.asset(
                'images/2.0x/selectfindcar.png',
                width: Ui.width(55.0),
                height: Ui.width(55.0),
              ),
              title: Text("找车"),
            ),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'images/2.0x/mall.png',
                  width: Ui.width(55.0),
                  height: Ui.width(55.0),
                ),
                activeIcon: Image.asset(
                  'images/2.0x/selectmall.png',
                  width: Ui.width(55.0),
                  height: Ui.width(55.0),
                ),
                title: Text("商城")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'images/2.0x/information.png',
                  width: Ui.width(55.0),
                  height: Ui.width(55.0),
                ),
                activeIcon: Image.asset(
                  'images/2.0x/informationselect.png',
                  width: Ui.width(55.0),
                  height: Ui.width(55.0),
                ),
                title: Text("资讯")),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'images/2.0x/infopage.png',
                  width: Ui.width(55.0),
                  height: Ui.width(55.0),
                ),
                activeIcon: Image.asset(
                  'images/2.0x/infopageselect.png',
                  width: Ui.width(55.0),
                  height: Ui.width(55.0),
                ),
                title: Text("我的"))
          ],
        ));
  }
}
