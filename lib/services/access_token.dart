import 'package:flutter_secure_storage/flutter_secure_storage.dart';



final storage = FlutterSecureStorage();

// Store token after login
Future<void> saveToken(String token) async {
  await storage.write(key: "auth_token", value: token);
}

// Retrieve token before making requests
Future<String?> getToken() async {
  return await storage.read(key: "auth_token");
}
