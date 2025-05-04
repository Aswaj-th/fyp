import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:fyp/get.dart'; // adjust path if needed

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  OTPVerificationPage({required this.phoneNumber});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final AppController authController = Get.find();
  int _start = 60;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _canResend = false;
    _start = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> verifyOTP() async {
    final otp = _otpController.text.trim();
    final phone = widget.phoneNumber;

    final url = Uri.parse(
      'https://policonn.rtnayush.run.place/api/auth/validate-otp',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];

        if (accessToken != null) {
          // Decode and get role
          Map<String, dynamic> decodedToken = Jwt.parseJwt(accessToken);
          String role = decodedToken['role'];

          // Save in global state
          authController.setAuthData(accessToken, role);

          // Navigate based on role
          if (role == 'SUPERADMIN') {
            Get.snackbar("Wait", "superadmin dashboard yet to be implemented");
          } else if (role == 'head_constable') {
            Navigator.pushNamed(context, '/hc/home');
          } else if (role == 'officer') {
            Navigator.pushNamed(context, '/si/menu');
          } else {
            Get.snackbar("Unauthorized", "Unknown role: $role");
          }
        } else {
          Get.snackbar("Error", "Token not received");
        }
      } else {
        Get.snackbar("Error", "Invalid OTP");
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Something went wrong");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00283C),
      body: Column(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Verify Phone Number',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Code sent to ${widget.phoneNumber}. Please\nenter the code below',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  const Text(
                    'Enter OTP',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Enter OTP',
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Didn’t receive code? ",
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Resend code",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration:
                                      _canResend
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap =
                                          _canResend
                                              ? () {
                                                print("Resending code...");
                                                startTimer();
                                              }
                                              : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Resend code in 00:${_start.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
