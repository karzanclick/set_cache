import 'package:flutter/material.dart';
import 'package:set_cache/set_cache.dart';

void main() {
  // maxAge: days
  // init() must be called before using save() and get()
  SetCache.instance.init(lifeTime: const Duration(days: 7));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Set Cache Example';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
    );
  }
}
