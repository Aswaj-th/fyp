import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AppController extends GetxController {
  var jwt = ''.obs;
  var userRole = ''.obs;
  var userInfo = <String, dynamic>{}.obs; // Store decoded JWT payload
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // Load stored JWT and role on initialization
    jwt.value = storage.read('jwt') ?? '';
    userRole.value = storage.read('userRole') ?? '';
    if (jwt.value.isNotEmpty) {
      _decodeJwt(jwt.value); // Decode JWT if it exists
    }
  }

  void setAuthData(String newJwt, String newRole) {
    jwt.value = newJwt;
    userRole.value = newRole;
    // Save to storage
    storage.write('jwt', newJwt);
    storage.write('userRole', newRole);
    // Decode JWT and update userInfo
    _decodeJwt(newJwt);
  }

  void clearAuthData() {
    jwt.value = '';
    userRole.value = '';
    userInfo.clear();
    // Clear from storage
    storage.remove('jwt');
    storage.remove('userRole');
  }

  void _decodeJwt(String token) {
    try {
      // Decode JWT payload
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      userInfo.value = payload; // Store decoded payload
    } catch (e) {
      print('Error decoding JWT: $e');
      userInfo.clear(); // Clear userInfo on error
    }
  }
}
