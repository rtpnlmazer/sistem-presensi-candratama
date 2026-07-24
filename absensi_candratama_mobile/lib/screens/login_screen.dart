import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../services/auth_service.dart';
import 'main_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand}-${androidInfo.model}-${androidInfo.id}'
            .replaceAll(' ', '');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
    } catch (e) {
      print('Gagal membaca Device ID: $e');
    }
    return 'unknown_device';
  }

  Future<void> _launchWhatsApp() async {
    final String phoneNumber = "628113309933";

    final String message =
        "Halo Admin PT. Candratama Grup Nusantara, saya lupa email/password akun saya. Mohon bantuannya untuk reset data login saya. Terima kasih.";
    final Uri url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorPopUp(
        'Gagal',
        'Aplikasi WhatsApp tidak ditemukan di perangkat ini.',
      );
    }
  }

  void _showErrorPopUp(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 28),
            SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorPopUp(
        'Data Tidak Lengkap',
        'Email dan Password wajib diisi untuk melanjutkan!',
      );
      return;
    }

    setState(() => _isLoading = true);

    String deviceId = await _getDeviceId();

    final result = await _authService.login(
      _emailController.text,
      _passwordController.text,
      deviceId,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      try {
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        if (fcmToken != null) {
          await NotificationService().sendTokenToServer(fcmToken);
          print('Sukses: Token FCM dikirim ke server saat login!');
        }
      } catch (e) {
        print('Gagal mengambil/mengirim FCM Token saat login: $e');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      _showErrorPopUp('Login Gagal', result['message']);
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.support_agent, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text(
              'Lupa Akun?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Untuk alasan keamanan, pemulihan email atau kata sandi hanya dapat dilakukan oleh Admin.\n\nSilakan ketuk tombol di bawah untuk menghubungi Admin PT Candratama Grup Nusantara via WhatsApp.',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _launchWhatsApp();
            },
            icon: Icon(Icons.chat, color: Colors.white, size: 18),
            label: Text(
              'Hubungi WA Admin',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 120, height: 120),
              SizedBox(height: 25),

              Text(
                'PRESENSI ONLINE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PT Candratama Grup Nusantara',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 40),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selamat Datang!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Silakan login untuk melanjutkan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    SizedBox(height: 30),

                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? Color(0xFF2C2C2C)
                            : Colors.grey.shade100,
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? Color(0xFF2C2C2C)
                            : Colors.grey.shade100,
                        hintText: 'Kata Sandi',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: _showForgotPasswordDialog,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Text(
                            'Lupa Password?',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E63D8),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'MASUK SEKARANG',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Versi 1.0.0',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
