import 'dart:io';

import 'package:bookkeeping/common/runtime.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import 'pages/home_page.dart';

void main() {
  runApp(MyApp());

  if (Platform.isAndroid) {
    // 设置沉浸状态栏
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
}

class MyApp extends StatefulWidget {
  @override
  State createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('------- [' + state.toString() + '] -------');
    switch (state) {
      case AppLifecycleState.resumed:
        Runtime.resumedListenerList.forEach((f) {
          try {
            f();
          } catch (e) {
            print("exception on resumedListener " + e);
          }
        });
        break;
      case AppLifecycleState.paused:
        Runtime.pausedListenerList.forEach((f) {
          try {
            f();
          } catch (e) {
            print("exception on pausedListener " + e);
          }
        });
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bookkeeping',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      home: ProgressHUD(child: HomePage()),
    );
  }
}
