<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <title>Rapor Statistik Kehadiran Karyawan PT. Candratama Grup Nusantara - {{ $pegawai->name }}</title>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            font-size: 12px;
            color: #333;
            line-height: 1.5;
        }

        .header-table {
            width: 100%;
            border-bottom: 2px solid #dc2626;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }

        .header-title {
            color: #dc2626;
            margin: 0;
            font-size: 20px;
            font-weight: bold;
        }

        .header-subtitle {
            color: #4b5563;
            margin: 3px 0 0 0;
            font-size: 12px;
            letter-spacing: 1px;
        }

        .info-table {
            width: 100%;
            margin-bottom: 25px;
        }

        .info-table td {
            padding: 4px 0;
        }

        .info-label {
            font-weight: bold;
            color: #4b5563;
            width: 15%;
        }

        .info-value {
            width: 35%;
        }

        .stats-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
            text-align: center;
        }

        .stats-table th {
            background-color: #f3f4f6;
            color: #374151;
            font-size: 10px;
            padding: 10px;
            border: 1px solid #e5e7eb;
            text-transform: uppercase;
        }

        .stats-table td {
            padding: 15px 10px;
            border: 1px solid #e5e7eb;
            font-size: 16px;
        }

        .section-title {
            font-size: 14px;
            color: #111827;
            border-bottom: 1px solid #e5e7eb;
            padding-bottom: 5px;
            margin-bottom: 15px;
            font-weight: bold;
        }

        .alert {
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 12px;
            font-size: 12px;
        }

        .alert-success {
            background-color: #f0fdf4;
            border: 1px dashed #22c55e;
            color: #15803d;
            text-align: center;
            font-size: 13px;
        }

        .alert-danger {
            background-color: #fef2f2;
            border: 1px dashed #ef4444;
            color: #b91c1c;
        }

        .alert-warning {
            background-color: #fffbeb;
            border: 1px dashed #f59e0b;
            color: #b45309;
        }

        .alert-info {
            background-color: #eff6ff;
            border: 1px dashed #3b82f6;
            color: #1d4ed8;
        }

        .kotak-catatan {
            page-break-inside: auto;
        }

        .kotak-catatan li,
        .kotak-catatan p {
            page-break-inside: avoid;
            page-break-after: auto;
        }

        .footer {
            margin-top: 40px;
            text-align: right;
            font-size: 10px;
            color: #9ca3af;
            font-style: italic;
        }
    </style>
</head>

<body>

    <table class="header-table">
        <tr>
            <td style="width: 80px; text-align: left;">
                @if(file_exists(public_path('images/logo.png')))
                    <img src="{{ public_path('images/logo.png') }}" width="65" alt="Logo">
                @endif
            </td>
            <td>
                <h1 class="header-title">PT CANDRATAMA GRUP NUSANTARA</h1>
                <h2 class="header-subtitle">RAPOR STATISTIK KEHADIRAN KARYAWAN</h2>
            </td>
            <td style="text-align: right; font-size: 10px; color: #6b7280; vertical-align: bottom;">
                Dicetak pada:<br>
                <b>{{ \Carbon\Carbon::now('Asia/Jakarta')->translatedFormat('d F Y - H:i') }} WIB</b>
            </td>
        </tr>
    </table>

    <table class="info-table">
        <tr>
            <td class="info-label">Nama Karyawan</td>
            <td class="info-value">: <b>{{ $pegawai->name }}</b></td>
            <td class="info-label">Nomor HP</td>
            <td class="info-value">: {{ $pegawai->phone ?? $pegawai->no_hp ?? '-' }}</td>
        </tr>
        <tr>
            <td class="info-label">Alamat Email</td>
            <td class="info-value">: {{ $pegawai->email }}</td>
            <td class="info-label">Divisi</td>
            <td class="info-value">: {{ $pegawai->jabatan ?? $pegawai->position ?? 'Karyawan' }}</td>
        </tr>
        <tr>
            <td class="info-label">Periode Data</td>
            <td class="info-value">: Karyawan Aktif</td>
            <td class="info-label">NIK</td>
            <td class="info-value">: {{ str_pad($pegawai->id, 4, '0', STR_PAD_LEFT) }}</td>
        </tr>
    </table>

    <table class="stats-table">
        <tr>
            <th style="width: 20%;">Tepat Waktu</th>
            <th style="width: 20%;">Terlambat</th>
            <th style="width: 20%;">Izin / Sakit</th>
            <th style="width: 20%;">Alpha (Tanpa Ket.)</th>
            <th style="width: 20%;">Akumulasi Terlambat</th>
        </tr>
        <tr>
            <td style="color: #15803d;"><b>{{ $hadir }}</b> Hari</td>
            <td style="color: #a16207;"><b>{{ $terlambat }}</b> Hari</td>
            <td style="color: #1d4ed8;"><b>{{ $izin }}</b> Hari</td>
            <td style="color: #b91c1c;"><b>{{ $alpha }}</b> Hari</td>
            <td style="color: #b91c1c;"><b>{{ $teksTerlambat }}</b></td>
        </tr>
    </table>

    <h3 class="section-title">Catatan Kedisiplinan</h3>

    @if($alpha > 0)
        <div class="alert alert-danger kotak-catatan">
            <strong>PERHATIAN PENTING:</strong> Karyawan ini memiliki rekam jejak <b>Alpha (Tanpa Keterangan) sebanyak
                {{ $alpha }} hari</b>. Hal ini menunjukkan tingkat kedisiplinan yang tidak baik sehingga perlu segera dievaluasi
            oleh Pimpinan Perusahaan.

            @if(isset($rincianAlpha) && count($rincianAlpha) > 0)
                <ul style="margin-top: 8px; margin-bottom: 0; padding-left: 20px;">
                    @foreach($rincianAlpha as $tglAlpha)
                        <li>Hari: <b>{{ \Carbon\Carbon::parse($tglAlpha)->translatedFormat('l, d F Y') }}</b></li>
                    @endforeach
                </ul>
            @endif
        </div>
    @endif

    @if(count($rincianTelat) > 0)
        <div class="alert alert-warning kotak-catatan">
            <strong>Rincian Keterlambatan:</strong>
            <ul style="margin-top: 5px; margin-bottom: 0; padding-left: 20px;">
                @foreach($rincianTelat as $telat)
                    <li>Tanggal <b>{{ \Carbon\Carbon::parse($telat['tanggal'])->translatedFormat('d F Y') }}</b>: Masuk pukul
                        {{ $telat['jam_masuk'] }} <i>(Terlambat {{ $telat['selisih'] }})</i> - Alasan:
                        {{ $telat['alasan'] ?? 'Tidak mengisi alasan' }}
                    </li>
                @endforeach
            </ul>
        </div>
    @endif

    @if($izin > 0)
        <div class="alert alert-info kotak-catatan">
            <strong>Informasi Cuti/Sakit:</strong> Karyawan ini telah melakukan pengajuan tidak masuk yang
            disetujui sebanyak <b>{{ $izin }} hari kerja</b>.

            @if(isset($rincianIzin) && count($rincianIzin) > 0)
                <ul style="margin-top: 8px; margin-bottom: 0; padding-left: 20px;">
                    @foreach($rincianIzin as $riwayatIzin)
                        <li>
                            <b>{{ \Carbon\Carbon::parse($riwayatIzin->start_date)->translatedFormat('d M Y') }}</b> s/d
                            <b>{{ \Carbon\Carbon::parse($riwayatIzin->end_date)->translatedFormat('d M Y') }}</b>
                            ({{ $riwayatIzin->type }}) - Alasan: <i>{{ $riwayatIzin->reason ?? 'Tidak ada catatan' }}</i>
                        </li>
                    @endforeach
                </ul>
            @endif
        </div>
    @endif

    @if($alpha == 0 && count($rincianTelat) == 0)
        <div class="alert alert-success">
            Karyawan ini memiliki rekam jejak presensi yang sempurna. Tidak ada catatan
            Alpha maupun Keterlambatan sama sekali selama bekerja.
        </div>
    @endif

    <div class="footer">
        * Dokumen ini dicetak dan diterbitkan oleh Admin PT. Candratama Grup Nusantara.
    </div>

</body>

</html>