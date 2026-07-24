import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/attendance_service.dart';
import 'leave_history_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _reasonController = TextEditingController();
  String _selectedLeaveType = 'Izin';
  DateTime? _startDate;
  DateTime? _endDate;
  File? _attachment;
  bool _isLoading = false;

  final List<String> _leaveTypes = ['Izin', 'Sakit', 'Lainnya'];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime.now().add(Duration(days: 90)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: Color(0xFF3B82F6),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: Color(0xFF1E1E1E),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color(0xFF1E63D8),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (mounted) {
        setState(() {
          if (isStartDate) {
            _startDate = picked;
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = null;
            }
          } else {
            if (_startDate != null && picked.isBefore(_startDate!)) {
              _showErrorSnackBar(
                'Tanggal selesai tidak boleh sebelum tanggal mulai',
              );
            } else {
              _endDate = picked;
            }
          }
        });
      }
    }
  }

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      if (mounted) {
        setState(() {
          _attachment = File(result.files.single.path!);
        });
      }
    }
  }

  void _showErrorSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _submitRequest() async {
    if (_startDate == null ||
        _endDate == null ||
        _reasonController.text.isEmpty) {
      _showErrorSnackBar('Harap isi tanggal mulai, selesai, dan alasan');
      return;
    }

    if (_selectedLeaveType == 'Sakit' && _attachment == null) {
      _showErrorSnackBar('Wajib melampirkan Surat Dokter untuk izin Sakit');
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    AttendanceService service = AttendanceService();

    String reqStartStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    List<dynamic> attendanceHistory = await service.getHistory();

    bool alreadyAttended = attendanceHistory.any(
      (record) => record['date'] == reqStartStr,
    );

    if (alreadyAttended && _attachment == null) {
      if (mounted) setState(() => _isLoading = false);
      _showErrorDialog(
        'Bukti Wajib Dilampirkan!',
        'Anda sudah melakukan Presensi Masuk hari ini. Pengajuan ini akan dicatat sebagai Izin Pulang Cepat.\n\nHarap lampirkan bukti pendukung agar Admin dapat menyetujuinya.',
      );
      return;
    }

    List<dynamic> existingLeaves = await service.getLeaveHistory();
    bool isOverlapping = false;

    for (var leave in existingLeaves) {
      if (leave['status'] == 'rejected') continue;

      DateTime start = DateTime.parse(leave['start_date']);
      DateTime end = DateTime.parse(leave['end_date']);

      if ((_startDate!.isAtSameMomentAs(start) || _startDate!.isAfter(start)) &&
              (_startDate!.isAtSameMomentAs(end) ||
                  _startDate!.isBefore(end)) ||
          (_endDate!.isAtSameMomentAs(start) || _endDate!.isAfter(start)) &&
              (_endDate!.isAtSameMomentAs(end) || _endDate!.isBefore(end)) ||
          (start.isAfter(_startDate!) && start.isBefore(_endDate!))) {
        isOverlapping = true;
        break;
      }
    }

    if (isOverlapping) {
      if (mounted) setState(() => _isLoading = false);
      _showErrorSnackBar(
        'Tanggal yang Anda pilih tumpang tindih dengan pengajuan lain',
      );
      return;
    }

    var result = await service.sendLeaveRequest(
      _selectedLeaveType,
      DateFormat('yyyy-MM-dd').format(_startDate!),
      DateFormat('yyyy-MM-dd').format(_endDate!),
      _reasonController.text,
      _attachment,
    );

    if (mounted) setState(() => _isLoading = false);

    if (result['success']) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Berhasil', style: TextStyle(color: Colors.greenAccent)),
          content: Text(result['message'] ?? 'Pengajuan berhasil diproses'),
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
      _showErrorSnackBar(result['message'] ?? 'Gagal mengirim pengajuan');
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengajuan Izin'),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded),
            tooltip: 'Riwayat Pengajuan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaveHistoryScreen()),
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
                  _buildSectionTitle('Jenis Pengajuan'),
                  SizedBox(height: 12),
                  _buildLeaveTypeDropdown(),
                  SizedBox(height: 24),
                  _buildSectionTitle('Pilih Tanggal'),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateInput(
                          'Mulai',
                          _startDate,
                          () => _selectDate(context, true),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildDateInput(
                          'Selesai',
                          _endDate,
                          () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  _buildSectionTitle('Alasan'),
                  SizedBox(height: 12),
                  _buildReasonInput(),
                  SizedBox(height: 24),
                  _buildSectionTitle('Lampiran (Bukti/Surat Dokter)'),
                  SizedBox(height: 12),
                  _buildAttachmentPicker(),
                  SizedBox(height: 40),
                  _buildSubmitButton(),
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

  Widget _buildLeaveTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLeaveType,
          items: _leaveTypes
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) {
            if (value != null && mounted) {
              setState(() {
                _selectedLeaveType = value;
              });
            }
          },
          dropdownColor: Theme.of(context).cardColor,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildDateInput(String label, DateTime? date, VoidCallback onTap) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 8),
            Text(
              date == null ? 'Pilih' : DateFormat('dd/MM/yyyy').format(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: date == null ? Colors.grey : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: _reasonController,
      maxLines: 5,
      decoration: InputDecoration(
        fillColor: Theme.of(context).cardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
    );
  }

  Widget _buildAttachmentPicker() {
    return InkWell(
      onTap: _pickAttachment,
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
            Icon(Icons.attach_file, color: Colors.grey),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                _attachment == null
                    ? 'Unggah Foto/PDF'
                    : _attachment!.path.split('/').last,
                style: TextStyle(
                  color: _attachment == null ? Colors.grey : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_attachment != null)
              Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFF1E63D8),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Kirim Pengajuan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
