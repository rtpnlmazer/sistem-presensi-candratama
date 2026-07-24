import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _oldPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  void _submitChangePassword() async {
    if (_oldPassCtrl.text.isEmpty ||
        _newPassCtrl.text.isEmpty ||
        _confirmPassCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua kolom wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konfirmasi kata sandi baru tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kata sandi baru minimal 6 karakter!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.changePassword(
      _oldPassCtrl.text,
      _newPassCtrl.text,
      _confirmPassCtrl.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Berhasil!', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Text(result['message']),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark ? Color(0xFF1E1E1E) : Colors.transparent;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ubah Kata Sandi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E63D8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1E63D8).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset,
                  size: 60,
                  color: Color(0xFF1E63D8),
                ),
              ),
            ),
            SizedBox(height: 30),

            Text(
              'Keamanan Akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Pastikan kata sandi baru Anda unik dan mudah diingat.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 24),

            Text(
              'Kata Sandi Lama',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _oldPassCtrl,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: 'Masukkan kata sandi lama',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureOld ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Kata Sandi Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _newPassCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: 'Minimal 6 karakter',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(Icons.lock_reset, color: Color(0xFF3B82F6)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),

            Text(
              'Konfirmasi Kata Sandi Baru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmPassCtrl,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                filled: true,
                fillColor: inputFillColor,
                hintText: 'Ulangi kata sandi baru',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: Icon(
                  Icons.check_circle_outline,
                  color: Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E63D8),
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _submitChangePassword,
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'SIMPAN KATA SANDI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
