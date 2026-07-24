<?php

namespace App\Filament\Resources\Attendances;

use App\Filament\Resources\Attendances\Pages\ListAttendances;
use App\Models\Attendance;
use Filament\Resources\Resource;
use pxlrbt\FilamentExcel\Actions\Tables\ExportAction;
use pxlrbt\FilamentExcel\Exports\ExcelExport;
use pxlrbt\FilamentExcel\Columns\Column;

use Filament\Schemas\Schema;
use Filament\Tables\Table;

use Filament\Schemas\Components\Section;
use Filament\Forms\Components\Select;

use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\IconColumn;

use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ImageEntry;

use Carbon\Carbon;

class AttendanceResource extends Resource
{
    protected static ?string $model = Attendance::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-clipboard-document-check';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-clipboard-document-check';
    protected static ?string $navigationLabel = 'Riwayat Presensi';
    protected static ?string $pluralModelLabel = 'Riwayat Presensi';
    protected static ?int $navigationSort = 2;

    public static function getNavigationGroup(): ?string
    {
        return 'Manajemen Kehadiran';
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Detail Data Presensi')
                    ->schema([
                        Select::make('status')
                            ->label('Status Kehadiran')
                            ->options([
                                'hadir' => 'Hadir Tepat Waktu',
                                'terlambat' => 'Terlambat',
                                'izin' => 'Izin',
                                'sakit' => 'Sakit',
                                'tidak_hadir' => 'Tidak Hadir',
                            ]),

                    ])->columns(2),
            ]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                Section::make('Detail Informasi Presensi')
                    ->columnSpan(1)
                    ->extraAttributes(['style' => 'height: 100% !important;'])
                    ->schema([
                        TextEntry::make('user.name')
                            ->label('Nama Karyawan')
                            ->weight('bold')
                            ->icon('heroicon-m-user'),

                        TextEntry::make('date')
                            ->label('Tanggal')
                            ->date('d F Y')
                            ->icon('heroicon-m-calendar'),

                        TextEntry::make('time_in')
                            ->label('Jam Masuk')
                            ->icon('heroicon-m-clock'),

                        TextEntry::make('time_out')
                            ->label('Jam Pulang')
                            ->default('-')
                            ->icon('heroicon-m-clock'),

                        TextEntry::make('status')
                            ->label('Status Kehadiran')
                            ->badge()
                            ->color(fn(string $state): string => match ($state) {
                                'hadir' => 'success',
                                'terlambat' => 'warning',
                                'izin', 'sakit' => 'info',
                                'tidak_hadir' => 'danger',
                                default => 'gray',
                            }),

                        TextEntry::make('late_reason')
                            ->label('Alasan Terlambat')
                            ->default('-')
                            ->color('danger'),

                    ])->columns(2),

                Section::make('Bukti Foto Selfie & Terlambat')
                    ->columnSpan(1)
                    ->extraAttributes(['style' => 'height: 100% !important;'])
                    ->schema([
                        ImageEntry::make('photo_in')
                            ->label('Foto Masuk')
                            ->size(150)
                            ->disk('public')
                            ->extraImgAttributes([
                                'class' => 'rounded-xl shadow-md border border-gray-200 dark:border-gray-700 object-cover',
                            ]),

                        ImageEntry::make('photo_out')
                            ->label('Foto Pulang')
                            ->size(150)
                            ->disk('public')
                            ->extraImgAttributes([
                                'class' => 'rounded-xl shadow-md border border-gray-200 dark:border-gray-700 object-cover',
                            ]),

                        ImageEntry::make('late_photo')
                            ->label('Bukti Terlambat')
                            ->size(150)
                            ->disk('public')
                            ->extraImgAttributes([
                                'class' => 'rounded-xl shadow-md border border-gray-200 dark:border-gray-700 object-cover',
                            ]),
                    ])->columns(3),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Nama Karyawan')
                    ->sortable()
                    ->searchable()
                    ->alignCenter(),

                TextColumn::make('date')
                    ->label('Tanggal')
                    ->date('d M Y')
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('time_in')
                    ->label('Jam Masuk')
                    ->time('H:i')
                    ->sortable()
                    ->badge()
                    ->color('success')
                    ->icon('heroicon-m-arrow-right-on-rectangle')
                    ->alignCenter(),

                TextColumn::make('keterlambatan')
                    ->label('Keterlambatan')
                    ->getStateUsing(function ($record) {
                        if (!$record->time_in || !$record->date) {
                            return '-';
                        }

                        $pengaturan = \App\Models\Setting::first();
                        $jamMasukKantor = $pengaturan ? $pengaturan->time_in_limit : '07:30:00';

                        $waktuMasuk = \Carbon\Carbon::parse($record->date . ' ' . $record->time_in);
                        $batasWaktu = \Carbon\Carbon::parse($record->date . ' ' . $jamMasukKantor);

                        if ($waktuMasuk->gt($batasWaktu)) {
                            $selisih = $waktuMasuk->diff($batasWaktu);

                            $jam = $selisih->h;
                            $menit = $selisih->i;
                            $detik = $selisih->s;

                            if ($jam > 0 && $menit > 0)
                                return "Telat {$jam} Jam {$menit} Menit";
                            elseif ($jam > 0 && $menit == 0)
                                return "Telat {$jam} Jam";
                            elseif ($jam == 0 && $menit > 0)
                                return "Telat {$menit} Menit";
                            else
                                return "Telat {$detik} Detik";
                        }

                        return 'Tepat Waktu';
                    })
                    ->badge()
                    ->color(fn(string $state): string => match (true) {
                        $state === 'Tepat Waktu' => 'success',
                        $state === '-' => 'gray',
                        default => 'danger',
                    })
                    ->icon(fn(string $state): string => match (true) {
                        $state === 'Tepat Waktu' => 'heroicon-m-check-circle',
                        $state === '-' => 'heroicon-m-minus-circle',
                        default => 'heroicon-m-clock',
                    })
                    ->alignCenter(),

                TextColumn::make('time_out')
                    ->label('Jam Pulang')
                    ->getStateUsing(function ($record) {
                        if ($record->time_out) {
                            return \Carbon\Carbon::parse($record->time_out)->format('H:i');
                        }

                        $izinPulangCepat = \App\Models\Leave::where('user_id', $record->user_id)
                            ->whereDate('start_date', '<=', $record->date)
                            ->whereDate('end_date', '>=', $record->date)
                            ->where('status', 'approved')
                            ->first();

                        if ($izinPulangCepat) {
                            return 'Pulang Awal (' . $izinPulangCepat->type . ')';
                        }

                        return 'Belum Pulang';
                    })
                    ->badge()
                    ->color(fn(string $state): string => match (true) {
                        $state === 'Belum Pulang' => 'gray',
                        str_contains($state, 'Pulang Awal') => 'warning',
                        default => 'info',
                    })
                    ->icon(fn(string $state): string => match (true) {
                        $state === 'Belum Pulang' => 'heroicon-m-minus-circle',
                        str_contains($state, 'Pulang Awal') => 'heroicon-m-exclamation-circle',
                        default => 'heroicon-m-arrow-left-on-rectangle',
                    })
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'hadir' => 'success',
                        'terlambat' => 'warning',
                        'izin', 'sakit' => 'info',
                        'tidak_hadir', 'alpha' => 'danger',
                        default => 'gray',
                    })
                    ->alignCenter(),

                IconColumn::make('is_auto_checkout')
                    ->label('Auto-Checkout')
                    ->boolean()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->alignCenter(),
            ])
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('status')
                    ->label('Status Kehadiran')
                    ->options([
                        'hadir' => 'Hadir',
                        'terlambat' => 'Terlambat',
                    ]),

                \Filament\Tables\Filters\Filter::make('periode')
                    ->form([
                        \Filament\Forms\Components\Select::make('bulan')
                            ->label('Saring Bulan')
                            ->options([
                                '01' => 'Januari',
                                '02' => 'Februari',
                                '03' => 'Maret',
                                '04' => 'April',
                                '05' => 'Mei',
                                '06' => 'Juni',
                                '07' => 'Juli',
                                '08' => 'Agustus',
                                '09' => 'September',
                                '10' => 'Oktober',
                                '11' => 'November',
                                '12' => 'Desember'
                            ])
                            ->placeholder('Semua Bulan'),

                        \Filament\Forms\Components\Select::make('tahun')
                            ->label('Saring Tahun')
                            ->options([
                                '2024' => '2024',
                                '2025' => '2025',
                                '2026' => '2026',
                            ])
                            ->placeholder('Semua Tahun'),
                    ])
                    ->columns(2)
                    ->query(function (\Illuminate\Database\Eloquent\Builder $query, array $data) {
                        return $query
                            ->when($data['bulan'], fn($query, $bulan) => $query->whereMonth('date', $bulan))
                            ->when($data['tahun'], fn($query, $tahun) => $query->whereYear('date', $tahun));
                    })
                    ->indicateUsing(function (array $data) {
                        $indikator = [];
                        if ($data['bulan']) {
                            $namaBulan = ['01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April', '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus', '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'];
                            $indikator[] = 'Bulan: ' . $namaBulan[$data['bulan']];
                        }
                        if ($data['tahun'])
                            $indikator[] = 'Tahun: ' . $data['tahun'];
                        return empty($indikator) ? null : implode(', ', $indikator);
                    }),

                \Filament\Tables\Filters\Filter::make('dari_tanggal')
                    ->form([
                        \Filament\Forms\Components\DatePicker::make('dari')
                            ->label('Dari Tanggal')
                            ->placeholder('Pilih Tanggal')
                            ->maxDate(function (\Livewire\Component $livewire) {
                                $sampai = $livewire->tableFilters['sampai_tanggal']['sampai'] ?? null;
                                return $sampai ? \Carbon\Carbon::parse($sampai) : now('Asia/Jakarta');
                            }),
                    ])
                    ->query(function (\Illuminate\Database\Eloquent\Builder $query, array $data) {
                        return $query->when($data['dari'], fn($query, $date) => $query->whereDate('date', '>=', $date));
                    })
                    ->indicateUsing(function (array $data) {
                        return $data['dari'] ? 'Mulai: ' . \Carbon\Carbon::parse($data['dari'])->translatedFormat('d M Y') : null;
                    }),

                \Filament\Tables\Filters\Filter::make('sampai_tanggal')
                    ->form([
                        \Filament\Forms\Components\DatePicker::make('sampai')
                            ->label('Sampai Tanggal')
                            ->placeholder('Pilih Tanggal')
                            ->minDate(function (\Livewire\Component $livewire) {
                                $dari = $livewire->tableFilters['dari_tanggal']['dari'] ?? null;
                                return $dari ? \Carbon\Carbon::parse($dari) : null;
                            })
                            ->maxDate(now('Asia/Jakarta')),
                    ])
                    ->query(function (\Illuminate\Database\Eloquent\Builder $query, array $data) {
                        return $query->when($data['sampai'], fn($query, $date) => $query->whereDate('date', '<=', $date));
                    })
                    ->indicateUsing(function (array $data) {
                        return $data['sampai'] ? 'Sampai: ' . \Carbon\Carbon::parse($data['sampai'])->translatedFormat('d M Y') : null;
                    }),
            ])
            ->filtersFormColumns(2)
            ->filtersFormWidth('2xl')
            ->filtersFormColumns(2)
            ->filtersFormWidth('2xl')
            ->headerActions([
                \Filament\Actions\Action::make('ekspor_pdf')
                    ->label('Ekspor PDF')
                    ->icon('heroicon-o-document-text')
                    ->color('danger')
                    ->action(function ($livewire) {
                        $bulan = $livewire->tableFilters['periode']['bulan'] ?? null;
                        $tahun = $livewire->tableFilters['periode']['tahun'] ?? null;

                        if ($bulan && $tahun) {
                            $namaBulan = ['01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April', '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus', '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'];
                            $periodeTeks = $namaBulan[$bulan] . ' ' . $tahun;
                        } elseif ($tahun) {
                            $periodeTeks = 'Tahun ' . $tahun;
                        } elseif ($bulan) {
                            $namaBulan = ['01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April', '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus', '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'];
                            $periodeTeks = 'Bulan ' . $namaBulan[$bulan];
                        } else {
                            $periodeTeks = 'Semua Periode';
                        }

                        $records = $livewire->getFilteredTableQuery()->get();

                        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.laporan-presensi', [
                            'records' => $records,
                            'periode' => $periodeTeks,
                        ])->setPaper('a4', 'landscape');

                        return response()->streamDownload(function () use ($pdf) {
                            echo $pdf->stream();
                        }, 'Laporan Presensi PT Candratama Grup Nusantara - ' . str_replace(' ', ' ', $periodeTeks) . '.pdf');
                    }),

                ExportAction::make('export_excel')
                    ->label('Ekspor Excel')
                    ->color('success')
                    ->icon('heroicon-o-document-arrow-down')
                    ->exports([
                        ExcelExport::make()
                            ->fromTable()
                            ->withFilename(function (\Livewire\Component $livewire) {
                                $bulan = $livewire->tableFilters['periode']['bulan'] ?? null;
                                $tahun = $livewire->tableFilters['periode']['tahun'] ?? null;

                                if ($bulan && $tahun) {
                                    $namaBulan = ['01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April', '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus', '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'];
                                    $periode = $namaBulan[$bulan] . ' ' . $tahun;
                                } elseif ($tahun) {
                                    $periode = 'Tahun ' . $tahun;
                                } elseif ($bulan) {
                                    $namaBulan = ['01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April', '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus', '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'];
                                    $periode = 'Bulan ' . $namaBulan[$bulan];
                                } else {
                                    $periode = 'Semua Periode';
                                }

                                return 'Laporan Presensi PT Candratama - ' . $periode;
                            })
                            ->withColumns([
                                Column::make('user.name')->heading('Nama Karyawan'),
                                Column::make('date')->heading('Tanggal'),
                                Column::make('status')->heading('Status Kehadiran'),
                                Column::make('time_in')->heading('Jam Masuk'),
                                Column::make('time_out')->heading('Jam Pulang'),
                                Column::make('late_reason')->heading('Alasan Terlambat'),
                            ])
                    ]),
            ])
            ->defaultSort('date', 'desc')
            ->actions([
                \Filament\Actions\Action::make('view_detail')
                    ->label('Lihat Detail')
                    ->icon('heroicon-o-eye')
                    ->color('info')
                    ->action(function (Attendance $record, $livewire) {
                        Carbon::setLocale('id');
                        $dateFormatted = Carbon::parse($record->date)->translatedFormat('d F Y');
                        $timeIn = $record->time_in ?? '-';
                        $timeOut = $record->time_out ?? '-';

                        $statusColor = match ($record->status) {
                            'hadir', 'Tepat Waktu' => '#10b981',
                            'terlambat' => '#f59e0b',
                            'izin', 'sakit' => '#3b82f6',
                            'tidak_hadir', 'alpha' => '#ef4444',
                            default => '#64748b',
                        };

                        $statusBadge = "<span style='background-color: {$statusColor}20; color: {$statusColor}; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: bold; border: 1px solid {$statusColor}40;'>" . strtoupper($record->status) . "</span>";

                        $lateReason = $record->late_reason ?? '-';
                        $reasonColor = $lateReason !== '-' ? '#ef4444' : '#94a3b8';

                        $photoIn = $record->photo_in ? asset('storage/' . $record->photo_in) : null;
                        $photoOut = $record->photo_out ? asset('storage/' . $record->photo_out) : null;
                        $latePhoto = $record->late_photo ? asset('storage/' . $record->late_photo) : null;

                        $html = "
                            <div style='display: flex; flex-direction: column; gap: 20px; text-align: left; font-family: ui-sans-serif, system-ui, sans-serif;'>
                                
                                <div style='display: grid; grid-template-columns: 1fr 1fr; gap: 15px; background: #1e293b; padding: 20px; border-radius: 12px; border: 1px solid #334155;'>
                                    <div>
                                        <p style='margin: 0; font-size: 13px; color: #94a3b8;'>Nama Karyawan</p>
                                        <p style='margin: 5px 0 15px 0; font-weight: 600; color: #f8fafc; font-size: 15px;'>
                                            <svg style='width: 16px; height: 16px; display: inline; vertical-align: sub; margin-right: 4px; color: #cbd5e1;' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z'></path></svg>
                                            {$record->user->name}
                                        </p>
                                        
                                        <p style='margin: 0; font-size: 13px; color: #94a3b8;'>Jam Masuk</p>
                                        <p style='margin: 5px 0 15px 0; font-weight: 600; color: #f8fafc; font-size: 15px;'>
                                            <svg style='width: 16px; height: 16px; display: inline; vertical-align: sub; margin-right: 4px; color: #cbd5e1;' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z'></path></svg>
                                            {$timeIn}
                                        </p>
                                        
                                        <p style='margin: 0; font-size: 13px; color: #94a3b8;'>Status Kehadiran</p>
                                        <p style='margin: 8px 0 0 0;'>{$statusBadge}</p>
                                    </div>
                                    <div>
                                        <p style='margin: 0; font-size: 13px; color: #94a3b8;'>Tanggal</p>
                                        <p style='margin: 5px 0 15px 0; font-weight: 600; color: #f8fafc; font-size: 15px;'>
                                            <svg style='width: 16px; height: 16px; display: inline; vertical-align: sub; margin-right: 4px; color: #cbd5e1;' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z'></path></svg>
                                            {$dateFormatted}
                                        </p>
                                        
                                        <p style='margin: 0; font-size: 13px; color: #94a3b8;'>Jam Pulang</p>
                                        <p style='margin: 5px 0 15px 0; font-weight: 600; color: #f8fafc; font-size: 15px;'>
                                            <svg style='width: 16px; height: 16px; display: inline; vertical-align: sub; margin-right: 4px; color: #cbd5e1;' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z'></path></svg>
                                            {$timeOut}
                                        </p>
                                        
                                        <p style='margin: 0; font-size: 13px; color: #94a3b8;'>Alasan Terlambat</p>
                                        <p style='margin: 5px 0 0 0; font-weight: 600; color: {$reasonColor}; font-size: 15px;'>{$lateReason}</p>
                                    </div>
                                </div>
                                
                                <div style='background: #1e293b; padding: 20px; border-radius: 12px; border: 1px solid #334155;'>
                                    <p style='margin: 0 0 15px 0; font-weight: 600; color: #f8fafc; font-size: 14px;'>Bukti Foto Selfie & Terlambat</p>
                                    <div style='display: flex; gap: 20px; flex-wrap: wrap;'>
                        ";

                        if ($photoIn) {
                            $html .= "<div>
                                <p style='margin: 0 0 8px 0; font-size: 12px; color: #94a3b8;'>Foto Masuk</p>
                                <img src='{$photoIn}' 
                                     onclick=\"Swal.fire({imageUrl: '{$photoIn}', imageAlt: 'Foto Masuk', imageHeight: 450, showConfirmButton: false, showCloseButton: true, background: '#0f172a', backdrop: 'rgba(0,0,0,0.9)'})\" 
                                     style='width: 110px; height: 130px; object-fit: cover; border-radius: 8px; border: 1px solid #475569; cursor: zoom-in; transition: transform 0.2s ease-in-out;' 
                                     onmouseover=\"this.style.transform='scale(1.05)'\" 
                                     onmouseout=\"this.style.transform='scale(1)'\" />
                            </div>";
                        }
                        if ($photoOut) {
                            $html .= "<div>
                                <p style='margin: 0 0 8px 0; font-size: 12px; color: #94a3b8;'>Foto Pulang</p>
                                <img src='{$photoOut}' 
                                     onclick=\"Swal.fire({imageUrl: '{$photoOut}', imageAlt: 'Foto Pulang', imageHeight: 450, showConfirmButton: false, showCloseButton: true, background: '#0f172a', backdrop: 'rgba(0,0,0,0.9)'})\" 
                                     style='width: 110px; height: 130px; object-fit: cover; border-radius: 8px; border: 1px solid #475569; cursor: zoom-in; transition: transform 0.2s ease-in-out;' 
                                     onmouseover=\"this.style.transform='scale(1.05)'\" 
                                     onmouseout=\"this.style.transform='scale(1)'\" />
                            </div>";
                        }
                        if ($latePhoto) {
                            $html .= "<div>
                                <p style='margin: 0 0 8px 0; font-size: 12px; color: #94a3b8;'>Bukti Terlambat</p>
                                <img src='{$latePhoto}' 
                                     onclick=\"Swal.fire({imageUrl: '{$latePhoto}', imageAlt: 'Bukti Terlambat', imageHeight: 450, showConfirmButton: false, showCloseButton: true, background: '#0f172a', backdrop: 'rgba(0,0,0,0.9)'})\" 
                                     style='width: 110px; height: 130px; object-fit: cover; border-radius: 8px; border: 1px solid #475569; cursor: zoom-in; transition: transform 0.2s ease-in-out;' 
                                     onmouseover=\"this.style.transform='scale(1.05)'\" 
                                     onmouseout=\"this.style.transform='scale(1)'\" />
                            </div>";
                        }

                        if (!$photoIn && !$photoOut && !$latePhoto) {
                            $html .= "<p style='color: #64748b; font-size: 13px; font-style: italic; width: 100%; text-align: center; padding: 20px 0;'>Tidak ada foto yang dilampirkan dalam presensi ini.</p>";
                        }

                        $html .= "</div></div></div>";

                        $livewire->js("
                            Swal.fire({
                                title: '<strong style=\"color: #f8fafc; font-size: 20px;\">Detail Riwayat Presensi</strong>',
                                html: `$html`,
                                width: '700px',
                                background: '#0f172a', // Warna background modal sangat gelap
                                showConfirmButton: false,
                                showCloseButton: true,
                                showCancelButton: true,
                                cancelButtonText: 'Tutup Detail',
                                cancelButtonColor: '#334155',
                                customClass: {
                                    popup: 'border border-slate-700',
                                    title: 'text-left',
                                    closeButton: 'text-slate-400 hover:text-white',
                                    cancelButton: 'hover:bg-slate-600 transition-colors'
                                }
                            });
                        ");
                    }),
            ])
            ->bulkActions([]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAttendances::route('/'),
        ];
    }
}