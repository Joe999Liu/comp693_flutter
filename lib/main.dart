import 'package:flutter_tiktok/style/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth/loginPage.dart';

void main() {
  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
      debugPrint(flutterErrorDetails.toString());
      return Material(
        child: Center(
            child: Text(
          "Error",
          textAlign: TextAlign.center,
        )),
      );
    };
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Tiktok',
      theme: ThemeData(
        brightness: Brightness.dark,
        hintColor: Colors.white,
        primaryColor: ColorPlate.orange,
        scaffoldBackgroundColor: ColorPlate.back1,
        dialogBackgroundColor: ColorPlate.back2,
      ),
      home: LoginPage(),
    );
  }
}
