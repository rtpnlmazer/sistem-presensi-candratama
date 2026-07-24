import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _nipCtrl = TextEditingController();
  final TextEditingController _positionCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isUploading = false;
  String _photoPath = '';
  String _userName = '';

  final String _storageBaseUrl = ApiConfig.storageUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'Karyawan';
      _nameCtrl.text = _userName;
      _emailCtrl.text = prefs.getString('email') ?? '';
      _phoneCtrl.text = prefs.getString('phone') ?? '';
      _addressCtrl.text = prefs.getString('address') ?? '';
      _nipCtrl.text = prefs.getString('nip') ?? '-';
      _positionCtrl.text = prefs.getString('position') ?? '-';
      _photoPath = prefs.getString('photo_path') ?? '';
    });
  }

  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Ubah Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  Icons.camera_alt,
                  'Kamera',
                  ImageSource.camera,
                  Colors.blue,
                ),
                _buildPhotoOption(
                  Icons.photo_library,
                  'Galeri',
                  ImageSource.gallery,
                  Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(
    IconData icon,
    String label,
    ImageSource source,
    Color color,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: source);

        if (pickedFile != null) {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: pickedFile.path,
            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
            compressQuality: 70,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Potong Foto',
                toolbarColor: Color(0xFF1E63D8),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
              ),
              IOSUiSettings(title: 'Potong Foto', aspectRatioLockEnabled: true),
            ],
          );

          if (croppedFile != null) {
            setState(() => _isUploading = true);
            final result = await _authService.updateProfilePhoto(
              File(croppedFile.path),
            );

            if (result['success']) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('photo_path', result['photo_path']);

              setState(() {
                _photoPath = result['photo_path'];
                _isUploading = false;
              });
            } else {
              setState(() => _isUploading = false);
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message']),
                backgroundColor: result['success'] ? Colors.green : Colors.red,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _submitUpdate() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nama tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nomor Telepon tidak boleh kosong!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.updateProfile(
      _nameCtrl.text,
      _emailCtrl.text,
      _phoneCtrl.text,
      _addressCtrl.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameCtrl.text);
      await prefs.setString('email', _emailCtrl.text);
      await prefs.setString('phone', _phoneCtrl.text);
      await prefs.setString('address', _addressCtrl.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
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
          'Ubah Profil',
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
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF1E63D8).withOpacity(0.2),
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage:
                          _photoPath.isNotEmpty && _photoPath != '-'
                          ? NetworkImage('$_storageBaseUrl$_photoPath')
                          : NetworkImage(
                                  'https://ui-avatars.com/api/?name=$_userName&background=1E63D8&color=fff&size=200',
                                )
                                as ImageProvider,
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: _changeProfilePhoto,
                    child: Container(
                      margin: EdgeInsets.only(right: 0, bottom: 0),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1E63D8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            Text(
              'Nama Lengkap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: _inputDecoration(
                inputFillColor,
                borderColor,
                Icons.person_outline,
              ),
            ),
            SizedBox(height: 20),

            Text(
              'Alamat Email',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                inputFillColor,
                borderColor,
                Icons.email_outlined,
              ),
            ),
            SizedBox(height: 20),

            Text(
              'Nomor Telepon / WhatsApp',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                inputFillColor,
                borderColor,
                Icons.phone_outlined,
              ),
            ),
            SizedBox(height: 30),

            Text(
              'Alamat Domisili Lengkap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              keyboardType: TextInputType.streetAddress,
              decoration: _inputDecoration(
                inputFillColor,
                borderColor,
                Icons.location_on_outlined,
              ),
            ),
            SizedBox(height: 30),

            Divider(color: borderColor),
            SizedBox(height: 20),

            Text(
              'NIK (Nomor Induk Karyawan)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nipCtrl,
              readOnly: true,
              style: TextStyle(color: Colors.grey),
              decoration: _readOnlyInputDecoration(isDark, Icons.badge),
            ),
            SizedBox(height: 16),

            Text(
              'Divisi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _positionCtrl,
              readOnly: true,
              style: TextStyle(color: Colors.grey),
              decoration: _readOnlyInputDecoration(isDark, Icons.domain),
            ),

            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NIK dan Divisi hanya dapat diubah oleh Admin.',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
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
                onPressed: _isLoading ? null : _submitUpdate,
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
                        'SIMPAN PERUBAHAN',
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

  InputDecoration _inputDecoration(
    Color fillColor,
    Color borderColor,
    IconData icon,
  ) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      prefixIcon: Icon(icon, color: Color(0xFF3B82F6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  InputDecoration _readOnlyInputDecoration(bool isDark, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.black26 : Colors.grey.shade100,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
