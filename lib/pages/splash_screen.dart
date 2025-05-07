import 'package:flutter/material.dart';
import 'package:fyp/get.dart';
import 'package:fyp/pages/login_page.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppController authController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    // Navigate to the appropriate screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (authController.jwt.value.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Navigate based on user role
        switch (authController.userRole.value) {
          case 'SUPERADMIN':
            Navigator.pushReplacementNamed(context, '/admin/home');
            break;
          case 'HC':
            Navigator.pushReplacementNamed(context, '/hc/home');
            break;
          case 'SI':
            Navigator.pushReplacementNamed(context, '/si/home');
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF001A2C), // Dark blue background
        ),
        child: Stack(
          children: [
            // Bottom curved shape (lightest)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A5A6B),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(200),
                  ),
                ),
              ),
            ),
            // Middle curved shape (medium)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFF344456),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(200),
                  ),
                ),
              ),
            ),
            // Top curved shape (darkest)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2E40),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200),
                    topRight: Radius.circular(200),
                  ),
                ),
              ),
            ),
            // Text content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 80,
                  ), // Push text down to center of visible area
                  const Text(
                    'Police',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Connect App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
