class AttendanceStatistic {
  final int tepatWaktu;
  final int terlambat;
  final int izinSakit;
  final int alpha;
  final String akumulasiMenitTerlambat;

  AttendanceStatistic({
    required this.tepatWaktu,
    required this.terlambat,
    required this.izinSakit,
    required this.alpha,
    required this.akumulasiMenitTerlambat,
  });

  factory AttendanceStatistic.fromJson(Map<String, dynamic> json) {
    return AttendanceStatistic(
      tepatWaktu: json['tepat_waktu'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      izinSakit: json['izin_sakit'] ?? 0,
      alpha: json['alpha'] ?? 0,
      akumulasiMenitTerlambat: json['akumulasi_menit_terlambat'] ?? '0 Menit',
    );
  }
}
