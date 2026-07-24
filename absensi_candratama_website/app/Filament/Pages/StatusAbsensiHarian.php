<?php

namespace App\Filament\Pages;

use App\Models\User;
use App\Models\Attendance;
use Filament\Pages\Page;
use Filament\Tables\Table;
use Filament\Tables\Contracts\HasTable;
use Filament\Tables\Concerns\InteractsWithTable;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Columns\ImageColumn;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\HtmlString;
use Carbon\Carbon;
use Livewire\Attributes\On;

class StatusAbsensiHarian extends Page implements HasTable
{
    use InteractsWithTable;

    protected static string|\UnitEnum|null $navigationGroup = 'Manajemen Kehadiran';
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-document-chart-bar';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-document-chart-bar';
    protected static ?string $navigationLabel = 'Rekap Presensi';
    protected static ?int $navigationSort = 2;

    protected string $view = 'filament.pages.status-absensi-harian';

    public function getTitle(): string|\Illuminate\Contracts\Support\Htmlable
    {
        return 'Rekap Presensi';
    }

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Manajemen Kehadiran',
            url()->current() => 'Rekap Presensi',
        ];
    }

    public function getSubheading(): string|\Illuminate\Contracts\Support\Htmlable|null
    {
        Carbon::setLocale('id');
        $tanggal = Carbon::now('Asia/Jakarta')->translatedFormat('l, d F Y');

        return new HtmlString('
            <div style="color: #6b7280; font-size: 15px; margin-bottom: 8px;">
                Menampilkan status presensi seluruh karyawan secara langsung. Tanggal hari ini: ' . $tanggal . '.
            </div>
            <style>@keyframes ping { 75%, 100% { transform: scale(2); opacity: 0; } }</style>
        ');
    }

    public function isHariLibur(\Carbon\Carbon $date): bool
    {
        if ($date->isSunday()) {
            return true;
        }

        $isCompanyHoliday = \App\Models\CompanyHoliday::whereDate('start_date', '<=', $date->format('Y-m-d'))
            ->whereDate('end_date', '>=', $date->format('Y-m-d'))
            ->exists();

        if ($isCompanyHoliday) {
            return true;
        }

        $googleHolidays = \Illuminate\Support\Facades\Cache::remember('google_holidays_' . $date->year, 86400, function () use ($date) {
            $apiKey = env('GOOGLE_CALENDAR_API_KEY');
            $holidays = [];

            if ($apiKey) {
                try {
                    $calendarId = urlencode('id.indonesian#holiday@group.v.calendar.google.com');
                    $timeMin = $date->copy()->startOfYear()->toRfc3339String();
                    $timeMax = $date->copy()->endOfYear()->toRfc3339String();

                    $url = "https://www.googleapis.com/calendar/v3/calendars/{$calendarId}/events?key={$apiKey}&timeMin={$timeMin}&timeMax={$timeMax}&singleEvents=true";

                    $response = \Illuminate\Support\Facades\Http::timeout(5)->get($url);

                    if ($response->successful() && !empty($response->json('items'))) {
                        foreach ($response->json('items') as $item) {
                            $summary = strtolower($item['summary'] ?? '');
                            if (!str_contains($summary, 'cuti bersama') && !str_contains($summary, 'puasa') && !str_contains($summary, 'ramadhan')) {
                                if (isset($item['start']['date'])) {
                                    $holidays[] = $item['start']['date'];
                                }
                            }
                        }
                    }
                } catch (\Exception $e) {
                }
            }
            return $holidays;
        });

        return in_array($date->format('Y-m-d'), $googleHolidays);
    }

    public function getStatistikAkumulasi(User $record): array
    {
        $awalMulai = $record->created_at ? Carbon::parse($record->created_at)->startOfDay() : Carbon::now('Asia/Jakarta')->startOfMonth();
        $waktuSekarang = Carbon::now('Asia/Jakarta');
        $hariIni = Carbon::today('Asia/Jakarta');

        $pengaturan = \App\Models\Setting::first();
        $jamPulangKantor = $pengaturan && $pengaturan->time_out_limit ? $pengaturan->time_out_limit : '16:30:00';
        $batasWaktuPulang = Carbon::parse($hariIni->format('Y-m-d') . ' ' . $jamPulangKantor);

        $batasPenghitungan = $hariIni;

        if ($awalMulai->gt($batasPenghitungan)) {
            return ['alpha' => 0, 'izin' => 0, 'detail_alpha' => []];
        }

        $holidayDates = [];
        foreach (\App\Models\CompanyHoliday::all() as $h) {
            $start = Carbon::parse($h->start_date);
            $end = Carbon::parse($h->end_date);
            for ($d = $start->copy(); $d->lte($end); $d->addDay())
                $holidayDates[] = $d->format('Y-m-d');
        }

        $googleHolidays = [];
        $apiKey = env('GOOGLE_CALENDAR_API_KEY');
        if ($apiKey) {
            try {
                $response = Http::timeout(3)->get('https://www.googleapis.com/calendar/v3/calendars/id.indonesian%23holiday%40group.v.calendar.google.com/events', [
                    'key' => $apiKey,
                    'timeMin' => $awalMulai->copy()->startOfDay()->toRfc3339String(),
                    'timeMax' => $hariIni->copy()->endOfDay()->toRfc3339String(),
                    'singleEvents' => 'true',
                ]);
                if ($response->successful() && !empty($response->json('items'))) {
                    foreach ($response->json('items') as $item) {
                        $summary = strtolower($item['summary'] ?? '');
                        if (!str_contains($summary, 'cuti bersama') && !str_contains($summary, 'puasa') && !str_contains($summary, 'ramadhan')) {
                            if (isset($item['start']['date']))
                                $googleHolidays[] = $item['start']['date'];
                        }
                    }
                }
            } catch (\Exception $e) {
            }
        }

        $attendanceDates = Attendance::where('user_id', $record->id)->whereIn('status', ['hadir', 'Tepat Waktu', 'terlambat'])->pluck('date')->toArray();

        $manualLeaveDates = Attendance::where('user_id', $record->id)
            ->whereIn('status', ['izin', 'sakit', 'Izin', 'Sakit', 'IZIN', 'SAKIT', 'cuti', 'Cuti'])
            ->pluck('date')->toArray();

        $izinRecords = \App\Models\Leave::where('user_id', $record->id)->where('status', 'approved')->get();

        $leaveDates = [];
        foreach ($izinRecords as $izin) {
            $start = Carbon::parse($izin->start_date);
            $end = Carbon::parse($izin->end_date);
            for ($d = $start->copy(); $d->lte($end); $d->addDay())
                $leaveDates[] = $d->format('Y-m-d');
        }

        $totalIzinKerja = 0;
        $detailAlphaDates = [];

        for ($d = $awalMulai->copy(); $d->lte($batasPenghitungan); $d->addDay()) {
            $dateStr = $d->format('Y-m-d');
            if (!$d->isSunday() && !in_array($dateStr, $holidayDates) && !in_array($dateStr, $googleHolidays)) {

                if (in_array($dateStr, $attendanceDates)) {
                } elseif (in_array($dateStr, $leaveDates) || in_array($dateStr, $manualLeaveDates)) {
                    $totalIzinKerja++;
                } else {
                    if ($d->lt($hariIni) || ($d->isSameDay($hariIni) && $waktuSekarang->gt($batasWaktuPulang))) {
                        $detailAlphaDates[] = $dateStr;
                    }
                }
            }
        }

        return ['alpha' => count($detailAlphaDates), 'izin' => $totalIzinKerja, 'detail_alpha' => $detailAlphaDates];
    }

    #[On('download-rapor')]
    public function downloadRaporPdf($data)
    {
        $userId = $data['userId'] ?? null;
        if (!$userId)
            return;

        $record = User::find($userId);

        $hadir = Attendance::where('user_id', $record->id)->whereIn('status', ['hadir', 'Tepat Waktu'])->count();
        $terlambatRecords = Attendance::where('user_id', $record->id)->where('status', 'terlambat')->orderBy('date', 'asc')->get();

        $izinRecords = \App\Models\Leave::where('user_id', $record->id)->where('status', 'approved')->orderBy('start_date', 'asc')->get();

        $stats = $this->getStatistikAkumulasi($record);
        $izinSakit = $stats['izin'];
        $alpha = $stats['alpha'];
        $rincianAlpha = $stats['detail_alpha'];

        $totalMenitTerlambat = 0;
        $pengaturan = \App\Models\Setting::first();
        $jamMasukKantor = $pengaturan ? $pengaturan->time_in_limit : '07:30:00';

        $rincianTelat = [];
        foreach ($terlambatRecords as $absen) {
            $waktuMasuk = Carbon::parse($absen->date . ' ' . $absen->time_in);
            $batasWaktu = Carbon::parse($absen->date . ' ' . $jamMasukKantor);
            if ($waktuMasuk->gt($batasWaktu)) {
                $selisihTotalMenit = (int) $batasWaktu->diffInMinutes($waktuMasuk);
                $totalMenitTerlambat += $selisihTotalMenit;

                $jamTelat = floor($selisihTotalMenit / 60);
                $menitTelat = $selisihTotalMenit % 60;
                $teksSelisih = $jamTelat > 0 ? "{$jamTelat} Jam {$menitTelat} Menit" : "{$menitTelat} Menit";

                $rincianTelat[] = [
                    'tanggal' => $absen->date,
                    'jam_masuk' => $absen->time_in,
                    'selisih' => $teksSelisih,
                    'alasan' => $absen->late_reason
                ];
            }
        }

        $jam = floor($totalMenitTerlambat / 60);
        $menit = $totalMenitTerlambat % 60;
        $teksTerlambat = $jam > 0 ? "{$jam} Jam {$menit} Mnt" : "{$menit} Menit";

        $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.statistik-karyawan', [
            'pegawai' => $record,
            'hadir' => $hadir,
            'terlambat' => $terlambatRecords->count(),
            'izin' => $izinSakit,
            'alpha' => $alpha,
            'teksTerlambat' => $teksTerlambat,
            'rincianTelat' => $rincianTelat,
            'rincianIzin' => $izinRecords,
            'rincianAlpha' => $rincianAlpha
        ]);

        return response()->streamDownload(function () use ($pdf) {
            echo $pdf->stream();
        }, 'Rapor Statistik Kehadiran Karyawan PT. Candratama Grup Nusantara - ' . str_replace(' ', ' ', $record->name) . '.pdf');
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(function ($livewire) {
                $query = User::query()->where('role', 'pegawai');

                $filterDate = $livewire->tableFilters['tanggal_filter']['tanggal_presensi'] ?? null;
                $dateToCheck = !empty($filterDate) ? Carbon::parse($filterDate) : Carbon::today('Asia/Jakarta');

                if ($dateToCheck->gt(Carbon::today('Asia/Jakarta'))) {
                    $query->whereNull('id');
                    return $query;
                }

                $query->where(function ($q) use ($dateToCheck) {
                    $q->whereDate('created_at', '<=', $dateToCheck->toDateString())
                        ->orWhereNull('created_at');
                });

                if ($this->isHariLibur($dateToCheck)) {
                    if (!Attendance::whereDate('date', $dateToCheck)->exists()) {
                        $query->whereNull('id');
                    }
                }

                return $query;
            })
            ->poll('10s')
            ->columns([
                ImageColumn::make('photo')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->defaultImageUrl(url('https://ui-avatars.com/api/?background=random&name=P'))
                    ->toggleable()
                    ->alignCenter(),
                TextColumn::make('name')->label('Nama Karyawan')->searchable()->sortable()->weight('bold')->alignCenter(),
                TextColumn::make('email')->label('Alamat Email')->searchable()->color('gray')->toggleable(isToggledHiddenByDefault: true)->alignCenter(),

                TextColumn::make('status_hari_ini')
                    ->alignCenter()
                    ->label('Status Kehadiran')
                    ->getStateUsing(function ($record, $livewire) {
                        $filterDate = $livewire->tableFilters['tanggal_filter']['tanggal_presensi'] ?? null;
                        $dateObj = !empty($filterDate) ? Carbon::parse($filterDate) : Carbon::today('Asia/Jakarta');
                        $dateStr = $dateObj->toDateString();

                        $presensi = Attendance::where('user_id', $record->id)->whereDate('date', $dateStr)->first();
                        if ($presensi) {
                            return $presensi->status;
                        }

                        $izin = \App\Models\Leave::where('user_id', $record->id)
                            ->whereDate('start_date', '<=', $dateStr)
                            ->whereDate('end_date', '>=', $dateStr)
                            ->where('status', 'approved')
                            ->first();

                        if ($izin) {
                            return strtolower($izin->type) === 'sakit' ? 'sakit' : 'izin';
                        }

                        $todayObj = Carbon::today('Asia/Jakarta');

                        if ($dateObj->lt($todayObj)) {
                            return 'alpha';
                        } elseif ($dateObj->isSameDay($todayObj)) {
                            $pengaturan = \App\Models\Setting::first();
                            $jamPulangKantor = $pengaturan && $pengaturan->time_out_limit ? $pengaturan->time_out_limit : '16:30:00';
                            $waktuSekarang = Carbon::now('Asia/Jakarta')->format('H:i:s');

                            if ($waktuSekarang > $jamPulangKantor) {
                                return 'alpha';
                            }
                        }

                        return 'belum_presensi';
                    })
                    ->badge()
                    ->color(fn(string $state): string => match ($state) { 'hadir', 'Tepat Waktu' => 'success', 'terlambat' => 'warning', 'izin', 'sakit' => 'info', 'tidak_hadir', 'alpha' => 'danger', 'belum_presensi' => 'gray', default => 'gray'})
                    ->formatStateUsing(fn(string $state): string => match ($state) { 'hadir' => 'Hadir', 'terlambat' => 'Terlambat', 'izin' => 'Izin', 'sakit' => 'Sakit', 'tidak_hadir' => 'Tidak Hadir', 'belum_presensi' => 'Belum Presensi', 'alpha' => 'Alpha', default => ucfirst($state)}),

                TextColumn::make('jam_masuk')
                    ->alignCenter()
                    ->label('Jam Masuk')
                    ->getStateUsing(function ($record, $livewire) {
                        $filterDate = $livewire->tableFilters['tanggal_filter']['tanggal_presensi'] ?? null;
                        $date = !empty($filterDate) ? Carbon::parse($filterDate)->toDateString() : Carbon::today('Asia/Jakarta')->toDateString();
                        $presensi = Attendance::where('user_id', $record->id)->whereDate('date', $date)->first();
                        return $presensi && $presensi->time_in ? Carbon::parse($presensi->time_in)->format('H:i') : '-';
                    })
                    ->badge()->color('success')->icon(fn(string $state): string => $state !== '-' ? '' : ''),

                TextColumn::make('jam_pulang')
                    ->alignCenter()
                    ->label('Jam Pulang')
                    ->getStateUsing(function ($record, $livewire) {
                        $filterDate = $livewire->tableFilters['tanggal_filter']['tanggal_presensi'] ?? null;
                        $date = !empty($filterDate) ? Carbon::parse($filterDate)->toDateString() : Carbon::today('Asia/Jakarta')->toDateString();

                        $presensi = Attendance::where('user_id', $record->id)->whereDate('date', $date)->first();

                        if ($presensi && $presensi->time_out) {
                            return Carbon::parse($presensi->time_out)->format('H:i');
                        }

                        $izin = \App\Models\Leave::where('user_id', $record->id)
                            ->whereDate('start_date', '<=', $date)
                            ->whereDate('end_date', '>=', $date)
                            ->where('status', 'approved')
                            ->first();

                        if ($presensi && $presensi->time_in && $izin) {
                            return 'Pulang Awal (' . $izin->type . ')';
                        }

                        return '-';
                    })
                    ->badge()
                    ->color(fn(string $state): string => match (true) {
                        $state === '-' => 'gray',
                        str_contains($state, 'Pulang Awal') => 'warning',
                        default => 'info'
                    })
            ])
            ->filters([
                Filter::make('tanggal_filter')
                    ->form([DatePicker::make('tanggal_presensi')->label('Cek Presensi di Tanggal Lain:')->native(false)->displayFormat('d F Y')])
                    ->query(function (Builder $query, array $data) {
                    })
                    ->indicateUsing(fn(array $data) => empty($data['tanggal_presensi']) ? null : 'Melihat Tanggal: ' . Carbon::parse($data['tanggal_presensi'])->translatedFormat('d F Y')),

                Filter::make('status_kehadiran')
                    ->form([
                        Select::make('status')->label('Saring Status Kehadiran')->options([
                            'hadir' => 'Hadir Tepat Waktu',
                            'terlambat' => 'Terlambat',
                            'izin_sakit' => 'Sedang Izin / Sakit',
                            'belum_presensi' => 'Belum Absen / Alpha'
                        ])
                    ])
                    ->query(function (Builder $query, array $data, $livewire) {
                        if (!empty($data['status'])) {
                            $filterDate = $livewire->tableFilters['tanggal_filter']['tanggal_presensi'] ?? null;
                            $date = !empty($filterDate) ? Carbon::parse($filterDate)->toDateString() : Carbon::today('Asia/Jakarta')->toDateString();
                            $status = $data['status'];

                            if ($status === 'hadir') {
                                $query->whereIn('id', fn($q) => $q->select('user_id')->from('attendances')->whereDate('date', $date)->where('status', 'hadir'));
                            } elseif ($status === 'terlambat') {
                                $query->whereIn('id', fn($q) => $q->select('user_id')->from('attendances')->whereDate('date', $date)->where('status', 'terlambat'));
                            } elseif ($status === 'izin_sakit') {
                                $query->whereIn('id', fn($q) => $q->select('user_id')->from('leaves')->whereDate('start_date', '<=', $date)->whereDate('end_date', '>=', $date)->where('status', 'approved'));
                            } elseif ($status === 'belum_presensi') {
                                $query->whereNotIn('id', fn($q) => $q->select('user_id')->from('attendances')->whereDate('date', $date))
                                    ->whereNotIn('id', fn($q) => $q->select('user_id')->from('leaves')->whereDate('start_date', '<=', $date)->whereDate('end_date', '>=', $date)->where('status', 'approved'));
                            }
                        }
                    })
                    ->indicateUsing(fn(array $data) => empty($data['status']) ? null : 'Status: ' . (['hadir' => 'Hadir Tepat Waktu', 'terlambat' => 'Terlambat', 'izin_sakit' => 'Izin / Sakit', 'belum_presensi' => 'Belum Presensi'][$data['status']] ?? $data['status']))
            ])
            ->actions([
                \Filament\Actions\Action::make('statistik')
                    ->label('Statistik')
                    ->icon('heroicon-m-chart-pie')
                    ->color('info')
                    ->action(function (User $record, $livewire) {
                        $hadir = Attendance::where('user_id', $record->id)->whereIn('status', ['hadir', 'Tepat Waktu'])->count();
                        $terlambatRecords = Attendance::where('user_id', $record->id)->where('status', 'terlambat')->get();

                        $stats = $livewire->getStatistikAkumulasi($record);
                        $izinSakit = $stats['izin'];
                        $alpha = $stats['alpha'];

                        $totalMenitTerlambat = 0;
                        $pengaturan = \App\Models\Setting::first();
                        $jamMasukKantor = $pengaturan ? $pengaturan->time_in_limit : '07:30:00';

                        foreach ($terlambatRecords as $absen) {
                            $waktuMasuk = Carbon::parse($absen->date . ' ' . $absen->time_in);
                            $batasWaktu = Carbon::parse($absen->date . ' ' . $jamMasukKantor);
                            if ($waktuMasuk->gt($batasWaktu)) {
                                $totalMenitTerlambat += $batasWaktu->diffInMinutes($waktuMasuk);
                            }
                        }

                        $jam = floor($totalMenitTerlambat / 60);
                        $menit = $totalMenitTerlambat % 60;
                        $teksTerlambat = $jam > 0 ? "{$jam} Jam {$menit} Mnt" : "{$menit} Menit";
                        $terlambatCount = $terlambatRecords->count();

                        $htmlTemplate = <<<HTML
                            <p style="font-size: 14px; color: #9ca3af; margin-bottom: 25px; margin-top: -5px;">Akumulasi seluruh data selama menjadi karyawan aktif.</p>
                            <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; text-align: left;">
                                <div style="background-color: #f0fdf4; padding: 20px; border-radius: 12px; border: 1px solid #bbf7d0;">
                                    <div style="font-size: 13px; color: #166534; font-weight: bold; margin-bottom: 5px;">Tepat Waktu</div>
                                    <div style="font-size: 30px; color: #15803d; font-weight: 900;">{$hadir} <span style="font-size: 16px; font-weight: normal;">hari</span></div>
                                </div>
                                <div style="background-color: #fffbeb; padding: 20px; border-radius: 12px; border: 1px solid #fef08a;">
                                    <div style="font-size: 13px; color: #854d0e; font-weight: bold; margin-bottom: 5px;">Terlambat</div>
                                    <div style="font-size: 30px; color: #a16207; font-weight: 900;">{$terlambatCount} <span style="font-size: 16px; font-weight: normal;">hari</span></div>
                                </div>
                                <div style="background-color: #eff6ff; padding: 20px; border-radius: 12px; border: 1px solid #bfdbfe;">
                                    <div style="font-size: 13px; color: #1e40af; font-weight: bold; margin-bottom: 5px;">Izin / Sakit</div>
                                    <div style="font-size: 30px; color: #1d4ed8; font-weight: 900;">{$izinSakit} <span style="font-size: 16px; font-weight: normal;">kali</span></div>
                                </div>
                                <div style="background-color: #faf5ff; padding: 20px; border-radius: 12px; border: 1px solid #e9d5ff;">
                                    <div style="font-size: 13px; color: #6b21a8; font-weight: bold; margin-bottom: 5px;">Alpha (Tanpa Keterangan)</div>
                                    <div style="font-size: 30px; color: #7e22ce; font-weight: 900;">{$alpha} <span style="font-size: 16px; font-weight: normal;">hari</span></div>
                                </div>
                                <div style="background-color: #fef2f2; padding: 20px; border-radius: 12px; border: 1px solid #fecaca; grid-column: span 2;">
                                    <div style="font-size: 13px; color: #991b1b; font-weight: bold; margin-bottom: 5px;">Akumulasi Waktu Terlambat</div>
                                    <div style="font-size: 30px; color: #b91c1c; font-weight: 900;">{$teksTerlambat}</div>
                                </div>
                            </div>
                        HTML;

                        $livewire->js(<<<JS
                            Swal.fire({
                                title: '<strong style="color: #f8fafc;">Statistik: {$record->name}</strong>',
                                html: `{$htmlTemplate}`,
                                width: '800px',
                                background: '#1e293b',
                                showCancelButton: true,
                                confirmButtonText: '<svg style="width: 20px; height: 20px; display: inline-block; vertical-align: middle; margin-right: 5px;" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg> Cetak Rapor PDF',
                                cancelButtonText: 'Tutup',
                                confirmButtonColor: '#2563eb',
                                cancelButtonColor: '#475569',
                                customClass: { title: 'swal-title-custom' }
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    Livewire.dispatch('download-rapor', { data: { userId: {$record->id} } });
                                }
                            });
                        JS);
                    })
            ])
            ->striped()
            ->emptyStateHeading(fn($livewire) => (!empty($livewire->tableSearch) || !empty($livewire->tableFilters['status_kehadiran']['status'])) ? 'Karyawan Tidak Ditemukan' : 'Tidak Ada Aktivitas Presensi')
            ->emptyStateDescription(fn($livewire) => (!empty($livewire->tableSearch) || !empty($livewire->tableFilters['status_kehadiran']['status'])) ? 'Tidak ada data karyawan yang cocok. Coba sesuaikan kata kunci pencarian atau hapus filter status yang sedang aktif.' : 'Tabel kosong karena belum ada yang melakukan presensi.')
            ->emptyStateIcon(fn($livewire) => (!empty($livewire->tableSearch) || !empty($livewire->tableFilters['status_kehadiran']['status'])) ? 'heroicon-o-magnifying-glass' : 'heroicon-o-face-smile')
            ->defaultSort('name', 'asc');
    }
}
