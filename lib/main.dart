import 'package:flutter/material.dart';

/// Temporary entry point.
///
/// Step 0.2 replaces this with `app/app.dart` and `app/bootstrap.dart`, and
/// step 0.3 splits it into per-flavor entry points (`main_dev.dart`, ...).
void main() {
  runApp(const DetectiveDarkApp());
}

class DetectiveDarkApp extends StatelessWidget {
  const DetectiveDarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const Scaffold(backgroundColor: Colors.black),
    );
  }
}
