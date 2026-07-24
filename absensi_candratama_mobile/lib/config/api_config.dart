import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ApiConfig {
  static const String baseUrl = 'http://10.136.70.141:8000';

  static const String apiUrl = '$baseUrl/api';
  static const String storageUrl = '$baseUrl/storage/';

  static const String login = '$apiUrl/login';
  static const String logout = '$apiUrl/logout';
  static const String profile = '$apiUrl/profile';
  static const String attendances = '$apiUrl/attendances';
  static const String leaves = '$apiUrl/leaves';
  static const String overtimes = '$apiUrl/overtimes';
  static const String getStatistics = "$apiUrl/attendance/statistics";
} 

class ApiService {
  static const int globalTimeout = 10;

  static Future<http.Response> get(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      return await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: globalTimeout));
    } on TimeoutException {
      return http.Response(
        '{"success": false, "message": "Koneksi lambat, coba lagi."}',
        408,
      );
    } catch (e) {
      return http.Response(
        '{"success": false, "message": "Server tidak merespons."}',
        500,
      );
    }
  }

  static Future<http.Response> post(String url, {Object? body}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      return await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: globalTimeout));
    } on TimeoutException {
      return http.Response(
        '{"success": false, "message": "Koneksi lambat, coba lagi."}',
        408,
      );
    } catch (e) {
      return http.Response(
        '{"success": false, "message": "Server tidak merespons."}',
        500,
      );
    }
  }

  static Future<http.Response> delete(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    try {
      return await http
          .delete(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: globalTimeout));
    } on TimeoutException {
      return http.Response(
        '{"success": false, "message": "Koneksi lambat, coba lagi."}',
        408,
      );
    } catch (e) {
      return http.Response(
        '{"success": false, "message": "Server tidak merespons."}',
        500,
      );
    }
  }
}
