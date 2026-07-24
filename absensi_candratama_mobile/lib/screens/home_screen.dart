import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'map_attendance_screen.dart';
import '../services/attendance_service.dart';
import 'leave_request_screen.dart';
import 'overtime_request_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:safe_device/safe_device.dart';
import 'notification_screen.dart';
import '../services/notification_service.dart';
import 'package:ntp/ntp.dart';
import '../config/api_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Memuat...';
  String _currentTime = '00:00:00';
  String _photoPath = '-';
  Timer? _timer;

  final String _storageBaseUrl = ApiConfig.storageUrl;
  final NotificationService _notificationService = NotificationService();

  String? _jamMasuk;
  String? _jamPulang;
  String? _jamMulaiAbsen;

  List<dynamic> _liburPerusahaan = [];

  Future<bool> _verifySecurity() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );

    try {
      bool isJailBroken = await SafeDevice.isJailBroken;
      bool isRealDevice = await SafeDevice.isRealDevice;
      bool isMockLocation = await SafeDevice.isMockLocation;

      DateTime localTime = DateTime.now();
      DateTime internetTime = await NTP.now();
      int timeDifference = localTime.difference(internetTime).inMinutes.abs();

      Navigator.pop(context);

      if (timeDifference > 2) {
        _showInfoDialog(
          'Waktu Tidak Sinkron!',
          'Jam di HP Anda terdeteksi tidak akurat.\n\nHarap aktifkan "Tanggal & Waktu Otomatis" di Pengaturan HP.',
        );
        return false;
      }
      if (isJailBroken) {
        _showInfoDialog(
          'Keamanan Terancam!',
          'Perangkat Root / Jailbreak tidak dapat digunakan untuk mengakses aplikasi ini.',
        );
        return false;
      }
      if (!isRealDevice) {
        _showInfoDialog(
          'Akses Ditolak!',
          'Harap gunakan Smartphone fisik, bukan Emulator.',
        );
        return false;
      }
      if (isMockLocation) {
        _showInfoDialog(
          'Lokasi Palsu Terdeteksi!',
          'Anda terdeteksi menggunakan aplikasi Fake GPS. Harap matikan untuk melanjutkan.',
        );
        return false;
      }

      return true;
    } catch (e) {
      Navigator.pop(context);
      _showInfoDialog(
        'Error Sistem!',
        'Gagal memverifikasi keamanan perangkat dan waktu server.',
      );
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _checkAndSendFcmToken();

    _fetchJamKerja();
    _fetchLiburNasional();
    _fetchCompanyHolidays();
    _notificationService.initNotification();
    _fetchUnreadCount();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndSendFcmToken() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _notificationService.sendTokenToServer(fcmToken);
        print('Sinkronisasi Beranda: Token FCM berhasil divalidasi ke server.');
      }
    } catch (e) {
      print('Gagal sinkronisasi FCM Token di Beranda: $e');
    }
  }

  void _getTime() {
    if (mounted) {
      setState(() {
        _currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    }
  }

  Future<void> _fetchJamKerja() async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.apiUrl}/pengaturan-absensi',
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          final data = result['data'];
          if (mounted) {
            setState(() {
              _jamMasuk = data['time_in_limit']
                  .toString()
                  .substring(0, 5)
                  .replaceFirst(':', '.');
              _jamPulang = data['time_out_limit']
                  .toString()
                  .substring(0, 5)
                  .replaceFirst(':', '.');
              _jamMulaiAbsen = data['start_time'] != null
                  ? data['start_time']
                        .toString()
                        .substring(0, 5)
                        .replaceFirst(':', '.')
                  : '06.00';
            });
          }
        }
      } else {
        if (mounted)
          setState(() {
            _jamMasuk = '--.--';
            _jamPulang = '--.--';
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _jamMasuk = '--.--';
          _jamPulang = '--.--';
        });
    }
  }

  Future<void> _fetchCompanyHolidays() async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.apiUrl}/company-holidays',
      );
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] && mounted) {
          setState(() {
            _liburPerusahaan = result['data'];
          });
        }
      }
    } catch (e) {}
  }

  String? _getCompanyHolidayReason(DateTime date) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    for (var item in _liburPerusahaan) {
      if (item['date'] == dateStr) {
        return item['description'];
      }
    }
    return null;
  }

  int _unreadCount = 0;

  Future<void> _fetchUnreadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await ApiService.get(
          '${ApiConfig.apiUrl}/notifications/unread-count',
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (mounted)
            setState(() {
              _unreadCount = data['data'];
            });
        }
      } catch (e) {}
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('name') ?? 'Karyawan';
        _photoPath = prefs.getString('photo_path') ?? '';
      });
    }
  }

  List<String> _liburNasional = [];
  final String _googleApiKey = 'AIzaSyAfW8jltYDADAxEpQE_h0uPfxawKrRHyG4';

  Future<void> _fetchLiburNasional() async {
    try {
      int currentYear = DateTime.now().year;
      String calendarId = Uri.encodeComponent(
        'id.indonesian#holiday@group.v.calendar.google.com',
      );
      String timeMin = '${currentYear}-01-01T00:00:00Z';
      String timeMax = '${currentYear}-12-31T23:59:59Z';
      String url =
          'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?key=$_googleApiKey&timeMin=$timeMin&timeMax=$timeMax';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        List<String> liburValid = [];

        for (var item in items) {
          String summary = item['summary']?.toString().toLowerCase() ?? '';

          String dateStr = '';
          if (item['start']['date'] != null) {
            dateStr = item['start']['date'].toString().substring(0, 10);
          } else if (item['start']['dateTime'] != null) {
            DateTime dt = DateTime.parse(
              item['start']['dateTime'].toString(),
            ).toLocal();
            dateStr = DateFormat('yyyy-MM-dd').format(dt);
          }

          if (summary.contains('cuti bersama') ||
              summary.contains('puasa') ||
              summary.contains('ramadhan')) {
            continue;
          }

          if (dateStr.isNotEmpty) {
            liburValid.add(dateStr);
          }
        }

        if (mounted) {
          setState(() {
            _liburNasional = liburValid;
          });
        }
      }
    } catch (e) {}
  }

  bool _isTanggalMerah(DateTime date) {
    String dateStr = DateFormat('yyyy-MM-dd').format(date);
    return _liburNasional.contains(dateStr);
  }

  Future<void> _refreshData() async {
    await _loadUserData();
    await _fetchUnreadCount();
    setState(() {
      _jamMasuk = null;
      _jamPulang = null;
    });
    await _fetchJamKerja();
    await _fetchCompanyHolidays();
    await Future.delayed(Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data beranda berhasil diperbarui!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF1E63D8), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(message, style: TextStyle(height: 1.5)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E63D8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('OK Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _goToMapAttendance(String type) async {
    DateTime todayDate = DateTime.now();

    bool isSecure = await _verifySecurity();
    if (!isSecure) return;

    if (todayDate.weekday == DateTime.sunday) {
      _showInfoDialog(
        'Hari Libur',
        'Hari ini adalah hari Minggu.\nAnda tidak dapat melakukan presensi.',
      );
      return;
    }

    if (_isTanggalMerah(todayDate)) {
      _showInfoDialog(
        'Libur Nasional',
        'Hari ini adalah tanggal merah / Libur Nasional.\nAnda tidak dapat melakukan presensi.',
      );
      return;
    }

    String? companyHolidayReason = _getCompanyHolidayReason(todayDate);
    if (companyHolidayReason != null) {
      _showInfoDialog(
        'Kantor Diliburkan',
        'Hari ini seluruh kegiatan kantor diliburkan.\n\nKeterangan: $companyHolidayReason\n\nOleh karena itu, Anda tidak dapat melakukan presensi.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Color(0xFF1E63D8))),
    );

    try {
      AttendanceService service = AttendanceService();
      List<dynamic> leaves = await service.getLeaveHistory();

      Navigator.pop(context);

      String todayStr = DateFormat('yyyy-MM-dd').format(todayDate);
      DateTime today = DateTime.parse(todayStr);

      bool hasLeaveToday = false;
      String leaveStatus = '';

      for (var leave in leaves) {
        DateTime start = DateTime.parse(leave['start_date']);
        DateTime end = DateTime.parse(leave['end_date']);
        if ((today.isAtSameMomentAs(start) || today.isAfter(start)) &&
            (today.isAtSameMomentAs(end) || today.isBefore(end))) {
          if (leave['status'] != 'rejected') {
            hasLeaveToday = true;
            leaveStatus = leave['status'];
            break;
          }
        }
      }

      if (hasLeaveToday) {
        String statusText = leaveStatus == 'approved'
            ? 'DISETUJUI'
            : 'MENUNGGU PERSETUJUAN';
        _showInfoDialog(
          'Akses Ditolak',
          'Anda sudah memiliki pengajuan Izin/Sakit untuk hari ini (Status: $statusText).\n\nAnda tidak dapat membuat pengajuan ganda.',
        );
        return;
      }
    } catch (e) {
      Navigator.pop(context);
      _showInfoDialog('Error', 'Gagal memverifikasi data pengajuan izin.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );

    try {
      bool isJailBroken = await SafeDevice.isJailBroken;
      bool isRealDevice = await SafeDevice.isRealDevice;
      bool isMockLocation = await SafeDevice.isMockLocation;

      DateTime localTime = DateTime.now();
      DateTime internetTime = await NTP.now();
      int timeDifference = localTime.difference(internetTime).inMinutes.abs();

      Navigator.pop(context);

      if (timeDifference > 2) {
        _showInfoDialog(
          'Waktu Tidak Sinkron!',
          'Jam di HP Anda terdeteksi tidak akurat.\n\nHarap aktifkan "Tanggal & Waktu Otomatis" di Pengaturan HP.',
        );
        return;
      }
      if (isJailBroken) {
        _showInfoDialog(
          'Keamanan Terancam!',
          'Perangkat Root / Jailbreak tidak dapat digunakan untuk presensi.',
        );
        return;
      }
      if (!isRealDevice) {
        _showInfoDialog(
          'Akses Ditolak!',
          'Harap gunakan Smartphone fisik, bukan Emulator.',
        );
        return;
      }
      if (isMockLocation) {
        _showInfoDialog(
          'Lokasi Palsu Terdeteksi!',
          'Anda terdeteksi menggunakan aplikasi Fake GPS. Harap matikan untuk melanjutkan.',
        );
        return;
      }
    } catch (e) {
      Navigator.pop(context);
      _showInfoDialog(
        'Error Sistem!',
        'Gagal memverifikasi keamanan perangkat.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Color(0xFF1E63D8))),
    );

    AttendanceService service = AttendanceService();
    List<dynamic> history = await service.getHistory();
    List<dynamic> leaves = await service.getLeaveHistory();

    Navigator.pop(context);

    String todayStr = DateFormat('yyyy-MM-dd').format(todayDate);
    DateTime today = DateTime.parse(todayStr);

    bool hasLeaveToday = false;
    String leaveStatus = '';

    for (var leave in leaves) {
      DateTime start = DateTime.parse(leave['start_date']);
      DateTime end = DateTime.parse(leave['end_date']);
      if ((today.isAtSameMomentAs(start) || today.isAfter(start)) &&
          (today.isAtSameMomentAs(end) || today.isBefore(end))) {
        if (leave['status'] != 'rejected') {
          hasLeaveToday = true;
          leaveStatus = leave['status'];
          break;
        }
      }
    }

    if (hasLeaveToday) {
      String statusText = leaveStatus == 'approved'
          ? 'DISETUJUI'
          : 'MENUNGGU PERSETUJUAN';
      _showInfoDialog(
        'Terkunci',
        'Anda memiliki pengajuan Izin/Cuti untuk hari ini (Status: $statusText).\n\nAnda tidak dapat melakukan presensi.',
      );
      return;
    }

    var todayRecord;
    for (var item in history) {
      if (item['date'] == todayStr) {
        todayRecord = item;
        break;
      }
    }

    if (type == 'Masuk') {
      if (todayRecord != null) {
        _showInfoDialog(
          'Sudah Melakukan Presensi Masuk!',
          'Anda sudah melakukan Presensi Masuk hari ini.',
        );
        return;
      }

      if (_jamMulaiAbsen != null && _jamMulaiAbsen != '--.--') {
        try {
          List<String> parts = _jamMulaiAbsen!.split('.');
          int bukaJam = int.parse(parts[0]);
          int bukaMenit = int.parse(parts[1]);
          DateTime now = DateTime.now();
          int currentTotalMinutes = (now.hour * 60) + now.minute;
          int bukaTotalMinutes = (bukaJam * 60) + bukaMenit;

          if (currentTotalMinutes < bukaTotalMinutes) {
            String jamAsli = _jamMulaiAbsen!.replaceFirst('.', ':');
            _showInfoDialog(
              'Belum Dibuka',
              'Terlalu pagi! Presensi Karyawan baru dibuka pada pukul $jamAsli WIB. Silakan menunggu sejenak.',
            );
            return;
          }
        } catch (e) {}
      }

      bool isLate = false;
      if (_jamMasuk != null && _jamMasuk != '--.--') {
        try {
          List<String> parts = _jamMasuk!.split('.');
          int batasJam = int.parse(parts[0]);
          int batasMenit = int.parse(parts[1]);
          DateTime now = DateTime.now();
          int currentTotalMinutes = (now.hour * 60) + now.minute;
          int batasTotalMinutes = (batasJam * 60) + batasMenit;
          if (currentTotalMinutes > batasTotalMinutes) {
            isLate = true;
          }
        } catch (e) {}
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapAttendanceScreen(type: type, isLate: isLate),
        ),
      );
      return;
    } else if (type == 'Keluar') {
      if (todayRecord == null) {
        _showInfoDialog(
          'Belum Melakukan Presensi Masuk!',
          'Anda belum melakukan Presensi Masuk hari ini.',
        );
        return;
      }
      if (todayRecord['time_out'] != null) {
        _showInfoDialog(
          'Sudah Pulang!',
          'Anda sudah menyelesaikan Presensi hari ini.',
        );
        return;
      }

      if (_jamPulang != null && _jamPulang != '--.--') {
        try {
          List<String> parts = _jamPulang!.split('.');
          int batasJam = int.parse(parts[0]);
          int batasMenit = int.parse(parts[1]);
          DateTime now = DateTime.now();
          int currentTotalMinutes = (now.hour * 60) + now.minute;
          int batasTotalMinutes = (batasJam * 60) + batasMenit;

          if (currentTotalMinutes < batasTotalMinutes) {
            String jamAsli = _jamPulang!.replaceFirst('.', ':');
            _showInfoDialog(
              'Belum Waktunya Pulang',
              'Sistem menolak. Anda baru diperbolehkan melakukan Presensi Pulang pada pukul $jamAsli WIB.',
            );
            return;
          }
        } catch (e) {}
      } else if (_jamPulang == null) {
        _showInfoDialog(
          'Memuat Data',
          'Aturan jam kerja belum selesai dimuat dari server. Harap tunggu sebentar.',
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapAttendanceScreen(type: type),
        ),
      );
    }
  }

  Future<void> _goToLeaveRequest() async {
    DateTime todayDate = DateTime.now();

    bool isSecure = await _verifySecurity();
    if (!isSecure) return;

    if (todayDate.weekday == DateTime.sunday) {
      _showInfoDialog(
        'Hari Libur',
        'Sistem menolak. Anda tidak dapat membuat pengajuan Izin / Sakit pada hari libur (Minggu).',
      );
      return;
    }

    if (_isTanggalMerah(todayDate)) {
      _showInfoDialog(
        'Libur Nasional',
        'Sistem menolak. Anda tidak dapat membuat pengajuan Izin / Sakit pada hari Libur Nasional.',
      );
      return;
    }

    String? companyHolidayReason = _getCompanyHolidayReason(todayDate);
    if (companyHolidayReason != null) {
      _showInfoDialog(
        'Kantor Diliburkan',
        'Sistem menolak. Anda tidak dapat membuat pengajuan Izin / Sakit karena kantor sedang libur.\n\nKeterangan: $companyHolidayReason',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaveRequestScreen()),
    );
  }

  Future<void> _goToOvertimeRequest() async {
    DateTime todayDate = DateTime.now();

    bool isSecure = await _verifySecurity();
    if (!isSecure) return;

    if (todayDate.weekday == DateTime.sunday) {
      _showInfoDialog(
        'Hari Libur',
        'Sistem menolak. Anda tidak dapat mengajukan lembur pada hari libur (Minggu).',
      );
      return;
    }

    if (_isTanggalMerah(todayDate)) {
      _showInfoDialog(
        'Libur Nasional',
        'Sistem menolak. Anda tidak dapat mengajukan lembur pada hari Libur Nasional.',
      );
      return;
    }

    String? companyHolidayReason = _getCompanyHolidayReason(todayDate);
    if (companyHolidayReason != null) {
      _showInfoDialog(
        'Kantor Diliburkan',
        'Sistem menolak. Anda tidak dapat mengajukan lembur karena kantor sedang libur.\n\nKeterangan: $companyHolidayReason',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Color(0xFF1E63D8))),
    );

    try {
      AttendanceService service = AttendanceService();

      List<dynamic> leaves = await service.getLeaveHistory();
      List<dynamic> history = await service.getHistory();

      Navigator.pop(context);

      String todayStr = DateFormat('yyyy-MM-dd').format(todayDate);
      DateTime today = DateTime.parse(todayStr);

      bool hasLeaveToday = false;
      String leaveStatus = '';

      for (var leave in leaves) {
        DateTime start = DateTime.parse(leave['start_date']);
        DateTime end = DateTime.parse(leave['end_date']);
        if ((today.isAtSameMomentAs(start) || today.isAfter(start)) &&
            (today.isAtSameMomentAs(end) || today.isBefore(end))) {
          if (leave['status'] != 'rejected') {
            hasLeaveToday = true;
            leaveStatus = leave['status'];
            break;
          }
        }
      }

      if (hasLeaveToday) {
        String statusText = leaveStatus == 'approved'
            ? 'DISETUJUI'
            : 'MENUNGGU PERSETUJUAN';
        _showInfoDialog(
          'Tidak Dapat Lembur',
          'Anda terdata sedang Izin/Sakit hari ini (Status: $statusText).\n\nSistem menolak pengajuan lembur pada saat status Anda tidak hadir.',
        );
        return;
      }

      var todayRecord;
      for (var item in history) {
        if (item['date'] == todayStr) {
          todayRecord = item;
          break;
        }
      }

      if (todayRecord == null || todayRecord['time_in'] == null) {
        _showInfoDialog(
          'Belum Presensi Masuk',
          'Sistem menolak. Anda harus melakukan Presensi Masuk terlebih dahulu pada hari ini sebelum dapat mengajukan formulir lembur.',
        );
        return;
      }
    } catch (e) {
      Navigator.pop(context);
      _showInfoDialog('Error', 'Gagal memverifikasi data kehadiran.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OvertimeRequestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime todayDate = DateTime.now();
    final currentDateStr = DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(todayDate);

    final bool isSunday = todayDate.weekday == DateTime.sunday;
    final bool isNationalHoliday = _isTanggalMerah(todayDate);

    final String? companyHolidayReason = _getCompanyHolidayReason(todayDate);
    final bool isCompanyHoliday = companyHolidayReason != null;

    final bool isHoliday = isSunday || isNationalHoliday || isCompanyHoliday;

    String jamKerjaText = '';
    Color jamKerjaColor = Colors.white;
    IconData jamKerjaIcon = Icons.access_time;

    if (isCompanyHoliday) {
      jamKerjaText = 'LIBUR: $companyHolidayReason';
      jamKerjaColor = Colors.redAccent.shade100;
      jamKerjaIcon = Icons.event_busy;
    } else if (isSunday) {
      jamKerjaText = 'Hari Libur (Minggu)';
      jamKerjaColor = Colors.redAccent.shade100;
      jamKerjaIcon = Icons.event_busy;
    } else if (isNationalHoliday) {
      jamKerjaText = 'Hari Libur Nasional';
      jamKerjaColor = Colors.redAccent.shade100;
      jamKerjaIcon = Icons.event_busy;
    } else if (_jamMasuk == null || _jamPulang == null) {
      jamKerjaText = 'Memuat jam kerja...';
      jamKerjaColor = Colors.white70;
    } else {
      jamKerjaText = 'Jam Kerja: $_jamMasuk - $_jamPulang';
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Color(0xFF1E63D8),
          backgroundColor: Theme.of(context).cardColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage:
                          _photoPath.isNotEmpty && _photoPath != '-'
                          ? NetworkImage('$_storageBaseUrl$_photoPath')
                          : NetworkImage(
                                  'https://ui-avatars.com/api/?name=$_userName&background=1E63D8&color=fff',
                                )
                                as ImageProvider,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            _userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF3B82F6).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.notifications_active,
                              color: Color(0xFF3B82F6),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationScreen(),
                                ),
                              ).then((_) => _fetchUnreadCount());
                            },
                          ),
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  _unreadCount > 99 ? '99+' : '$_unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E63D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1E63D8).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentDateStr,
                        style: TextStyle(
                          color: Colors.blue.shade100,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _currentTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isHoliday
                              ? Colors.red.withOpacity(0.3)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHoliday
                                ? Colors.redAccent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(jamKerjaIcon, color: jamKerjaColor, size: 16),
                            SizedBox(width: 8),
                            Text(
                              jamKerjaText,
                              style: TextStyle(
                                color: jamKerjaColor,
                                fontSize: 13,
                                fontWeight: isHoliday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontStyle:
                                    (!isHoliday &&
                                        (_jamMasuk == null ||
                                            _jamPulang == null))
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Menu Presensi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSquareButton(
                        title: 'Presensi Masuk',
                        icon: Icons.login_rounded,
                        iconColor: Colors.greenAccent.shade400,
                        bgColor: isDark
                            ? Color(0xFF102A1A)
                            : Colors.green.shade50,
                        onTap: () => _goToMapAttendance('Masuk'),
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildSquareButton(
                        title: 'Presensi Pulang',
                        icon: Icons.logout_rounded,
                        iconColor: Colors.deepOrangeAccent,
                        bgColor: isDark
                            ? Color(0xFF3A1612)
                            : Colors.orange.shade50,
                        onTap: () => _goToMapAttendance('Keluar'),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _goToLeaveRequest,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: !isDark
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Color(0xFF1A253A)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.assignment_late,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengajuan Izin / Sakit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Formulir Pengajuan Izin',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: _goToOvertimeRequest,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: !isDark
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Color(0xFF2D1B4E)
                                : Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.more_time_rounded,
                            color: Colors.purple.shade400,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengajuan Lembur',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Formulir Catatan Waktu Lembur',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
