import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import 'overtime_history_screen.dart';

class OvertimeRequestScreen extends StatefulWidget {
  const OvertimeRequestScreen({Key? key}) : super(key: key);

  @override
  _OvertimeRequestScreenState createState() => _OvertimeRequestScreenState();
}

class _OvertimeRequestScreenState extends State<OvertimeRequestScreen> {
  final _reasonController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _showErrorSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(height: 1.5, color: Colors.grey),
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
            child: Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_selectedDate == null ||
        _startTime == null ||
        _endTime == null ||
        _reasonController.text.trim().isEmpty) {
      _showErrorSnackBar('Harap lengkapi tanggal, jam lembur, dan alasan!');
      return;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (endMinutes <= startMinutes) {
      _showErrorSnackBar(
        'Jam selesai lembur harus lebih besar dari jam mulai!',
      );
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    AttendanceService service = AttendanceService();
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    List<dynamic> existingOvertimes = await service.getOvertimeHistory();
    bool isOverlapping = false;
    
    for (var overtime in existingOvertimes) {
      if (overtime['status'] == 'rejected') continue;
      
      if (overtime['date'] == dateStr) {
        isOverlapping = true;
        break;
      }
    }

    if (isOverlapping) {
      if (mounted) setState(() => _isLoading = false);
      _showErrorDialog(
        'Pengajuan Ganda!',
        'Anda sudah memiliki pengajuan lembur untuk tanggal ini (Status: Menunggu/Disetujui).\n\nSistem menolak pengajuan ganda pada hari yang sama.',
      );
      return;
    }

    String startTimeStr =
        '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00';
    String endTimeStr =
        '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00';

    var result = await service.sendOvertime(
      dateStr,
      startTimeStr,
      endTimeStr,
      _reasonController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);
    
    if (result['success']) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Berhasil', style: TextStyle(color: Colors.greenAccent)),
          content: Text(result['message'] ?? 'Pengajuan lembur berhasil diproses'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                Navigator.pop(context, true); 
              },
              child: Text('OK', style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        ),
      );
    } else {
      _showErrorSnackBar(result['message'] ?? 'Gagal mengirim pengajuan lembur');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Formulir Lembur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFF1E63D8),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded),
            tooltip: 'Riwayat Lembur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OvertimeHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? Color(0xFF3B82F6) : Color(0xFF1E63D8),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tanggal Lembur'),
                  SizedBox(height: 12),
                  _buildPickerInput(
                    label: _selectedDate == null
                        ? 'Pilih Tanggal'
                        : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                    icon: Icons.calendar_today,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 24),

                  _buildSectionTitle('Durasi Lembur'),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerInput(
                          label: _startTime == null
                              ? 'Jam Mulai'
                              : _startTime!.format(context),
                          icon: Icons.access_time,
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildPickerInput(
                          label: _endTime == null
                              ? 'Jam Selesai'
                              : _endTime!.format(context),
                          icon: Icons.access_time_filled,
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  _buildSectionTitle('Pekerjaan / Keterangan Lembur'),
                  SizedBox(height: 12),
                  TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Menyelesaikan laporan akhir bulan...',
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Color(0xFF3B82F6)
                            : Color(0xFF1E63D8),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kirim Pengajuan Lembur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
      ),
    );
  }

  Widget _buildPickerInput({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF1E63D8), size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}