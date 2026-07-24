<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <title>Laporan Presensi PT Candratama</title>
    <style>
        @page {
            margin: 30px 40px;
        }

        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            font-size: 11px;
            color: #333;
        }

        .kop-surat {
            width: 100%;
            border-bottom: 2px solid #DA2128;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }

        .header-table {
            width: 100%;
            border-collapse: collapse;
        }

        .header-table td {
            border: none;
            padding: 0;
            vertical-align: middle;
        }

        .logo-img {
            max-height: 70px;
            width: auto;
            display: block;
        }

        .company-name {
            font-size: 20px;
            font-weight: bold;
            color: #DA2128;
            margin: 0;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .report-title {
            font-size: 13px;
            font-weight: bold;
            color: #555;
            margin: 4px 0 0 0;
            text-transform: uppercase;
        }

        .date-text {
            font-size: 10px;
            color: #666;
            text-align: right;
            line-height: 1.5;
        }

        .summary-text {
            font-size: 10.5px;
            font-weight: bold;
            color: #1e293b;
            margin-bottom: 15px;
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-left: 4px solid #DA2128;
            padding: 8px 12px;
            border-radius: 4px;
            display: inline-block;
        }

        table.data-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        .data-table th {
            background-color: #DA2128;
            color: #ffffff;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 9.5px;
            padding: 10px 4px;
            border: 1px solid #DA2128;
            border-right: 1px solid #f87171;
            word-wrap: break-word;
        }

        .data-table th:last-child {
            border-right: 1px solid #DA2128;
        }

        .data-table td {
            border: 1px solid #e2e8f0;
            padding: 6px 4px;
            text-align: center;
            vertical-align: middle;
            word-wrap: break-word;
        }

        .data-table tbody tr:nth-child(even) {
            background-color: #fcfcfc;
        }

        .text-left {
            text-align: left !important;
            padding-left: 8px !important;
        }

        .text-green {
            color: #15803d;
            font-weight: bold;
        }

        .text-red {
            color: #b91c1c;
            font-weight: bold;
        }

        .text-reason {
            color: #475569;
        }

        .text-gray {
            color: #94a3b8;
        }

        .data-kosong {
            padding: 25px !important;
            color: #64748b;
            font-style: italic;
            font-size: 12px;
        }

        .badge {
            padding: 4px 6px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 9px;
        }

        .badge-success {
            background-color: #dcfce7;
            color: #166534;
        }

        .badge-warning {
            background-color: #fef9c3;
            color: #854d0e;
        }

        .badge-danger {
            background-color: #fee2e2;
            color: #991b1b;
        }

        .foto-selfie,
        .foto-terlambat {
            width: 40px;
            height: 40px;
            border-radius: 4px;
            border: 1px solid #cbd5e1;
        }

        .footer {
            margin-top: 20px;
            font-size: 9px;
            color: #94a3b8;
            text-align: right;
            font-style: italic;
        }
    </style>
</head>

<body>

    <div class="kop-surat">
        <table class="header-table">
            <tr>
                <td style="width: 80px; text-align: left;">
                    <img src="{{ public_path('images/logo.png') }}" class="logo-img" alt="Logo">
                </td>
                <td style="text-align: left; padding-left: 10px;">
                    <h1 class="company-name">PT CANDRATAMA GRUP NUSANTARA</h1>
                    <h2 class="report-title">LAPORAN REKAPITULASI PRESENSI KARYAWAN</h2>
                    <h2 class="report-title">Periode: {{ $periode }}</h2>
                </td>
                <td style="width: 170px;" class="date-text">
                    Dicetak pada: <br>
                    <strong>{{ \Carbon\Carbon::now()->locale('id')->translatedFormat('d F Y - H:i') }} WIB</strong>
                </td>
            </tr>
        </table>
    </div>

    @php
        $totalTepatWaktu = $records->whereIn('status', ['hadir', 'Tepat Waktu'])->count();
        $totalTerlambat = $records->where('status', 'terlambat')->count();
        $totalHadir = $totalTepatWaktu + $totalTerlambat;

        $teksRingkasan = "TOTAL KARYAWAN HADIR: " . $totalHadir;

        if ($records->count() > 0) {
            if ($totalTepatWaktu == $records->count()) {
                $teksRingkasan = "TOTAL KARYAWAN HADIR TEPAT WAKTU: " . $totalTepatWaktu;
            } elseif ($totalTerlambat == $records->count()) {
                $teksRingkasan = "TOTAL KARYAWAN TERLAMBAT: " . $totalTerlambat;
            }
        } elseif ($records->count() == 0) {
            $teksRingkasan = "TOTAL KARYAWAN HADIR: 0";
        }
    @endphp

    <div class="summary-text">
        {{ $teksRingkasan }}
    </div>

    <table class="data-table">
        <thead>
            <tr>
                <th style="width: 3.5%;">No</th>
                <th style="width: 13.5%;">Nama Karyawan</th>
                <th style="width: 9.5%;">Tanggal</th>
                <th style="width: 6.5%;">Jam Masuk</th>
                <th style="width: 11.5%;">Keterlambatan</th>
                <th style="width: 7.5%;">Foto Masuk</th>
                <th style="width: 6.5%;">Jam Pulang</th>
                <th style="width: 7.5%;">Foto Pulang</th>
                <th style="width: 8.5%;">Status</th>
                <th style="width: 17.5%;">Alasan Terlambat</th>
                <th style="width: 7.5%;">Bukti Terlambat</th>
            </tr>
        </thead>
        <tbody>
            @forelse($records as $index => $row)

                @php
                    $keterlambatan = '-';
                    $telatClass = 'text-gray';

                    if ($row->time_in && $row->date) {
                        $pengaturan = \App\Models\Setting::first();
                        $jamMasukKantor = $pengaturan ? $pengaturan->time_in_limit : '07:30:00';

                        $waktuMasuk = \Carbon\Carbon::parse($row->date . ' ' . $row->time_in);
                        $batasWaktu = \Carbon\Carbon::parse($row->date . ' ' . $jamMasukKantor);

                        if ($waktuMasuk->gt($batasWaktu)) {
                            $selisih = $waktuMasuk->diff($batasWaktu);
                            $jam = $selisih->h;
                            $menit = $selisih->i;
                            $keterlambatan = $jam > 0 ? "Telat {$jam} Jam {$menit} Mnt" : "Telat {$menit} Menit";
                            $telatClass = 'text-red';
                        } else {
                            $keterlambatan = 'Tepat Waktu';
                            $telatClass = 'text-green';
                        }
                    }
                @endphp

                <tr>
                    <td>{{ $index + 1 }}</td>
                    <td class="text-left" style="text-align: left !important; padding-left: 5px;">
                        <strong>{{ $row->user->name ?? 'Tidak Diketahui' }}</strong>
                    </td>
                    <td style="white-space: nowrap;">{{ \Carbon\Carbon::parse($row->date)->format('d/m/Y') }}</td>
                    <td><strong>{{ $row->time_in ? \Carbon\Carbon::parse($row->time_in)->format('H:i') : '-' }}</strong>
                    </td>
                    <td class="{{ $telatClass }}">{{ $keterlambatan }}</td>
                    <td>
                        @if($row->photo_in)
                            <img src="{{ public_path('storage/' . $row->photo_in) }}" class="foto-selfie" alt="In">
                        @else
                            <span class="text-gray">-</span>
                        @endif
                    </td>
                    <td><strong>{{ $row->time_out ? \Carbon\Carbon::parse($row->time_out)->format('H:i') : '-' }}</strong>
                    </td>
                    <td>
                        @if($row->photo_out)
                            <img src="{{ public_path('storage/' . $row->photo_out) }}" class="foto-selfie" alt="Out">
                        @else
                            <span class="text-gray">-</span>
                        @endif
                    </td>
                    <td>
                        @if($row->status == 'hadir' || $row->status == 'Tepat Waktu')
                            <span class="badge badge-success">HADIR</span>
                        @elseif($row->status == 'terlambat')
                            <span class="badge badge-warning">TERLAMBAT</span>
                        @else
                            <span class="badge badge-danger">{{ strtoupper(str_replace('_', ' ', $row->status)) }}</span>
                        @endif
                    </td>
                    <td class="text-left text-reason" style="font-size: 9.5px; line-height: 1.3;">
                        {{ $row->late_reason ?? '-' }}</td>
                    <td>
                        @if($row->late_photo)
                            <img src="{{ public_path('storage/' . $row->late_photo) }}" class="foto-terlambat" alt="Late">
                        @else
                            <span class="text-gray">-</span>
                        @endif
                    </td>
                </tr>

            @empty
                <tr>
                    <td colspan="11" class="data-kosong">Belum ada data riwayat presensi karyawan pada periode ini.</td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        * Dokumen ini dicetak dan diterbitkan oleh Admin PT. Candratama Grup Nusantara.
    </div>

</body>

</html>