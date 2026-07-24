<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use Carbon\Carbon;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class AttendanceOverview extends BaseWidget
{
    protected static ?int $sort = 2;
    protected static bool $isLazy = false;

    public function isHariLibur(Carbon $date): bool
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

        $googleHolidays = Cache::remember('kalender_libur_terbaru_' . $date->year, 86400, function () use ($date) {
            $apiKey = env('GOOGLE_CALENDAR_API_KEY');
            $holidays = [];
            if ($apiKey) {
                try {
                    $calendarId = urlencode('id.indonesian#holiday@group.v.calendar.google.com');
                    $timeMin = $date->copy()->startOfYear()->toRfc3339String();
                    $timeMax = $date->copy()->endOfYear()->toRfc3339String();
                    $url = "https://www.googleapis.com/calendar/v3/calendars/{$calendarId}/events?key={$apiKey}&timeMin={$timeMin}&timeMax={$timeMax}&singleEvents=true";

                    $response = Http::timeout(5)->get($url);
                    if ($response->successful() && !empty($response->json('items'))) {
                        foreach ($response->json('items') as $item) {
                            $summary = strtolower($item['summary'] ?? '');
                            if (!str_contains($summary, 'cuti bersama') && !str_contains($summary, 'puasa') && !str_contains($summary, 'ramadhan')) {
                                if (isset($item['start']['date'])) {
                                    $holidays[] = substr($item['start']['date'], 0, 10);
                                }
                            }
                        }
                    }
                } catch (\Exception $e) {
                }
            }
            return array_unique($holidays);
        });

        return in_array($date->format('Y-m-d'), $googleHolidays);
    }

    protected function getStats(): array
    {
        $hariIni = Carbon::today('Asia/Jakarta');
        $apakahLibur = $this->isHariLibur($hariIni);
        $totalPegawai = User::where('id', '!=', 1)->count();

        $pengaturan = \App\Models\Setting::first();
        $jamPulang = $pengaturan && $pengaturan->time_out_limit ? Carbon::parse($pengaturan->time_out_limit)->format('H:i') : '16:30';

        $hadir = Attendance::whereDate('date', $hariIni)->where('status', 'hadir')->count();
        $terlambat = Attendance::whereDate('date', $hariIni)->where('status', 'terlambat')->count();

        $izinSakit = Leave::whereDate('start_date', '<=', $hariIni)
            ->whereDate('end_date', '>=', $hariIni)
            ->where('status', 'approved')
            ->count();

        $belumAbsen = 0;
        $alpha = 0;

        if (!$apakahLibur) {
            $sudahAbsenAtauIzin = $hadir + $terlambat + $izinSakit;
            $belumAbsen = $totalPegawai - $sudahAbsenAtauIzin;
            if ($belumAbsen < 0) {
                $belumAbsen = 0;
            }

            if (Carbon::now('Asia/Jakarta')->format('H:i') >= $jamPulang) {
                $alpha = $belumAbsen;
                $belumAbsen = 0;
            }
        }

        return [
            Stat::make('Karyawan Aktif', $totalPegawai)
                ->description('Total Seluruh Karyawan Kantor')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),

            Stat::make('Hadir Tepat Waktu', $hadir)
                ->description('Total Karyawan Hadir Tepat Waktu')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),

            Stat::make('Terlambat', $terlambat)
                ->description('Total Karyawan Hadir Terlambat')
                ->descriptionIcon('heroicon-m-clock')
                ->color('warning'),

            Stat::make('Izin / Sakit', $izinSakit)
                ->description('Total Karyawan Izin / Sakit')
                ->descriptionIcon('heroicon-m-document-text')
                ->color('info'),

            Stat::make('Belum Presensi', $apakahLibur ? 'Hari Libur' : $belumAbsen)
                ->description($apakahLibur ? 'Karyawan tidak melakukan presensi' : 'Total Karyawan Belum Presensi')
                ->descriptionIcon($apakahLibur ? 'heroicon-m-face-smile' : 'heroicon-m-question-mark-circle')
                ->color($apakahLibur ? 'success' : 'gray'),

            Stat::make('Alpha (Tanpa Keterangan)', $alpha)
                ->description('Total Karyawan Tanpa Keterangan')
                ->descriptionIcon('heroicon-m-x-circle')
                ->color('danger'),
        ];
    }
}