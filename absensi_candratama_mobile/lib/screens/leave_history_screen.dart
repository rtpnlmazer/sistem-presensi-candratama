import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_service.dart';
import '../config/api_config.dart';

class LeaveHistoryScreen extends StatefulWidget {
  @override
  _LeaveHistoryScreenState createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  final AttendanceService _service = AttendanceService();
  List<dynamic> _leaveHistory = [];
  bool _isLoading = true;

  final String _storageBaseUrl = ApiConfig.storageUrl;

  @override
  void initState() {
    super.initState();
    _fetchLeaveHistory();
  }

  Future<void> _fetchLeaveHistory() async {
    setState(() => _isLoading = true);
    final history = await _service.getLeaveHistory();
    if (mounted) {
      setState(() {
        _leaveHistory = history;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu';
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: Colors.white, size: 50),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLeaveDetail(Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    DateTime startDate =
        DateTime.tryParse(item['start_date']) ?? DateTime.now();
    DateTime endDate = DateTime.tryParse(item['end_date']) ?? DateTime.now();
    String dateRange = DateFormat('dd MMMM yyyy', 'id_ID').format(startDate);
    if (startDate != endDate) {
      dateRange +=
          ' - \n${DateFormat('dd MMMM yyyy', 'id_ID').format(endDate)}';
    }
    DateTime createdAt =
        DateTime.tryParse(item['created_at']) ?? DateTime.now();
    String submitDate = DateFormat(
      'dd MMMM yyyy • HH:mm',
      'id_ID',
    ).format(createdAt);

    Color statusColor = _getStatusColor(item['status']);
    String? photoPath = item['attachment'];
    bool isRejected = item['status'] == 'rejected';

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
                  Text(
                    'Detail Pengajuan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(item['status']).toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Divider(color: Colors.grey.withOpacity(0.2)),
              SizedBox(height: 16),

              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    if (isRejected && item['reject_reason'] != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Catatan Penolakan Admin:',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              item['reject_reason'],
                              style: TextStyle(
                                color: Colors.redAccent.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],

                    _buildInfoRow(
                      Icons.category,
                      'Jenis Izin',
                      item['type'],
                      isDark,
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.calendar_month,
                      'Tanggal Izin',
                      dateRange,
                      isDark,
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.access_time,
                      'Waktu Pengajuan',
                      submitDate,
                      isDark,
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Alasan / Keterangan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['reason'],
                        style: TextStyle(height: 1.5, fontSize: 15),
                      ),
                    ),

                    SizedBox(height: 24),
                    Text(
                      'Bukti Lampiran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 12),

                    if (photoPath != null && photoPath.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _showFullScreenImage('$_storageBaseUrl$photoPath');
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                '$_storageBaseUrl$photoPath',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 200,
                                      color: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      child: Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.zoom_out_map,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tidak ada lampiran',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF1E63D8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF1E63D8), size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Pengajuan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1E63D8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF1E63D8)))
          : RefreshIndicator(
              onRefresh: _fetchLeaveHistory,
              color: Color(0xFF1E63D8),
              child: _leaveHistory.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off,
                                size: 80,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat pengajuan',
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
                      padding: EdgeInsets.all(20),
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _leaveHistory.length,
                      itemBuilder: (context, index) {
                        final item = _leaveHistory[index];

                        DateTime startDate =
                            DateTime.tryParse(item['start_date']) ??
                            DateTime.now();
                        DateTime endDate =
                            DateTime.tryParse(item['end_date']) ??
                            DateTime.now();
                        String dateRange = DateFormat(
                          'dd MMM yyyy',
                          'id_ID',
                        ).format(startDate);
                        if (startDate != endDate) {
                          dateRange +=
                              ' - ${DateFormat('dd MMM yyyy', 'id_ID').format(endDate)}';
                        }

                        DateTime createdAt =
                            DateTime.tryParse(item['created_at']) ??
                            DateTime.now();
                        String submitDate = DateFormat(
                          'dd MMM yyyy',
                          'id_ID',
                        ).format(createdAt);

                        Color statusColor = _getStatusColor(item['status']);

                        return InkWell(
                          onTap: () => _showLeaveDetail(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ),
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
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF1E63D8,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          item['type'],
                                          style: TextStyle(
                                            color: Color(0xFF1E63D8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusText(item['status']),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          dateRange,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Alasan: ${item['reason']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 16),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tgl Pengajuan: $submitDate',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Text(
                                            'Lihat Detail',
                                            style: TextStyle(
                                              color: Color(0xFF1E63D8),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFF1E63D8),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
