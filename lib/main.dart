import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            //child: LeftSlider(),
            child: MainApp(),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  final String assetName = 'images/test_svg.svg';
  final Widget svg = SvgPicture.asset(
    'images/settings.svg',
    semanticsLabel: 'Acme Logo',
  );
  final Widget svg2 = SvgPicture.asset(
    'images/snow.svg',
    semanticsLabel: 'Acme Logo',
  );
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: svg2,
          ),
          // Container(
          //   child: svg2,
          // ),
        ],
      ),
    );
  }
}
