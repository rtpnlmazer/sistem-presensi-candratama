import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';

class OvertimeHistoryScreen extends StatefulWidget {
  @override
  _OvertimeHistoryScreenState createState() => _OvertimeHistoryScreenState();
}

class _OvertimeHistoryScreenState extends State<OvertimeHistoryScreen> {
  List<dynamic> _overtimes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOvertimes();
  }

  Future<void> _fetchOvertimes() async {
    setState(() => _isLoading = true);
    try {
      AttendanceService service = AttendanceService();
      List<dynamic> history = await service.getOvertimeHistory();

      if (mounted) {
        setState(() {
          _overtimes = history.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error memuat lembur: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Lembur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Color(0xFF3B82F6) : Color(0xFF1E63D8),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? Color(0xFF3B82F6) : Color(0xFF1E63D8),
              ),
            )
          : RefreshIndicator(
              color: Color(0xFF1E63D8),
              onRefresh: _fetchOvertimes,
              child: _overtimes.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.history_toggle_off,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat pengajuan lembur',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _overtimes.length,
                      itemBuilder: (context, index) {
                        final item = _overtimes[index];

                        Color statusColor;
                        IconData statusIcon;
                        String statusText;

                        if (item['status'] == 'approved') {
                          statusColor = Colors.green;
                          statusIcon = Icons.check_circle;
                          statusText = 'Disetujui';
                        } else if (item['status'] == 'rejected') {
                          statusColor = Colors.redAccent;
                          statusIcon = Icons.cancel;
                          statusText = 'Ditolak';
                        } else {
                          statusColor = Colors.orange;
                          statusIcon = Icons.pending;
                          statusText = 'Menunggu';
                        }

                        String startTime = item['start_time'] != null
                            ? item['start_time'].toString().substring(0, 5)
                            : '-';
                        String endTime = item['end_time'] != null
                            ? item['end_time'].toString().substring(0, 5)
                            : '-';

                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDate(
                                        item['date'] ??
                                            DateTime.now().toString(),
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            size: 14,
                                            color: statusColor,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '$startTime WIB - $endTime WIB',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.blue.shade300
                                            : Colors.blue.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  item['reason'] ?? '-',
                                  style: TextStyle(fontSize: 14),
                                ),
                                if (item['status'] == 'rejected' &&
                                    item['reject_reason'] != null) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Alasan Penolakan: ${item['reject_reason']}',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
