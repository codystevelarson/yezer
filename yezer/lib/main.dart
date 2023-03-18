import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:yezer/navigation/router.dart';
import 'package:yezer/themes/app_theme.dart';

void main() {
  setPathUrlStrategy();
  runApp(const FleldenRingApp());
}

class FleldenRingApp extends StatelessWidget {
  const FleldenRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: yezRouter,
      title: 'yeZer',
      theme: appTheme,
    );
  }
}
