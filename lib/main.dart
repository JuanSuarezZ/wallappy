import 'package:flutter/material.dart';

import 'package:wallappy/pages/fullIImage.dart';
import 'package:wallappy/pages/testPage.dart';
import 'package:wallappy/pages/wallpapers.dart';

void main() async {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();

  //TODO: icon app, name app, refactor pexelsprovider
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    // TODO: pedir permisos para descargas en aplicar foto
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        'FullImage': (context) => FullImage(),
        'testpage': (context) => TestHomePage()
      },
      home: Wallpaper(),
    );
  }
}
