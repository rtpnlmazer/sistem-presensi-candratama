import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../config/api_config.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  final String _baseUrl = ApiConfig.apiUrl;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('$_baseUrl/notifications');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _notifications = data['data'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }

      await ApiService.post('$_baseUrl/notifications/mark-read');
    } catch (e) {
      print('Error mengambil notifikasi: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String isoDate) {
    DateTime date = DateTime.parse(isoDate).toLocal();
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];

                String title = notif['title'].toString().toLowerCase();
                IconData iconData;
                Color iconColor;
                Color bgColor;

                if (title.contains('disetujui')) {
                  iconData = Icons.check_circle;
                  iconColor = Colors.green;
                  bgColor = Colors.green.withOpacity(0.1);
                } else if (title.contains('ditolak')) {
                  iconData = Icons.cancel;
                  iconColor = Colors.red;
                  bgColor = Colors.red.withOpacity(0.1);
                } else if (title.contains('pengumuman') ||
                    title.contains('libur')) {
                  iconData = Icons.campaign;
                  iconColor = Colors.blue;
                  bgColor = Colors.blue.withOpacity(0.1);
                } else {
                  iconData = Icons.notifications;
                  iconColor = Colors.orange;
                  bgColor = Colors.orange.withOpacity(0.1);
                }

                return Dismissible(
                  key: Key(notif['id']?.toString() ?? index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                  ),

                  onDismissed: (direction) async {
                    final deletedNotif = _notifications[index];
                    final deletedIndex = index;

                    setState(() {
                      _notifications.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifikasi telah dihapus'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    try {
                      final response = await ApiService.delete(
                          '$_baseUrl/notifications/${deletedNotif['id']}'
                      );

                      if (response.statusCode != 200 && response.statusCode != 204) {
                        if (mounted) {
                          setState(() {
                            _notifications.insert(deletedIndex, deletedNotif);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menghapus notifikasi di server'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      print('Error menghapus notifikasi: $e');
                      if (mounted) {
                        setState(() {
                          _notifications.insert(deletedIndex, deletedNotif);
                        });
                      }
                    }
                  },

                  child: Card(
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconData, color: iconColor),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  notif['body'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _formatDate(notif['created_at']),
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
