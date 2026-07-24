import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';
import 'services/notification_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notifikasi masuk saat aplikasi ditutup: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeDateFormatting('id_ID', null);

  await NotificationService().initNotification();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? themeIndex = prefs.getInt('theme_mode');

  if (themeIndex == 1) {
    themeNotifier.value = ThemeMode.light;
  } else if (themeIndex == 2) {
    themeNotifier.value = ThemeMode.dark;
  } else {
    themeNotifier.value = ThemeMode.system;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Presensi Candratama',
          debugShowCheckedModeBanner: false,

          navigatorKey: navigatorKey,

          builder: (context, child) {
            return GlobalInternetWrapper(child: child!);
          },

          themeMode: currentMode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey.shade100,
            primaryColor: Color(0xFF1E63D8),
            cardColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E63D8),
              secondary: Colors.orange,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF1E63D8),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF1E63D8),
              unselectedItemColor: Colors.grey.shade400,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Color(0xFF121212),
            primaryColor: Color(0xFF1E63D8),
            cardColor: Color(0xFF1E1E1E),
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF1E63D8),
              secondary: Colors.orange,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFF1E63D8),
              unselectedItemColor: Colors.grey.shade600,
            ),
          ),

          home: SplashScreen(),
        );
      },
    );
  }
}

class GlobalInternetWrapper extends StatefulWidget {
  final Widget child;
  const GlobalInternetWrapper({Key? key, required this.child})
    : super(key: key);

  @override
  _GlobalInternetWrapperState createState() => _GlobalInternetWrapperState();
}

class _GlobalInternetWrapperState extends State<GlobalInternetWrapper> {
  bool _hasInternet = true;

  bool _isServerUp = true;
  bool _isCheckingServer = false;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();

    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _hasInternet = !result.contains(ConnectivityResult.none);
        });

        if (_hasInternet) {
          _checkServerStatus();
        }
      }
    });
  }

  Future<void> _checkServerStatus() async {
    if (!_hasInternet) return;

    setState(() {
      _isCheckingServer = true;
    });

    try {
      final url = Uri.parse('${ApiConfig.apiUrl}/pengaturan-absensi');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 500) {
        if (mounted)
          setState(() {
            _isServerUp = true;
            _isCheckingServer = false;
          });
          
      } else {
        if (mounted)
          setState(() {
            _isServerUp = false;
            _isCheckingServer = false;
          });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isServerUp = false;
          _isCheckingServer = false;
        });
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,

        if (!_hasInternet)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.95),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.redAccent,
                            size: 80,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Koneksi Terputus',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aplikasi Presensi Online Candratama memerlukan koneksi internet untuk beroperasi.\n\nSilakan periksa jaringan Wi-Fi atau Data Seluler Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 40),
                        CircularProgressIndicator(color: Color(0xFF1E63D8)),
                        SizedBox(height: 16),
                        Text(
                          'Menunggu sinyal...',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else if (!_isServerUp)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.95),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.dns_rounded, // Icon Server
                            color: Colors.redAccent,
                            size: 80,
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Server Tidak Merespons',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aplikasi terhubung ke internet, namun tidak mendapat respons dari server pusat. Server mungkin sedang terjadi gangguan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            onPressed: _isCheckingServer
                                ? null
                                : _checkServerStatus,
                            icon: _isCheckingServer
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              _isCheckingServer ? 'MENGECEK...' : 'COBA LAGI',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E63D8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
