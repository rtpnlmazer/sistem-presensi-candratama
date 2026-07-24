import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../main.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import '../config/api_config.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Memuat...';
  String _userPosition = 'Memuat...';
  String _userNip = '-';
  String _photoPath = '-';
  String _userEmail = '-';
  String _userPhone = '-';
  String _userAddress = '-';

  final String _storageBaseUrl = ApiConfig.storageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('name') ?? 'Karyawan';
        _userPosition = prefs.getString('position') ?? '-';
        _userNip = prefs.getString('nip') ?? '-';
        _photoPath = prefs.getString('photo_path') ?? '';
        _userEmail = prefs.getString('email') ?? '-';
        _userPhone = prefs.getString('phone') ?? '-';
        _userAddress = prefs.getString('address') ?? '-';
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        print('Error saat logout ke server: $e');
      }
    }

    await prefs.clear();

    Navigator.pop(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: Text('Keluar', style: TextStyle(color: Colors.white)),
              onPressed: () => _logout(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 180,
                margin: EdgeInsets.only(bottom: 50),
                decoration: BoxDecoration(
                  color: Color(0xFF1E63D8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 6,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: _photoPath.isNotEmpty && _photoPath != '-'
                      ? NetworkImage('$_storageBaseUrl$_photoPath')
                      : NetworkImage(
                              'https://ui-avatars.com/api/?name=$_userName&background=1E1E1E&color=fff&size=200',
                            )
                            as ImageProvider,
                ),
              ),
            ],
          ),

          Text(
            _userName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          Text(
            _userPosition,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info Karyawan',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          icon: Icons.badge,
                          title: 'NIK',
                          trailingText: _userNip,
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        _buildListTile(
                          icon: Icons.domain,
                          title: 'Divisi',
                          trailingText: _userPosition,
                          iconColor: Colors.orange,
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        _buildListTile(
                          icon: Icons.email,
                          title: 'Email',
                          trailingText: _userEmail,
                          iconColor: Colors.redAccent,
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        _buildListTile(
                          icon: Icons.phone,
                          title: 'No. Telepon',
                          trailingText: _userPhone,
                          iconColor: Colors.green,
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        _buildListTile(
                          icon: Icons.home,
                          title: 'Alamat',
                          trailingText: _userAddress,
                          iconColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 0,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.dark_mode,
                              color: Colors.purpleAccent,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            'Mode Gelap',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Switch(
                            value: isDark,
                            activeColor: Color(0xFF1E63D8),
                            onChanged: (value) async {
                              themeNotifier.value = value
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setInt('theme_mode', value ? 2 : 1);
                            },
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

                        _buildListTile(
                          icon: Icons.person_outline,
                          title: 'Ubah Profil',
                          subtitle: 'Ganti nama atau foto profil',
                          isArrow: true,
                          iconColor: Colors.blue,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          },
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

                        _buildListTile(
                          icon: Icons.lock,
                          title: 'Ubah Kata Sandi',
                          subtitle: 'Ganti password akun anda',
                          isArrow: true,
                          iconColor: Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.logout, color: Colors.redAccent),
                      label: Text(
                        'KELUAR APLIKASI',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.redAccent.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _confirmLogout,
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

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    bool isArrow = false,
    Color iconColor = Colors.blue,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: subtitle != null ? 4 : 0,
      ),
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 11))
          : null,
      trailing: isArrow
          ? Icon(Icons.chevron_right, color: Colors.grey)
          : ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150),
              child: Text(
                trailingText ?? '',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
      onTap: onTap,
    );
  }
}
