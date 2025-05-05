import 'package:get/get.dart';

class AuthController extends GetxController {
  final jwt = ''.obs;
  final userId = ''.obs;
  final userRole = ''.obs;
  final stationId = ''.obs;

  void setAuthData({
    required String token,
    required String id,
    required String role,
    required String station,
  }) {
    jwt.value = token;
    userId.value = id;
    userRole.value = role;
    stationId.value = station;
  }

  void clearAuthData() {
    jwt.value = '';
    userId.value = '';
    userRole.value = '';
    stationId.value = '';
  }

  bool get isAuthenticated => jwt.value.isNotEmpty;
} 