<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\Attendance;
use App\Models\Leave;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class StatusKehadiranChart extends ChartWidget
{
    protected ?string $heading = 'Rasio Kehadiran Hari Ini';
    protected static ?int $sort = 4;
    protected int|string|array $columnSpan = [
        'md' => 1,
    ];

    protected static bool $isLazy = false;
    protected ?string $maxHeight = '260px';

    protected function getData(): array
    {
        $today = Carbon::today('Asia/Jakarta');

        $hadirTepat = Attendance::whereDate('date', $today)->where('status', 'hadir')->count();
        $hadirTerlambat = Attendance::whereDate('date', $today)->where('status', 'terlambat')->count();
        $izin = Leave::where('status', 'approved')->whereDate('start_date', '<=', $today)->whereDate('end_date', '>=', $today)->count();
        $alpha = Attendance::whereDate('date', $today)->where('status', 'tidak_hadir')->count();

        $totalPegawai = User::where('id', '!=', 1)->count();
        $belumAbsen = $totalPegawai - ($hadirTepat + $hadirTerlambat + $izin + $alpha);

        if ($belumAbsen < 0)
            $belumAbsen = 0;

        $isCompanyHoliday = \App\Models\CompanyHoliday::whereDate('start_date', '<=', $today)
            ->whereDate('end_date', '>=', $today)
            ->exists();

        $googleHolidays = Cache::remember('kalender_libur_terbaru_' . $today->year, 86400, function () use ($today) {
            $apiKey = env('GOOGLE_CALENDAR_API_KEY');
            $holidays = [];
            if ($apiKey) {
                try {
                    $calendarId = urlencode('id.indonesian#holiday@group.v.calendar.google.com');
                    $timeMin = $today->copy()->startOfYear()->toRfc3339String();
                    $timeMax = $today->copy()->endOfYear()->toRfc3339String();
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

        $isGoogleHoliday = in_array($today->format('Y-m-d'), $googleHolidays);

        if ($today->isSunday() || $isCompanyHoliday || $isGoogleHoliday) {
            $belumAbsen = 0;
            $alpha = 0;
        }

        $pembagi = $totalPegawai > 0 ? $totalPegawai : 1;

        $pHadir = round(($hadirTepat / $pembagi) * 100, 1);
        $pTerlambat = round(($hadirTerlambat / $pembagi) * 100, 1);
        $pIzin = round(($izin / $pembagi) * 100, 1);
        $pBelum = round(($belumAbsen / $pembagi) * 100, 1);
        $pAlpha = round(($alpha / $pembagi) * 100, 1);

        return [
            'datasets' => [
                [
                    'label' => 'Total Karyawan',
                    'data' => [$hadirTepat, $hadirTerlambat, $izin, $belumAbsen, $alpha],
                    'backgroundColor' => [
                        '#10b981',
                        '#f59e0b',
                        '#3b82f6',
                        '#94a3b8',
                        '#ef4444',
                    ],
                    'borderColor' => '#1e293b',
                    'borderWidth' => 2,
                    'hoverOffset' => 15,
                ],
            ],
            'labels' => [
                "Tepat Waktu ({$pHadir}%)",
                "Terlambat ({$pTerlambat}%)",
                "Izin/Sakit ({$pIzin}%)",
                "Belum Presensi ({$pBelum}%)",
                "Alpha ({$pAlpha}%)"
            ],
        ];
    }

    protected function getType(): string
    {
        return 'pie';
    }

    protected function getOptions(): array
    {
        return [
            'maintainAspectRatio' => false,
            'plugins' => [
                'legend' => [
                    'position' => 'right',
                    'labels' => [
                        'usePointStyle' => true,
                        'padding' => 20,
                    ],
                ],
            ],
            'layout' => [
                'padding' => 25,
            ]
        ];
    }
}