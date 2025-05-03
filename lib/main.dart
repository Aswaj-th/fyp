import 'package:flutter/material.dart';
import 'package:fyp/pages/hc_assigned_cases.dart';
// import 'package:fyp/pages/hc_dashboard.dart';
// import 'pages/hc_homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AssignedCasesPage(),
    );
  }
}
