import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatisticScreen extends StatefulWidget {
  final List<dynamic> fullHistoryData;

  const StatisticScreen({Key? key, required this.fullHistoryData})
    : super(key: key);

  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  // Secara bawaan akan menampilkan bulan saat ini
  DateTime _selectedMonth = DateTime.now();

  // Fungsi untuk memindah bulan (mundur/maju)
  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String monthName = DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth);

    // Format "yyyy-MM" untuk memfilter data
    String filterMonthStr = DateFormat('yyyy-MM').format(_selectedMonth);

    // 1. Filter Data Hanya untuk Bulan yang Ditampilkan
    List<dynamic> monthlyData = widget.fullHistoryData.where((item) {
      return item['date'] != null &&
          item['date'].toString().startsWith(filterMonthStr);
    }).toList();

    // 2. Mengelompokkan Data Berdasarkan Status
    List<dynamic> hadirList = [];
    List<dynamic> telatList = [];
    List<dynamic> izinList = [];
    List<dynamic> alphaList = [];

    for (var item in monthlyData) {
      if (item['status'] == 'hadir') {
        hadirList.add(item);
      } else if (item['status'] == 'terlambat') {
        telatList.add(item);
      } else if (item['status'] == 'izin' || item['status'] == 'sakit') {
        izinList.add(item);
      } else if (item['status'] == 'alpha') {
        alphaList.add(item);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rekap Presensi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Color(0xFF1E63D8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // HEADER PEMILIH BULAN
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFF1E63D8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1E63D8).withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => _changeMonth(-1), // Mundur 1 bulan
                ),
                Text(
                  monthName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => _changeMonth(1), // Maju 1 bulan
                ),
              ],
            ),
          ),

          // KONTEN REKAP (AKORDEON)
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  'Rincian Kehadiran Bulanan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),
                _buildSummaryTile(
                  context,
                  'Hadir Tepat Waktu',
                  hadirList,
                  Colors.green,
                  Icons.check_circle,
                  isDark,
                ),
                SizedBox(height: 16),
                _buildSummaryTile(
                  context,
                  'Terlambat',
                  telatList,
                  Colors.redAccent,
                  Icons.warning_rounded,
                  isDark,
                ),
                SizedBox(height: 16),
                _buildSummaryTile(
                  context,
                  'Izin / Sakit',
                  izinList,
                  Colors.amber.shade700,
                  Icons.sick,
                  isDark,
                ),
                SizedBox(height: 16),
                _buildSummaryTile(
                  context,
                  'Tanpa Keterangan (Alpha)',
                  alphaList,
                  Colors.grey.shade600,
                  Icons.person_off,
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
    BuildContext context,
    String title,
    List<dynamic> data,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: color,
          iconColor: color,
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            '${data.length} Kali',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          children: data.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      'Tidak ada catatan di bulan ini.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ]
              : data.map((item) {
                  DateTime dateObj =
                      DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
                  String formattedDate = DateFormat(
                    'EEEE, dd MMM yyyy',
                    'id_ID',
                  ).format(dateObj);

                  String subtitle = '';
                  if (title == 'Terlambat') {
                    subtitle = 'Jam Masuk: ${item['time_in'] ?? '-'}';
                  } else if (title == 'Izin / Sakit') {
                    subtitle = 'Keterangan: ${item['type'] ?? 'Izin'}';
                  } else if (title == 'Hadir Tepat Waktu') {
                    subtitle = 'Jam Masuk: ${item['time_in'] ?? '-'}';
                  } else if (title == 'Tanpa Keterangan (Alpha)') {
                    subtitle = 'Tanpa Kabar (Bolos)';
                  }

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.withOpacity(0.1)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (subtitle.isNotEmpty) SizedBox(height: 2),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }
}
