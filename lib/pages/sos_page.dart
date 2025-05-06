import 'package:flutter/material.dart';
import 'package:fyp/components/custom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:fyp/get.dart';

class SOSAlertPage extends StatefulWidget {
  @override
  _SOSAlertPageState createState() => _SOSAlertPageState();
}

class _SOSAlertPageState extends State<SOSAlertPage> {
  int tapCount = 0;

  void _handleDoubleTap() {
    setState(() {
      tapCount++;
    });

    if (tapCount >= 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('SOS Cancelled. You are safe.')));
      tapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AppController>();
    final userRole = authController.userRole.value;
    return Scaffold(
      backgroundColor: Colors.red[700],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        // <-- This ensures full center alignment
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // horizontal centering
          children: [
            Text(
              'SOS Alarm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(
                Icons.notifications_active,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'SOS alert is sent to Nearby Police Stations',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.touch_app, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Declare Safe',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Double tap here to cancel',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: userRole == 'SI' ? 4 : 2,
      ),
    );
  }
}
