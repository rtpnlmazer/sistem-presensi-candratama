<!DOCTYPE html>
<html lang="id">

<head>
    <meta charset="UTF-8">
    <title>Laporan Izin & Sakit PT Candratama</title>
    <style>
        @page {
            margin: 30px 40px;
        }

        body {
            font-family: 'Helvetica', 'Arial', sans-serif;
            font-size: 12px;
            color: #333;
        }

        .kop-surat {
            width: 100%;
            border-bottom: 2px solid #DA2128;
            padding-bottom: 15px;
            margin-bottom: 25px;
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
            max-height: 80px;
            width: auto;
            display: block;
        }

        .company-name {
            font-size: 22px;
            font-weight: bold;
            color: #DA2128;
            margin: 0;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .report-title {
            font-size: 14px;
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
            font-size: 11px;
            font-weight: bold;
            color: #333;
            margin-bottom: 12px;
            text-transform: uppercase;
        }

        table.data-table {
            width: 100%;
            border-collapse: collapse;
        }

        .data-table th {
            background-color: #DA2128;
            color: #ffffff;
            font-weight: bold;
            text-transform: uppercase;
            font-size: 11px;
            padding: 12px 6px;
            border: 1px solid #DA2128;
            border-right: 1px solid #f87171;
        }

        .data-table th:last-child {
            border-right: 1px solid #DA2128;
        }

        .data-table td {
            border: 1px solid #e2e8f0;
            padding: 8px 6px;
            text-align: center;
            vertical-align: middle;
        }

        .data-table tbody tr:nth-child(even) {
            background-color: #fcfcfc;
        }

        .text-left {
            text-align: left !important;
            padding-left: 10px !important;
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
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 9.5px;
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

        .badge-info {
            background-color: #e0f2fe;
            color: #0369a1;
        }

        .foto-lampiran {
            width: 50px;
            height: 50px;
            border-radius: 4px;
            object-fit: cover;
            border: 1px solid #ccc;
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
                <td style="width: 85px; text-align: left;">
                    <img src="{{ public_path('images/logo.png') }}" class="logo-img" alt="Logo">
                </td>
                <td style="text-align: left; padding-left: 12px;">
                    <h1 class="company-name">PT CANDRATAMA GRUP NUSANTARA</h1>
                    <h2 class="report-title">LAPORAN REKAPITULASI IZIN & SAKIT KARYAWAN</h2>
                    <h2 class="report-title">Periode: {{ $periode }}</h2>
                </td>
                <td style="width: 180px;" class="date-text">
                    Dicetak pada: <br>
                    <strong>{{ \Carbon\Carbon::now()->locale('id')->translatedFormat('d F Y - H:i') }} WIB</strong>
                </td>
            </tr>
        </table>
    </div>

    @php
        $totalData = $records->count();
        $jumlahSakit = $records->filter(fn($r) => str_contains(strtolower($r->type), 'sakit'))->count();
        $jumlahIzin = $records->filter(fn($r) => str_contains(strtolower($r->type), 'izin'))->count();

        $teksRingkasan = "Total Pengajuan Izin & Sakit: " . $totalData;

        if ($totalData > 0) {
            if ($jumlahSakit == $totalData) {
                $teksRingkasan = "Total Pengajuan Sakit: " . $jumlahSakit;
            } elseif ($jumlahIzin == $totalData) {
                $teksRingkasan = "Total Pengajuan Izin: " . $jumlahIzin;
            }
        }
    @endphp

    <div class="summary-text">
        {{ $teksRingkasan }}
    </div>

    <table class="data-table">
        <thead>
            <tr>
                <th style="width: 4%;">No</th>
                <th style="width: 18%;">Nama Karyawan</th>
                <th style="width: 10%;">Jenis</th>
                <th style="width: 12%;">Tgl Mulai</th>
                <th style="width: 12%;">Tgl Selesai</th>
                <th style="width: 17%;">Alasan / Keterangan</th>
                <th style="width: 12%;">Lampiran</th>
                <th style="width: 15%;">Status</th>
            </tr>
        </thead>
        <tbody>
            @forelse($records as $index => $row)
                <tr>
                    <td>{{ $index + 1 }}</td>
                    <td class="text-left"><strong>{{ $row->user->name ?? 'Tidak Diketahui' }}</strong></td>

                    <td><span class="badge badge-info">{{ strtoupper($row->type) }}</span></td>

                    <td>{{ \Carbon\Carbon::parse($row->start_date)->translatedFormat('d M Y') }}</td>
                    <td>{{ \Carbon\Carbon::parse($row->end_date)->translatedFormat('d M Y') }}</td>

                    <td class="text-left" style="font-size: 10px;">{{ $row->reason ?? '-' }}</td>

                    <td>
                        @if($row->attachment)
                            <img src="{{ public_path('storage/' . $row->attachment) }}" class="foto-lampiran" alt="Lampiran">
                        @else
                            <span class="text-gray">-</span>
                        @endif
                    </td>

                    <td>
                        @if($row->status == 'approved')
                            <span class="badge badge-success">DISETUJUI</span>
                        @elseif($row->status == 'rejected')
                            <span class="badge badge-danger">DITOLAK</span>
                        @else
                            <span class="badge badge-warning">MENUNGGU</span>
                        @endif
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="8" class="data-kosong">Belum ada data pengajuan izin atau sakit karyawan pada periode ini.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        * Dokumen ini dicetak dan diterbitkan oleh Admin PT. Candratama Grup Nusantara.
    </div>

</body>

</html>