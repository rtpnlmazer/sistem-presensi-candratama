import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/attendance_service.dart';
import '../config/api_config.dart';

class MapAttendanceScreen extends StatefulWidget {
  final String type;
  final bool isLate;

  MapAttendanceScreen({required this.type, this.isLate = false});

  @override
  _MapAttendanceScreenState createState() => _MapAttendanceScreenState();
}

class _MapAttendanceScreenState extends State<MapAttendanceScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  File? _imageFile;

  String _deviceInfo = 'Mendeteksi perangkat...';
  String _photoTime = '';
  String _currentAddress = 'Sedang mencari nama lokasi...';

  bool _isLoading = true;
  bool _faceDetected = false;

  LatLng? _officeLocation;
  double? _officeRadius;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getDeviceInfo();
    await _fetchOfficeSettings();
    if (_officeLocation == null || _officeRadius == null) return;
    await _getCurrentLocation();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (mounted) {
        setState(
          () => _deviceInfo = '${androidInfo.brand} ${androidInfo.model}',
        );
      }
    }
  }

  Future<void> _fetchOfficeSettings() async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.apiUrl}/pengaturan-absensi',
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success']) {
          final data = result['data'];
          if (mounted) {
            setState(() {
              _officeLocation = LatLng(
                double.parse(data['office_latitude'].toString()),
                double.parse(data['office_longitude'].toString()),
              );
              _officeRadius = double.parse(data['radius'].toString());
            });
          }
        } else {
          _showFatalErrorDialog(
            'Data Tidak Ditemukan',
            'Gagal memuat aturan presensi dari server.',
          );
        }
      } else {
        _showFatalErrorDialog(
          'Server Bermasalah',
          'Server mengembalikan kode error: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showFatalErrorDialog(
        'Koneksi Terputus',
        'Tidak dapat terhubung ke server. Pastikan internet Anda stabil dan server aplikasi menyala.',
      );
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) {
          setState(() {
            List<String> details = [];
            if (place.street != null && place.street!.isNotEmpty) {
              details.add(place.street!);
            }
            if (place.subLocality != null && place.subLocality!.isNotEmpty) {
              details.add(place.subLocality!);
            }
            if (place.locality != null && place.locality!.isNotEmpty) {
              details.add(place.locality!);
            }
            _currentAddress = details.join(', ');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentAddress = 'Gagal mendapatkan nama lokasi.');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showFatalErrorDialog(
        'GPS Belum Menyala',
        'Harap hidupkan fitur Lokasi (GPS) di pengaturan HP Anda untuk melakukan presensi.',
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showFatalErrorDialog(
          'Akses GPS Ditolak',
          'Aplikasi membutuhkan izin akses lokasi agar bisa mendeteksi jarak Anda dengan kantor.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showFatalErrorDialog(
        'Akses GPS Ditolak',
        'Izin lokasi ditolak secara permanen. Harap buka Pengaturan HP > Aplikasi > Presensi Candratama, lalu izinkan akses lokasi.',
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (position.isMocked) {
      _showFatalErrorDialog(
        'Terdeteksi Fake GPS',
        'Sistem mendeteksi penggunaan aplikasi pemalsu lokasi. Matikan Fake GPS untuk melanjutkan.',
      );
      return;
    }

    if (mounted) {
      setState(() => _currentPosition = position);
      await _getAddressFromLatLng(position);
      setState(() => _isLoading = false);
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            18.0,
          ),
        );
      }
    }
  }

  void _showFatalErrorDialog(String title, String message) {
    if (mounted) setState(() => _isLoading = false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade400,
              size: 28,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade400, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Kembali', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 50,
    );

    if (photo != null) {
      setState(() {
        _isLoading = true;
        _faceDetected = false;
      });

      final inputImage = InputImage.fromFilePath(photo.path);
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (mounted) setState(() => _isLoading = false);

      if (faces.isNotEmpty) {
        final face = faces.first;
        if (face.smilingProbability != null && face.smilingProbability! > 0.4) {
          setState(() {
            _imageFile = File(photo.path);
            _photoTime = DateFormat(
              'HH:mm:ss\ndd MMM yyyy',
            ).format(DateTime.now());
            _faceDetected = true;
          });
        } else {
          setState(() {
            _imageFile = null;
            _faceDetected = false;
          });

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.face_retouching_off,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Senyum Kurang Lebar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Wajah terdeteksi, tetapi Anda tidak tersenyum.\n\nHarap TERSENYUM saat mengambil foto untuk memverifikasi bahwa ini adalah foto asli.',
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Coba Lagi',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() => _imageFile = null);
        _showErrorSnackBar(
          'Wajah tidak ditemukan! Harap hadapkan wajah ke kamera.',
        );
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<Map<String, dynamic>?> _showLateReasonDialog() {
    TextEditingController _reasonController = TextEditingController();
    File? _latePhoto;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStatePopUp) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Anda Terlambat',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu presensi masuk telah melewati batas jam kerja. Harap masukkan alasan keterlambatan beserta foto bukti sebelum mengirim presensi.',
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Ban bocor, macet parah...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: isDark
                          ? Color(0xFF1E1E1E)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Lampirkan Foto Bukti (Wajib):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final source = await showDialog<ImageSource>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Pilih Sumber Foto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.photo_library,
                                  color: Color(0xFF1E63D8),
                                ),
                                title: Text('Pilih dari Galeri'),
                                onTap: () =>
                                    Navigator.pop(context, ImageSource.gallery),
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFF1E63D8),
                                ),
                                title: Text('Ambil dari Kamera'),
                                onTap: () =>
                                    Navigator.pop(context, ImageSource.camera),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (source != null) {
                        final XFile? photo = await picker.pickImage(
                          source: source,
                          imageQuality: 50,
                        );
                        if (photo != null) {
                          setStatePopUp(() => _latePhoto = File(photo.path));
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Color(0xFF1E1E1E)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: _latePhoto != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_latePhoto!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Unggah Bukti',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Batal', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_reasonController.text.trim().isEmpty ||
                      _latePhoto == null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Data Tidak Lengkap',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          'Alasan keterlambatan dan Foto Bukti wajib diisi! Harap berikan penjelasan singkat dan lampirkan bukti mengapa Anda terlambat hari ini.',
                          style: TextStyle(color: Colors.grey, height: 1.5),
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'OK, Saya Paham',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context, {
                    'reason': _reasonController.text.trim(),
                    'photo': _latePhoto,
                  });
                },
                child: Text(
                  'Kirim Presensi',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitAttendance() async {
    if (_imageFile == null || !_faceDetected) {
      _showErrorSnackBar(
        'Wajib mengambil foto selfie dengan wajah yang jelas dan tersenyum!',
      );
      return;
    }

    if (_currentPosition == null ||
        _officeLocation == null ||
        _officeRadius == null) {
      _showErrorSnackBar('Data lokasi belum siap!');
      return;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _officeLocation!.latitude,
      _officeLocation!.longitude,
    );

    if (distanceInMeters > _officeRadius!) {
      _showErrorSnackBar(
        'Anda berada di luar area kantor! Jarak Anda: ${distanceInMeters.toStringAsFixed(0)} meter dari batas toleransi ${_officeRadius!} meter.',
      );
      return;
    }

    String? finalLateReason;
    File? finalLatePhoto;

    if (widget.type == 'Masuk' && widget.isLate) {
      final lateData = await _showLateReasonDialog();
      if (lateData == null) {
        return;
      }
      finalLateReason = lateData['reason'];
      finalLatePhoto = lateData['photo'];
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: widget.type == 'Masuk' ? Colors.green : Colors.deepOrange,
        ),
      ),
    );

    AttendanceService service = AttendanceService();
    var result = await service.sendAttendance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _imageFile!,
      widget.type,
      finalLateReason,
      finalLatePhoto,
    );

    Navigator.pop(context);

    if (result['success']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Presensi Berhasil',
            style: TextStyle(color: Colors.greenAccent),
          ),
          content: Text(
            '${result['message']}\n\nPerangkat:\n$_deviceInfo',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
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
      bool isServerError = result['message'].toString().toLowerCase().contains(
        'gagal terhubung',
      );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isServerError
                    ? Icons.wifi_off_rounded
                    : Icons.warning_amber_rounded,
                color: Colors.red.shade400,
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  isServerError ? 'Koneksi Bermasalah' : 'Presensi Ditolak',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isServerError
                ? 'Tidak dapat terhubung ke server. Pastikan koneksi internet Anda stabil.'
                : result['message'],
            style: TextStyle(color: Colors.grey.shade400, height: 1.5),
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
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = widget.type == 'Masuk'
        ? Colors.green.shade600
        : Colors.deepOrange.shade600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Presensi ${widget.type}'),
        backgroundColor: primaryColor,
      ),
      body:
          (_currentPosition == null ||
              _officeLocation == null ||
              _officeRadius == null)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Menyiapkan area presensi...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 18.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                  circles: {
                    Circle(
                      circleId: CircleId('office_radius'),
                      center: _officeLocation!,
                      radius: _officeRadius!,
                      fillColor: Colors.blue.withOpacity(0.2),
                      strokeColor: Colors.blue,
                      strokeWidth: 2,
                    ),
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentAddress,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _isLoading ? null : _takePhoto,
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: _isLoading
                                        ? Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : _imageFile == null
                                        ? Icon(
                                            Icons.camera_alt,
                                            color: Colors.grey.shade400,
                                            size: 28,
                                          )
                                        : Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.file(
                                                  _imageFile!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          bottom:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Text(
                                                    _photoTime,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 22,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : _submitAttendance,
                                    child: Text(
                                      _isLoading
                                          ? 'MEMPROSES...'
                                          : 'KIRIM SEKARANG',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        color: _faceDetected
                            ? Colors.green.shade700
                            : Colors.transparent,
                        child: Text(
                          _faceDetected ? 'Wajah Terverifikasi!' : '',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
