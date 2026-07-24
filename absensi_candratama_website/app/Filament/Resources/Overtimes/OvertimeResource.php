<?php

namespace App\Filament\Resources\Overtimes;

use App\Filament\Resources\Overtimes\Pages;
use App\Models\Overtime;
use Filament\Resources\Resource;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use pxlrbt\FilamentExcel\Actions\Tables\ExportAction;
use pxlrbt\FilamentExcel\Exports\ExcelExport;
use pxlrbt\FilamentExcel\Columns\Column;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;
use App\Services\FirebaseService;

class OvertimeResource extends Resource
{
    protected static ?string $model = Overtime::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-clock';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-clock';
    protected static ?string $navigationLabel = 'Riwayat Lembur';
    protected static ?string $pluralModelLabel = 'Riwayat Lembur';
    protected static ?int $navigationSort = 3;

    public static function getNavigationGroup(): ?string
    {
        return 'Manajemen Kehadiran';
    }

    public static function canViewAny(): bool
    {
        return true;
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('Nama Karyawan')
                    ->sortable()
                    ->searchable()
                    ->weight('bold')
                    ->alignCenter(),

                TextColumn::make('user.position')
                    ->label('Divisi')
                    ->searchable()
                    ->alignCenter(),

                TextColumn::make('date')
                    ->label('Tanggal Lembur')
                    ->date('d F Y')
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('waktu')
                    ->label('Jam Lembur')
                    ->getStateUsing(fn($record) => date('H:i', strtotime($record->start_time)) . ' - ' . date('H:i', strtotime($record->end_time)))
                    ->badge()
                    ->color('success')
                    ->alignCenter(),

                TextColumn::make('durasi')
                    ->alignCenter()
                    ->label('Total Durasi')
                    ->getStateUsing(function ($record) {
                        $start = Carbon::parse($record->date . ' ' . $record->start_time);
                        $end = Carbon::parse($record->date . ' ' . $record->end_time);

                        if ($end->lt($start)) {
                            $end->addDay();
                        }

                        $diff = $start->diff($end);

                        $jam = $diff->h;
                        $menit = $diff->i;

                        if ($jam > 0 && $menit > 0)
                            return "{$jam} Jam {$menit} Menit";
                        if ($jam > 0)
                            return "{$jam} Jam";
                        return "{$menit} Menit";
                    }),

                TextColumn::make('reason')
                    ->label('Pekerjaan / Keterangan')
                    ->searchable()
                    ->wrap()
                    ->alignCenter(),

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
            ->defaultSort('date', 'desc')
            ->filters([
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
                        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.laporan-lembur', [
                            'records' => $records,
                            'periode' => $periodeTeks
                        ]);
                        $pdf->setPaper('a4', 'landscape');

                        return response()->streamDownload(function () use ($pdf) {
                            echo $pdf->stream();
                        }, 'Laporan Lembur PT Candratama Grup Nusantara - ' . str_replace(' ', ' ', $periodeTeks) . '.pdf');
                    }),

                ExportAction::make()
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
                                return 'Laporan Lembur PT Candratama Grup Nusantara - ' . $periode;
                            })
                    ]),
            ])
            ->actions([
                \Filament\Actions\Action::make('approve')
                    ->label('Setujui')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Setujui Lembur Karyawan?',
                                text: 'Apakah Anda yakin ingin menyetujui pengajuan lembur ini?',
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
                    ->action(function (Overtime $record) {
                        $record->update([
                            'status' => 'approved',
                            'reject_reason' => null
                        ]);

                        $judulNotif = 'Lembur Disetujui!';
                        $pesanNotif = 'Pengajuan lembur Anda untuk tanggal ' . \Carbon\Carbon::parse($record->date)->format('d M Y') . ' telah disetujui oleh Admin.';

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
                            ->title('Lembur Berhasil Disetujui!')
                            ->body('Notifikasi persetujuan telah terkirim ke HP karyawan.')
                            ->success()
                            ->send();
                    })
                    ->hidden(fn(Overtime $record) => $record->status !== 'pending'),

                \Filament\Actions\Action::make('reject')
                    ->label('Tolak')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Tolak Pengajuan Lembur',
                                text: 'Silakan ketik alasan penolakan di bawah ini. Karyawan akan menerima notifikasi di aplikasi mobile.',
                                input: 'textarea',
                                inputPlaceholder: 'Masukkan alasan mengapa lembur ditolak...',
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
                    ->action(function (Overtime $record, array $arguments) {
                        $alasanPenolakan = $arguments['reject_reason'] ?? 'Ditolak oleh Admin.';

                        $record->update([
                            'status' => 'rejected',
                            'reject_reason' => $alasanPenolakan,
                        ]);

                        $judulNotif = 'Lembur Ditolak!';
                        $pesanNotif = 'Pengajuan lembur Anda ditolak. Alasan Admin: ' . $alasanPenolakan;

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
                            ->title('Lembur Telah Ditolak!')
                            ->body('Catatan penolakan tersimpan & notifikasi telah dikirim ke HP karyawan.')
                            ->danger()
                            ->send();
                    })
                    ->hidden(fn(Overtime $record) => $record->status !== 'pending'),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListOvertimes::route('/'),
        ];
    }
}