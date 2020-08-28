import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
// void main() => runApp(MyApp());

class Testnew extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // App名字
      title: 'EasyRefresh',
      // App主题
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      // 主页
      home: _Example(),
    );
  }
}

class _Example extends StatefulWidget {
  @override
  _ExampleState createState() {
    return _ExampleState();
  }
}

class _ExampleState extends State<_Example> {
  EasyRefreshController _controller;

  // 条目总数
  bool _headerFloat = false;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("EasyRefresh"),
      ),
      body: EasyRefresh(
        enableControlFinishRefresh: false,
        enableControlFinishLoad: true,
        controller: _controller,
        header: ClassicalHeader(
          // enableInfiniteRefresh: false,
          refreshText: '下拉刷新哦～',
          refreshReadyText: '下拉刷新哦～',
          refreshingText: '加载中～',
          refreshedText: '加载完成',
          // refreshFailedText: FlutterI18n.translate(context, 'refreshFailed'),
          // noMoreText: FlutterI18n.translate(context, 'noMore'),
          infoText: "更新时间 %T",
          // bgColor: _headerFloat ? Theme.of(context).primaryColor : null,
          //   infoColor: _headerFloat ? Colors.black87 : Colors.teal,
          //   float: _headerFloat,
          infoColor:Color(0XFF111F37),
          textColor:Color(0XFF111F37),
        ),
        // // footer: ClassicalFooter(),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2), () {
            print('111');
            // setState(() {
            //   _count = 20;
            // });
            _controller.resetLoadState();
          });
        },
        // onLoad: () async {
        //   await Future.delayed(Duration(seconds: 2), () {
        //     print('onLoad');
        //     setState(() {
        //       _count += 10;
        //     });
        //     _controller.finishLoad(noMore: _count >= 40);
        //   });
        // },
        child: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return Center(
                child: Text('${index}跳'),
              );
            }),
        // slivers: <Widget>[
        //   SliverList(
        //     delegate: SliverChildBuilderDelegate(
        //           (context, index) {
        //         return Container(
        //           width: 60.0,
        //           height: 60.0,
        //           child: Center(
        //             child: Text('$index'),
        //           ),
        //           color: index%2==0 ? Colors.grey[300] : Colors.transparent,
        //         );
        //       },
        //       childCount: _count,
        //     ),
        //   ),
        // ],
      ),
      // persistentFooterButtons: <Widget>[
      //   FlatButton(
      //       onPressed: () {
      //         _controller.callRefresh();
      //       },
      //       child: Text("Refresh", style: TextStyle(color: Colors.black))),
      //   FlatButton(
      //       onPressed: () {
      //         _controller.callLoad();
      //       },
      //       child: Text("Load more", style: TextStyle(color: Colors.black))),
      // ]
    );
  }
}
