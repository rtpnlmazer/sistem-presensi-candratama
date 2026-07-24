import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screens/login_screen.dart';
import '../config/api_config.dart';

class AuthService {
  final String baseUrl = ApiConfig.apiUrl;

  Future<void> forceLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? currentTheme = prefs.getInt('theme_mode');

    await prefs.clear();

    if (currentTheme != null) {
      await prefs.setInt('theme_mode', currentTheme);
    }

    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Sesi Anda telah habis. Silakan login kembali.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String deviceId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Accept': 'application/json'},
            body: {'email': email, 'password': password, 'device_id': deviceId},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        String name = data['data']['name'];
        String position = data['data']['position'] ?? 'Karyawan';
        String nip = data['data']['nip'] ?? '-';
        String photoPath = data['data']['photo'] ?? '';
        String email = data['data']['email'] ?? '-';
        String phone = data['data']['phone'] ?? '-';
        String address = data['data']['address'] ?? '-';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('name', name);
        await prefs.setString('position', position);
        await prefs.setString('nip', nip);
        await prefs.setString('photo_path', photoPath);
        await prefs.setString('email', email);
        await prefs.setString('phone', phone);
        await prefs.setString('address', address);

        return {'success': true, 'message': 'Login Berhasil'};
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau Password salah!',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message':
            'Gagal terhubung ke Server! Pastikan server aktif dan koneksi internet stabil.',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfilePhoto(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update-profile-photo'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        await forceLogout();
        return {'success': false, 'message': 'Sesi habis'};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString('photo_path', data['photo_path']);
        return {
          'success': true,
          'message': data['message'],
          'photo_path': data['photo_path'],
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memperbarui foto',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await ApiService.post(
        '$baseUrl/change-password',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      if (response.statusCode == 401) {
        await forceLogout();
        return {'success': false, 'message': 'Sesi habis'};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengubah kata sandi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String name,
    String email,
    String phone,
    String address,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      await forceLogout();
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login kembali.',
      };
    }

    try {
      final response = await ApiService.post(
        '$baseUrl/update-profile',
        body: {'name': name, 'email': email, 'phone': phone, 'address': address},
      );

      if (response.statusCode == 401) {
        await forceLogout();
        return {'success': false, 'message': 'Sesi habis'};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Profil berhasil diperbarui',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui profil',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }
}
