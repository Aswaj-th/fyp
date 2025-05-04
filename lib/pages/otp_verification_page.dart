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
  bool _isLoading = false;
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
    if (_isLoading) return;

    final otp = _otpController.text.trim();
    final phone = widget.phoneNumber;

    if (otp.isEmpty || otp.length != 6) {
      Get.snackbar("Error", "Please enter a valid 6-digit OTP");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print(phone);
      print(otp);
      final response = await http.post(
        Uri.parse('https://policonn.rtnayush.run.place/api/auth/validate-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'otp': otp}),
      );

      print(response.statusCode);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Response data: $data'); // Debug print

        // Access the accessToken from the nested data structure
        final accessToken = data['data']['accessToken'];
        print('Access token: $accessToken'); // Debug print

        if (accessToken != null) {
          // Decode and get role
          Map<String, dynamic> decodedToken = Jwt.parseJwt(accessToken);
          String role = decodedToken['role'];
          print('User role: $role'); // Debug print

          // Save in global state
          authController.setAuthData(accessToken, role);

          // Navigate based on role
          String route;
          switch (role) {
            case 'SUPERADMIN':
              route = '/admin/home';
              break;
            case 'HC':
              route = '/hc/home';
              break;
            case 'SI':
              route = '/si/menu';
              break;
            default:
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Unknown role: $role")));
              return;
          }

          print('Navigating to route: $route'); // Debug print
          // Clear the navigation stack and push the new route
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Token not received")));
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          // Use ScaffoldMessenger instead of Get.snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['message'] ?? "Invalid OTP")),
          );
        } catch (e) {
          // Fallback if parsing fails
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resendOTP() async {
    if (!_canResend) return;

    try {
      final response = await http.post(
        Uri.parse('https://policonn.rtnayush.run.place/api/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': widget.phoneNumber}),
      );

      if (response.statusCode == 201) {
        startTimer();
        Get.snackbar("Success", "OTP sent successfully");
      } else {
        Get.snackbar("Error", "Failed to resend OTP");
      }
    } catch (e) {
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
                      onPressed: _isLoading ? null : verifyOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : const Text(
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
                            text: "Didn't receive code? ",
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: "Resend code",
                                style: TextStyle(
                                  color: _canResend ? Colors.blue : Colors.grey,
                                  decoration:
                                      _canResend
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = _canResend ? resendOTP : null,
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
