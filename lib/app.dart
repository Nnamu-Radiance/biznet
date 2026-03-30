import 'package:flutter/material.dart';

class BiznetApp extends StatelessWidget {
  const BiznetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biznet',
      home: Scaffold(
        appBar: AppBar(title: const Text('Biznet')),
        body: const Center(child: Text('Welcome to Biznet')),
      ),
    );
  }
}
