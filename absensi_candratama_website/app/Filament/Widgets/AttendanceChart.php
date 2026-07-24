<?php

namespace App\Filament\Widgets;

use App\Models\Attendance;
use Carbon\Carbon;
use Filament\Widgets\ChartWidget;

class AttendanceChart extends ChartWidget
{
    protected static ?int $sort = 3;
    protected ?string $maxHeight = '260px';
    protected int|string|array $columnSpan = ['md' => 1];
    protected static bool $isLazy = false;

    public function getHeading(): string
    {
        return 'Tren Kehadiran Karyawan';
    }

    protected function getFilters(): ?array
    {
        return [
            '7_hari' => '7 Hari Terakhir',
            'per_bulan' => 'Per Bulan',
        ];
    }

    protected function getData(): array
    {
        $activeFilter = $this->filter ?? '7_hari';
        $data = [];
        $labels = [];
        $currentYear = Carbon::today('Asia/Jakarta')->year;

        if ($activeFilter === '7_hari') {
            for ($i = 6; $i >= 0; $i--) {
                $date = Carbon::today('Asia/Jakarta')->subDays($i);
                $labels[] = $date->translatedFormat('d M');

                $data[] = Attendance::where('date', $date->toDateString())
                    ->whereIn('status', ['hadir', 'Tepat Waktu', 'terlambat'])
                    ->count();
            }
        }
        elseif ($activeFilter === 'per_bulan') {
            for ($i = 1; $i <= 12; $i++) {
                $dateObj = Carbon::create($currentYear, $i, 1);

                $labels[] = $dateObj->translatedFormat('M');

                $startOfMonth = $dateObj->copy()->startOfMonth()->toDateString();
                $endOfMonth = $dateObj->copy()->endOfMonth()->toDateString();

                $data[] = Attendance::whereBetween('date', [$startOfMonth, $endOfMonth])
                    ->whereIn('status', ['hadir', 'Tepat Waktu', 'terlambat'])
                    ->count();
            }
        }

        return [
            'datasets' => [
                [
                    'label' => 'Total Kehadiran Karyawan',
                    'data' => $data,
                    'backgroundColor' => '#2563eb',
                    'borderRadius' => 4,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }

    protected function getOptions(): array
    {
        return [
            'maintainAspectRatio' => false,
            'plugins' => [
                'legend' => [
                    'display' => false,
                ],
            ],
            'scales' => [
                'x' => [
                    'grid' => [
                        'display' => false,
                    ],
                    'ticks' => [
                        'font' => [
                            'weight' => 'bold',
                            'size' => 11,
                        ],
                    ],
                ],
                'y' => [
                    'min' => 0,
                    'ticks' => [
                        'stepSize' => 1,
                    ],
                    'title' => [
                        'display' => true,
                        'text' => 'Jumlah Karyawan Hadir',
                        'color' => '#9ca3af',
                        'font' => [
                            'weight' => 'bold',
                            'size' => 12,
                        ],
                    ],
                ],
            ],
        ];
    }
}