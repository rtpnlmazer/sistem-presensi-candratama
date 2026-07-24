import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'auth_service.dart';
import '../config/api_config.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class AttendanceService {
  final String baseUrl = ApiConfig.apiUrl;

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60,
      minWidth: 800,
      minHeight: 800,
    );
    return result != null ? File(result.path) : file;
  }

  Future<Map<String, dynamic>> sendOvertime(
    String date,
    String startTime,
    String endTime,
    String reason,
  ) async {
    try {
      var response = await ApiService.post(
        ApiConfig.overtimes,
        body: {
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'reason': reason,
        },
      );

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengajukan lembur',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<List<dynamic>> getOvertimeHistory() async {
    try {
      final response = await ApiService.get('$baseUrl/overtimes');

      if (response.statusCode == 401) {
        await AuthService().forceLogout();
        return [];
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getOvertimeHistory: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> sendAttendance(
    double lat,
    double long,
    File imageFile,
    String type, [
    String? lateReason,
    File? latePhoto,
  ]) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/attendances'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = long.toString();
      request.fields['type'] = type;

      if (lateReason != null && lateReason.isNotEmpty) {
        request.fields['late_reason'] = lateReason;
      }

      if (latePhoto != null) {
        File? compressedLate = await _compressImage(latePhoto);
        var latePhotoMultipart = await http.MultipartFile.fromPath(
          'late_photo',
          compressedLate!.path,
        );
        request.files.add(latePhotoMultipart);
      }

      File? compressedMain = await _compressImage(imageFile);
      var imageMultipart = await http.MultipartFile.fromPath(
        'image',
        compressedMain!.path,
      );
      request.files.add(imageMultipart);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal melakukan presensi',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server'};
    }
  }

  Future<List<dynamic>> getHistory() async {
    try {
      final response = await ApiService.get('$baseUrl/attendances/history');

      if (response.statusCode == 401) {
        await AuthService().forceLogout();
        return [];
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        return [];
      }
    } catch (e) {
      print('Error get history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> sendLeaveRequest(
    String type,
    String startDate,
    String endDate,
    String reason,
    File? attachment,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/leave-request'),
      );
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['type'] = type;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;
      request.fields['reason'] = reason;

      if (attachment != null) {
        var multipartFile = await http.MultipartFile.fromPath(
          'attachment',
          attachment.path,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        await AuthService().forceLogout();
        return {'success': false, 'message': 'Sesi Anda telah berakhir.'};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengirim pengajuan',
      };
    } catch (e) {
      print('Error Pengajuan Izin: $e');
      return {'success': false, 'message': 'Gagal terhubung ke server!'};
    }
  }

  Future<List<dynamic>> getLeaveHistory() async {
    try {
      final response = await ApiService.get('$baseUrl/leave-history');

      if (response.statusCode == 401) {
        await AuthService().forceLogout();
        return [];
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      }
      return [];
    } catch (e) {
      print('Error getLeaveHistory: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateLeaveRequest(
    int id,
    String type,
    String startDate,
    String endDate,
    String reason,
    File? attachment,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) return {'success': false, 'message': 'Belum login'};

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.apiUrl}/leave-request/$id/update'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['type'] = type;
      request.fields['start_date'] = startDate;
      request.fields['end_date'] = endDate;
      request.fields['reason'] = reason;

      if (attachment != null) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', attachment.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal memperbarui',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan'};
    }
  }
}
