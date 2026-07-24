<?php

namespace App\Filament\Resources\Leaves;

use App\Filament\Resources\Leaves\Pages\ListLeaves;
use App\Models\Leave;
use Filament\Resources\Resource;

use Filament\Schemas\Schema;
use Filament\Tables\Table;

use Filament\Schemas\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\FileUpload;

use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ImageColumn;

use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;

use App\Services\FirebaseService;

class LeaveResource extends Resource
{
    protected static ?string $model = Leave::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-envelope-open';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-envelope-open';
    protected static ?string $navigationLabel = 'Riwayat Izin & Sakit';
    protected static ?string $pluralModelLabel = 'Riwayat Izin & Sakit';
    protected static ?int $navigationSort = 2;

    public static function getNavigationGroup(): ?string
    {
        return 'Manajemen Kehadiran';
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Detail Pengajuan Izin')
                    ->schema([
                        Select::make('user_id')
                            ->relationship('user', 'name')
                            ->label('Nama Karyawan'),

                        Select::make('type')
                            ->label('Jenis Izin')
                            ->options([
                                'Sakit' => 'Sakit',
                                'Izin Keperluan Pribadi' => 'Izin Keperluan Pribadi',
                                'Lainnya' => 'Lainnya',
                            ]),

                        DatePicker::make('start_date')
                            ->label('Tanggal Mulai'),

                        DatePicker::make('end_date')
                            ->label('Tanggal Selesai'),

                        Textarea::make('reason')
                            ->label('Alasan / Keterangan Karyawan')
                            ->columnSpanFull(),

                        FileUpload::make('attachment')
                            ->label('Lampiran')
                            ->disk('public')
                            ->disabled()
                            ->columnSpanFull(),

                        Select::make('status')
                            ->label('Status Persetujuan')
                            ->options([
                                'pending' => 'Menunggu Persetujuan',
                                'approved' => 'Disetujui',
                                'rejected' => 'Ditolak',
                            ]),

                        Textarea::make('reject_reason')
                            ->label('Catatan Penolakan Admin')
                            ->disabled()
                            ->columnSpanFull()
                            ->hidden(fn($record) => !$record || $record->status !== 'rejected'),
                    ])->columns(2),
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

                TextColumn::make('type')
                    ->label('Jenis')
                    ->badge()
                    ->color('info')
                    ->formatStateUsing(fn(string $state): string => strtoupper($state))
                    ->alignCenter(),

                TextColumn::make('start_date')
                    ->label('Tanggal Mulai')
                    ->date('d M Y')
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('end_date')
                    ->label('Tanggal Selesai')
                    ->date('d M Y')
                    ->alignCenter(),

                TextColumn::make('reason')
                    ->label('Alasan Karyawan')
                    ->searchable()
                    ->wrap()
                    ->alignCenter(),

                ImageColumn::make('attachment')
                    ->label('Lampiran')
                    ->disk('public')
                    ->square()
                    ->alignCenter()
                    ->extraImgAttributes(function ($record) {
                        if (!$record || !$record->attachment) {
                            return [];
                        }

                        $url = asset('storage/' . $record->attachment);

                        return [
                            'class' => 'cursor-pointer transition-transform hover:scale-180 rounded-md',
                            'title' => 'Klik untuk memperbesar',
                            'x-on:click.capture' => "
                                \$event.stopImmediatePropagation();
                                \$event.preventDefault();
                                Swal.fire({
                                    imageUrl: '{$url}',
                                    imageAlt: 'Surat Karyawan',
                                    showConfirmButton: false,
                                    showCloseButton: true,
                                    width: '400px', 
                                    background: '#1f2937', 
                                    color: '#ffffff',
                                    backdrop: 'rgba(0,0,0,0.85)',
                                    padding: '1 rem',
                                    customClass: {
                                        image: 'rounded-lg object-contain w-full h-auto mt-4 mb-2 shadow-md border border-slate-600'
                                    }
                                });
                            ",
                        ];
                    }),

                TextColumn::make('status')
                    ->label('Status')
                    ->alignCenter()
                    ->badge()
                    ->color(fn(string $state): string => match ($state) {
                        'pending' => 'warning',
                        'approved' => 'success',
                        'rejected' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn(string $state): string => match ($state) {
                        'pending' => 'Menunggu',
                        'approved' => 'Disetujui',
                        'rejected' => 'Ditolak',
                        default => $state,
                    }),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                \Filament\Tables\Filters\SelectFilter::make('type')
                    ->label('Jenis Pengajuan')
                    ->options([
                        'Sakit' => 'Sakit',
                        'Izin' => 'Izin',
                        'Lainnya' => 'Lainnya',
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
                            ->when($data['bulan'], fn($query, $bulan) => $query->whereMonth('start_date', $bulan))
                            ->when($data['tahun'], fn($query, $tahun) => $query->whereYear('start_date', $tahun));
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
                        return $query->when($data['dari'], fn($query, $date) => $query->whereDate('start_date', '>=', $date));
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
                        return $query->when($data['sampai'], fn($query, $date) => $query->whereDate('start_date', '<=', $date));
                    })
                    ->indicateUsing(function (array $data) {
                        return $data['sampai'] ? 'Sampai: ' . \Carbon\Carbon::parse($data['sampai'])->translatedFormat('d M Y') : null;
                    }),
            ])
            ->filtersFormColumns(2)
            ->filtersFormWidth('2xl')
            ->headerActions([
                \Filament\Actions\Action::make('export_pdf')
                    ->label('Ekspor PDF')
                    ->color('danger')
                    ->icon('heroicon-o-document-text')
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
                        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.laporan-izin', [
                            'records' => $records,
                            'periode' => $periodeTeks
                        ]);
                        $pdf->setPaper('a4', 'landscape');

                        return response()->streamDownload(function () use ($pdf) {
                            echo $pdf->stream();
                        }, 'Laporan Izin & Sakit PT Candratama Grup Nusantara - ' . str_replace(' ', ' ', $periodeTeks) . '.pdf');
                    }),

                \pxlrbt\FilamentExcel\Actions\Tables\ExportAction::make()
                    ->label('Ekspor Excel')
                    ->color('success')
                    ->icon('heroicon-o-document-arrow-down')
                    ->exports([
                        \pxlrbt\FilamentExcel\Exports\ExcelExport::make()
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
                                return 'Laporan Izin & Sakit PT Candratama Grup Nusantara - ' . $periode;
                            })
                            ->withColumns([
                                \pxlrbt\FilamentExcel\Columns\Column::make('user.name')->heading('Nama Karyawan'),
                                \pxlrbt\FilamentExcel\Columns\Column::make('type')->heading('Jenis Izin'),
                                \pxlrbt\FilamentExcel\Columns\Column::make('start_date')->heading('Tanggal Mulai'),
                                \pxlrbt\FilamentExcel\Columns\Column::make('end_date')->heading('Tanggal Selesai'),
                                \pxlrbt\FilamentExcel\Columns\Column::make('reason')->heading('Alasan Karyawan'),

                                \pxlrbt\FilamentExcel\Columns\Column::make('status')
                                    ->heading('Status')
                                    ->formatStateUsing(fn(string $state): string => match ($state) {
                                        'approved' => 'Disetujui',
                                        'rejected' => 'Ditolak',
                                        'pending' => 'Menunggu',
                                        default => $state,
                                    }),

                                \pxlrbt\FilamentExcel\Columns\Column::make('reject_reason')->heading('Catatan Penolakan Admin'),
                            ])
                    ]),
            ])
            ->actions([
                \Filament\Actions\Action::make('download')
                    ->label('Unduh Bukti')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->color('info')
                    ->action(function (Leave $record) {
                        if ($record->attachment) {
                            $filePath = storage_path('app/public/' . $record->attachment);
                            return response()->download($filePath);
                        }
                    })
                    ->hidden(fn(Leave $record) => !$record->attachment),

                \Filament\Actions\Action::make('approve')
                    ->label('Setujui')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Setujui Izin Karyawan?',
                                text: 'Apakah Anda yakin ingin menyetujui pengajuan izin/sakit ini?',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#10b981',
                                cancelButtonColor: '#374151',
                                confirmButtonText: 'Ya, Setujui',
                                cancelButtonText: 'Batal',
                                background: '#1f2937',
                                color: '#ffffff'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    \$wire.mountTableAction('approve', '{$record->id}');
                                }
                            })
                        "
                    ])
                    ->action(function (Leave $record) {
                        $record->update([
                            'status' => 'approved',
                            'reject_reason' => null
                        ]);

                        $judulNotif = 'Izin Disetujui!';
                        $pesanNotif = 'Pengajuan izin/sakit Anda untuk tanggal ' . \Carbon\Carbon::parse($record->start_date)->format('d M Y') . ' telah disetujui oleh Admin.';

                        \Illuminate\Support\Facades\DB::table('app_notifications')->insert([
                            'user_id' => $record->user_id,
                            'title' => $judulNotif,
                            'body' => $pesanNotif,
                            'is_read' => false,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);

                        if ($record->user && $record->user->fcm_token) {
                            FirebaseService::sendNotification($record->user->fcm_token, $judulNotif, $pesanNotif);
                        }

                        \Filament\Notifications\Notification::make()
                            ->title('Izin Berhasil Disetujui!')
                            ->body('Notifikasi persetujuan telah terkirim ke HP karyawan.')
                            ->success()
                            ->send();
                    })
                    ->hidden(fn(Leave $record) => $record->status !== 'pending'),

                \Filament\Actions\Action::make('reject')
                    ->label('Tolak')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Tolak Pengajuan Izin',
                                text: 'Silakan ketik alasan penolakan di bawah ini. Karyawan akan menerima notifikasi di aplikasi mobile.',
                                input: 'textarea',
                                inputPlaceholder: 'Masukkan alasan mengapa izin ditolak...',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#ef4444',
                                cancelButtonColor: '#374151',
                                confirmButtonText: 'Tolak Pengajuan & Kirim',
                                cancelButtonText: 'Batal',
                                background: '#1f2937',
                                color: '#ffffff',
                                inputValidator: (value) => {
                                    if (!value) {
                                        return 'Alasan penolakan wajib diisi!'
                                    }
                                }
                            }).then((result) => {
                                if (result.isConfirmed && result.value) {
                                    \$wire.mountTableAction('reject', '{$record->id}', { reject_reason: result.value });
                                }
                            })
                        "
                    ])
                    ->action(function (Leave $record, array $arguments) {
                        $alasanPenolakan = $arguments['reject_reason'] ?? 'Ditolak oleh Admin.';

                        $record->update([
                            'status' => 'rejected',
                            'reject_reason' => $alasanPenolakan,
                        ]);

                        $judulNotif = 'Izin Ditolak!';
                        $pesanNotif = 'Pengajuan izin Anda ditolak. Alasan Admin: ' . $alasanPenolakan;

                        \Illuminate\Support\Facades\DB::table('app_notifications')->insert([
                            'user_id' => $record->user_id,
                            'title' => $judulNotif,
                            'body' => $pesanNotif,
                            'is_read' => false,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ]);

                        if ($record->user && $record->user->fcm_token) {
                            FirebaseService::sendNotification($record->user->fcm_token, $judulNotif, $pesanNotif);
                        }

                        \Filament\Notifications\Notification::make()
                            ->title('Izin Telah Ditolak!')
                            ->body('Catatan penolakan tersimpan & notifikasi telah dikirim ke HP karyawan.')
                            ->danger()
                            ->send();
                    })
                    ->hidden(fn(Leave $record) => $record->status !== 'pending'),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ListLeaves::route('/'),
        ];
    }
}