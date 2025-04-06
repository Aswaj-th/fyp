import 'package:flutter/material.dart';
import 'pages/otp_verification_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OTPVerificationPage(phoneNumber: "9207137220"),
    );
  }
}
