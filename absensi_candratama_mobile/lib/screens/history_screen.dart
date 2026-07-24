import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:table_calendar/table_calendar.dart';
import 'statistic_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _historyList = [];
  bool _isLoading = true;

  bool _isCalendarView = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int _selectedYear = DateTime.now().year;
  List<int> _availableYears = [];

  final String _storageBaseUrl = ApiConfig.storageUrl;

  Map<String, String> _liburNasional = {};
  final String _googleApiKey = 'AIzaSyAfW 8jltYDADAxEpQE_h0uPfxawKrRHyG4';

  Future<void> _fetchLiburNasional() async {
    Map<String, String> liburValid = {};
    try {
      int currentYear = DateTime.now().year;
      String calendarId = Uri.encodeComponent(
        'id.indonesian#holiday@group.v.calendar.google.com',
      );
      String timeMin = '${currentYear - 1}-01-01T00:00:00Z';
      String timeMax = '${currentYear + 1}-12-31T23:59:59Z';
      String url =
          'https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?key=$_googleApiKey&timeMin=$timeMin&timeMax=$timeMax';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        for (var item in items) {
          String summary = item['summary']?.toString() ?? 'Libur Nasional';
          String summaryLower = summary.toLowerCase();

          String dateStr = '';
          if (item['start']['date'] != null) {
            dateStr = item['start']['date'].toString().substring(0, 10);
          } else if (item['start']['dateTime'] != null) {
            DateTime dt = DateTime.parse(
              item['start']['dateTime'].toString(),
            ).toLocal();
            dateStr = DateFormat('yyyy-MM-dd').format(dt);
          }

          if (summaryLower.contains('cuti bersama') ||
              summaryLower.contains('puasa') ||
              summaryLower.contains('ramadhan')) {
            continue;
          }

          if (dateStr.isNotEmpty) {
            liburValid[dateStr] = summary;
          }
        }
      }
    } catch (e) {
      print('Gagal memuat Google Calendar: $e');
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token != null) {
        final res = await ApiService.get(
          '${ApiConfig.apiUrl}/company-holidays',
        );
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final List<dynamic> holidays = data['data'] ?? [];
          for (var h in holidays) {
            DateTime start = DateTime.parse(h['start_date']);
            DateTime end = DateTime.parse(h['end_date']);
            String holidayName =
                h['title'] ??
                h['name'] ??
                h['keterangan'] ??
                'Libur Perusahaan';

            for (int i = 0; i <= end.difference(start).inDays; i++) {
              String dateStr = DateFormat(
                'yyyy-MM-dd',
              ).format(start.add(Duration(days: i)));
              liburValid[dateStr] = holidayName;
            }
          }
        }
      }
    } catch (e) {
      print('Gagal memuat Libur Perusahaan: $e');
    }

    if (mounted) setState(() => _liburNasional = liburValid);
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _generateYearList();
    _fetchHistory();
  }

  void _generateYearList() {
    int currentYear = DateTime.now().year;
    for (int i = currentYear + 1; i >= currentYear - 5; i--) {
      _availableYears.add(i);
    }
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    await _fetchLiburNasional();

    final history = await _attendanceService.getHistory();
    final leaves = await _attendanceService.getLeaveHistory();
    List<dynamic> combinedList = List.from(history);

    for (var leave in leaves) {
      if (leave['status'] == 'approved') {
        DateTime start = DateTime.parse(leave['start_date']);
        DateTime end = DateTime.parse(leave['end_date']);

        for (int i = 0; i <= end.difference(start).inDays; i++) {
          DateTime leaveDate = start.add(Duration(days: i));
          String dateStr = DateFormat('yyyy-MM-dd').format(leaveDate);

          int existingIndex = combinedList.indexWhere(
            (item) => item['date'] == dateStr,
          );

          if (existingIndex == -1) {
            combinedList.add({
              'date': dateStr,
              'status': leave['type'].toString().toLowerCase() == 'sakit'
                  ? 'sakit'
                  : 'izin',
              'time_in': '-',
              'time_out': '-',
              'type': leave['type'],
              'reason': leave['reason'],
              'photo_in': leave['attachment'],
              'is_full_day_leave': true,
            });
          } else {
            combinedList[existingIndex]['is_half_day_leave'] = true;
            combinedList[existingIndex]['leave_reason'] = leave['reason'];
            combinedList[existingIndex]['leave_attachment'] =
                leave['attachment'];
            combinedList[existingIndex]['type'] = leave['type'];
          }
        }
      }
    }

    if (combinedList.isNotEmpty) {
      DateTime firstRecordDate = DateTime.now();
      for (var item in combinedList) {
        DateTime itemDate =
            DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
        if (itemDate.isBefore(firstRecordDate)) firstRecordDate = itemDate;
      }

      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(Duration(days: 1));
      DateTime startDate = firstRecordDate;

      if (yesterday.isAfter(startDate) ||
          yesterday.isAtSameMomentAs(startDate)) {
        for (int i = 0; i <= yesterday.difference(startDate).inDays; i++) {
          DateTime checkDate = startDate.add(Duration(days: i));

          if (checkDate.weekday == DateTime.sunday) continue;

          String dateStr = DateFormat('yyyy-MM-dd').format(checkDate);

          if (_liburNasional.containsKey(dateStr)) continue;

          bool hasRecord = combinedList.any((item) => item['date'] == dateStr);
          if (!hasRecord) {
            combinedList.add({
              'date': dateStr,
              'status': 'alpha',
              'time_in': '-',
              'time_out': '-',
              'type': 'Alpha',
              'reason': 'Tidak hadir tanpa keterangan (Bolos).',
              'photo_in': null,
            });
          }
        }
      }
    }

    combinedList.sort((a, b) => b['date'].compareTo(a['date']));

    if (mounted) {
      setState(() {
        _historyList = combinedList;
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    String dateStr = DateFormat('yyyy-MM-dd').format(day);
    return _historyList.where((item) => item['date'] == dateStr).toList();
  }

  void _showImageModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttendanceDetail(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isAlpha = data['status'] == 'alpha';
    bool isFullDayLeave = data['is_full_day_leave'] == true;
    bool isHalfDayLeave = data['is_half_day_leave'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAlpha
                            ? 'Detail Alpha'
                            : (isFullDayLeave
                                  ? 'Detail Izin (Full Day)'
                                  : (isHalfDayLeave
                                        ? 'Izin Pulang Cepat'
                                        : 'Detail Presensi')),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        data['date'] ?? '-',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAlpha
                          ? Colors.grey.withOpacity(0.2)
                          : ((isFullDayLeave || isHalfDayLeave)
                                ? Colors.amber.withOpacity(0.1)
                                : (data['status'] == 'terlambat'
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.green.withOpacity(0.1))),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isAlpha
                          ? 'ALPHA'
                          : ((isFullDayLeave || isHalfDayLeave)
                                ? (data['type'] ?? 'IZIN').toUpperCase()
                                : (data['status'] ?? '').toUpperCase()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isAlpha
                            ? Colors.grey.shade700
                            : ((isFullDayLeave || isHalfDayLeave)
                                  ? Colors.amber.shade700
                                  : (data['status'] == 'terlambat'
                                        ? Colors.red
                                        : Colors.green)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Divider(color: Colors.grey.withOpacity(0.2)),
              SizedBox(height: 16),

              if (isFullDayLeave || isAlpha)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alasan / Keterangan:',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['reason'] ?? '-',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Bukti Lampiran:',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      SizedBox(height: 12),
                      Expanded(
                        child:
                            (data['photo_in'] != null &&
                                data['photo_in'].toString().isNotEmpty)
                            ? GestureDetector(
                                onTap: () => _showImageModal(
                                  context,
                                  '$_storageBaseUrl${data['photo_in']}',
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    '$_storageBaseUrl${data['photo_in']}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    isAlpha
                                        ? 'Tidak ada data'
                                        : 'Tidak ada lampiran',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['status'] == 'terlambat' &&
                            data['late_reason'] != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Alasan Terlambat:',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['late_reason'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.red.shade200
                                              : Colors.red.shade900,
                                          height: 1.5,
                                        ),
                                      ),
                                      if (data['late_photo'] != null) ...[
                                        SizedBox(height: 16),
                                        Text(
                                          'Foto Bukti Terlambat:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        GestureDetector(
                                          onTap: () => _showImageModal(
                                            context,
                                            '$_storageBaseUrl${data['late_photo']}',
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              '$_storageBaseUrl${data['late_photo']}',
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCompactDetailColumn(
                                context,
                                'Absen Masuk',
                                data['time_in'] ?? '-',
                                data['photo_in'],
                                Colors.green,
                                isDark,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 150,
                              color: Colors.grey.withOpacity(0.2),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                            ),
                            Expanded(
                              child: _buildCompactDetailColumn(
                                context,
                                'Absen Pulang',
                                data['time_out'] ?? 'Belum',
                                data['photo_out'],
                                Colors.deepOrange,
                                isDark,
                              ),
                            ),
                          ],
                        ),

                        if (isHalfDayLeave) ...[
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Icon(
                                Icons.assignment_late_outlined,
                                color: Colors.amber.shade700,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Detail Izin Pulang Cepat:',
                                style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alasan Izin:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  data['leave_reason'] ?? '-',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (data['leave_attachment'] != null) ...[
                                  SizedBox(height: 16),
                                  Text(
                                    'Bukti Lampiran (Dokter/Foto):',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => _showImageModal(
                                      context,
                                      '$_storageBaseUrl${data['leave_attachment']}',
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '$_storageBaseUrl${data['leave_attachment']}',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactDetailColumn(
    BuildContext context,
    String title,
    String time,
    String? photoPath,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 16),
        if (photoPath != null && photoPath.isNotEmpty)
          GestureDetector(
            onTap: () => _showImageModal(context, '$_storageBaseUrl$photoPath'),
            child: Container(
              height: 100,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '$_storageBaseUrl$photoPath',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Container(
            height: 100,
            width: 90,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 30,
                ),
                SizedBox(height: 4),
                Text(
                  'No Photo',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBlueHeaderChart(int cTepat, int cTelat, int cIzin, int cAlpha) {
    int totalAbsen = cTepat + cTelat + cIzin + cAlpha;
    String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(_focusedDay);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      decoration: BoxDecoration(
        color: Color(0xFF1E63D8),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1E63D8).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            monthYear,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade100,
                          ),
                        ),
                        Text(
                          '$totalAbsen',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 45,
                        sections: totalAbsen == 0
                            ? [
                                PieChartSectionData(
                                  color: Colors.white.withOpacity(0.2),
                                  value: 1,
                                  title: '',
                                  radius: 12,
                                ),
                              ]
                            : [
                                PieChartSectionData(
                                  color: Colors.greenAccent.shade400,
                                  value: cTepat.toDouble(),
                                  title: '',
                                  radius: 12,
                                ),
                                PieChartSectionData(
                                  color: Colors.redAccent.shade400,
                                  value: cTelat.toDouble(),
                                  title: '',
                                  radius: 12,
                                ),
                                PieChartSectionData(
                                  color: Colors.amber.shade400,
                                  value: cIzin.toDouble(),
                                  title: '',
                                  radius: 12,
                                ),
                                PieChartSectionData(
                                  color: Colors.grey.shade800,
                                  value: cAlpha.toDouble(),
                                  title: '',
                                  radius: 12,
                                ),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendRow(
                      Colors.greenAccent.shade400,
                      'Tepat Waktu',
                      cTepat,
                    ),
                    SizedBox(height: 8),
                    _buildLegendRow(
                      Colors.redAccent.shade400,
                      'Terlambat',
                      cTelat,
                    ),
                    SizedBox(height: 8),
                    _buildLegendRow(
                      Colors.amber.shade400,
                      'Izin / Sakit',
                      cIzin,
                    ),
                    SizedBox(height: 8),
                    _buildLegendRow(
                      Colors.grey.shade800,
                      'Tanpa Keterangan',
                      cAlpha,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.blue.shade100),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(bool isDark, dynamic item) {
    bool isAlpha = item['status'] == 'alpha';
    bool isFullDayLeave = item['is_full_day_leave'] == true;
    bool isHalfDayLeave = item['is_half_day_leave'] == true;
    bool isLate = item['status'] == 'terlambat';

    Color itemColor;
    if (isAlpha)
      itemColor = Colors.grey.shade600;
    else if (isFullDayLeave || isHalfDayLeave)
      itemColor = Colors.amber.shade700;
    else if (isLate)
      itemColor = Colors.redAccent;
    else
      itemColor = Colors.green;

    String statusText = isAlpha
        ? 'Alpha'
        : (isFullDayLeave
              ? (item['type'] ?? 'Izin')
              : (isHalfDayLeave
                    ? 'Pulang Cepat (${item['type']})'
                    : (isLate ? 'Terlambat' : 'Hadir')));

    DateTime dateObj = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
    String dayName = DateFormat('E', 'id_ID').format(dateObj);
    String dateNum = DateFormat('d').format(dateObj);

    return InkWell(
      onTap: () => _showAttendanceDetail(item),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Column(
              children: [
                Text(
                  dateNum,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  dayName,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(width: 16),
            Container(
              height: 40,
              width: 1,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: itemColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isAlpha
                            ? Icons.person_off
                            : ((isFullDayLeave || isHalfDayLeave)
                                  ? Icons.assignment_late
                                  : Icons.access_time),
                        size: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isAlpha
                            ? 'Tanpa Keterangan'
                            : (isFullDayLeave
                                  ? 'Bebas Tugas'
                                  : (item['time_in'] ?? '--:--')),
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int cTepat = 0, cTelat = 0, cIzin = 0, cAlpha = 0;
    String filterMonth = DateFormat('yyyy-MM').format(_focusedDay);

    for (var item in _historyList) {
      if (item['date'] != null &&
          item['date'].toString().startsWith(filterMonth)) {
        if (item['status'] == 'hadir')
          cTepat++;
        else if (item['status'] == 'terlambat')
          cTelat++;
        else if (item['status'] == 'izin' || item['status'] == 'sakit')
          cIzin++;
        else if (item['status'] == 'alpha')
          cAlpha++;
      }
    }

    List<dynamic> displayList = _historyList.where((item) {
      return item['date'] != null &&
          item['date'].toString().startsWith(filterMonth);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Presensi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1E63D8),
        elevation: 0,
        actions: [
          DropdownButton<int>(
            value: _selectedYear,
            dropdownColor: Color(0xFF1E63D8),
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            underline: SizedBox(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedYear = newValue;
                  _focusedDay = DateTime(_selectedYear, _focusedDay.month, 1);
                  _selectedDay = DateTime(_selectedYear, _focusedDay.month, 1);
                });
              }
            },
            items: _availableYears.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: Colors.white),
            tooltip: 'Rekap Presensi Bulanan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticScreen(
                    // Mengirimkan SELURUH data riwayat agar bisa difilter di halaman rekap
                    fullHistoryData: _historyList,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _isCalendarView
                  ? Icons.format_list_bulleted
                  : Icons.calendar_month,
              size: 22,
            ),
            tooltip: _isCalendarView ? 'Mode Daftar' : 'Mode Kalender',
            onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1E63D8)))
          : Column(
              children: [
                _buildBlueHeaderChart(cTepat, cTelat, cIzin, cAlpha),
                Expanded(
                  child: RefreshIndicator(
                    color: Color(0xFF1E63D8),
                    onRefresh: () async {
                      await _fetchHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Data riwayat berhasil diperbarui'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: _isCalendarView
                        ? _buildCalendarView(isDark)
                        : _buildListView(isDark, displayList),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarView(bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: !isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            weekendDays: const [DateTime.sunday],
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            }),
            onPageChanged: (focusedDay) =>
                setState(() => _focusedDay = focusedDay),
            eventLoader: _getEventsForDay,

            holidayPredicate: (day) {
              return _liburNasional.containsKey(
                DateFormat('yyyy-MM-dd').format(day),
              );
            },

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFF1E63D8).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF1E63D8),
                shape: BoxShape.circle,
              ),
              holidayTextStyle: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
              holidayDecoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                shape: BoxShape.circle,
              ),
              markerSize: 6,
            ),

            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                if (day.weekday == DateTime.sunday) {
                  return Center(
                    child: Text(
                      DateFormat('E', 'id_ID').format(day),
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                } else if (day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      DateFormat('E', 'id_ID').format(day),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                return null;
              },
              defaultBuilder: (context, day, focusedDay) {
                if (day.weekday == DateTime.saturday) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }
                return null;
              },
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return const SizedBox();
                dynamic item = events.first;

                Color markerColor;
                if (item['status'] == 'alpha')
                  markerColor = Colors.grey.shade600;
                else if (item['status'] == 'izin' || item['status'] == 'sakit')
                  markerColor = Colors.amber.shade700;
                else if (item['status'] == 'terlambat')
                  markerColor = Colors.redAccent;
                else
                  markerColor = Colors.green;

                return Positioned(
                  bottom: 6,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: markerColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 24),

        Builder(
          builder: (context) {
            String selectedDateStr = DateFormat(
              'yyyy-MM-dd',
            ).format(_selectedDay ?? DateTime.now());
            bool isHoliday = _liburNasional.containsKey(selectedDateStr);
            String holidayName = _liburNasional[selectedDateStr] ?? '';

            if (isHoliday) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_available,
                          color: Colors.redAccent,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hari Libur',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              holidayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark
                                    ? Colors.red.shade200
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),

        if (_selectedDay != null &&
            _getEventsForDay(_selectedDay!).isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Detail Presensi Harian',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildListItem(
              isDark,
              _getEventsForDay(_selectedDay!).first,
            ),
          ),
        ] else if (_selectedDay != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Tidak ada data presensi pada hari ini',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListView(bool isDark, List<dynamic> displayList) {
    if (displayList.isEmpty)
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Text(
              'Belum ada riwayat',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: displayList.length,
      itemBuilder: (context, index) =>
          _buildListItem(isDark, displayList[index]),
    );
  }
}
