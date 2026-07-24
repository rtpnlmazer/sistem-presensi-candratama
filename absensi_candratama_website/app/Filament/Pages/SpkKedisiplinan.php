<?php

namespace App\Filament\Pages;

use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use Carbon\Carbon;
use Filament\Pages\Page;
use App\Traits\HolidayLogic;

use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Schemas\Schema;
use Filament\Forms\Components\Select;
use Livewire\WithPagination;
use Illuminate\Pagination\LengthAwarePaginator;

class SpkKedisiplinan extends Page implements HasForms
{
    use HolidayLogic, InteractsWithForms, WithPagination;
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-chart-bar';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-chart-bar';
    protected static ?string $navigationLabel = 'Peringkat Kedisiplinan';
    protected static ?string $title = 'Peringkat Kedisiplinan';
    protected string $view = 'filament.pages.spk-kedisiplinan';

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Manajemen Kehadiran',
            url()->current() => 'Peringkat Kedisiplinan',
        ];
    }

    public ?array $data = [];

    public static function getNavigationGroup(): ?string
    {
        return 'Manajemen Kehadiran';
    }

    public function mount(): void
    {
        $this->form->fill([
            'bulan' => Carbon::now()->month,
            'tahun' => Carbon::now()->year,
        ]);
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Select::make('bulan')
                    ->label('Bulan')
                    ->options([
                        1 => 'Januari',
                        2 => 'Februari',
                        3 => 'Maret',
                        4 => 'April',
                        5 => 'Mei',
                        6 => 'Juni',
                        7 => 'Juli',
                        8 => 'Agustus',
                        9 => 'September',
                        10 => 'Oktober',
                        11 => 'November',
                        12 => 'Desember',
                    ])
                    ->live()
                    ->afterStateUpdated(fn() => $this->resetPage())
                    ->required(),

                Select::make('tahun')
                    ->label('Tahun')
                    ->options(function () {
                        $years = [];
                        $currentYear = date('Y');
                        for ($i = 0; $i <= 5; $i++) {
                            $years[$currentYear - $i] = $currentYear - $i;
                        }
                        return $years;
                    })
                    ->live()
                    ->afterStateUpdated(fn() => $this->resetPage())
                    ->required(),
            ])
            ->columns(2)
            ->statePath('data');
    }

    public function getPeriodeTeks(): string
    {
        $bulanTerpilih = $this->data['bulan'] ?? Carbon::now()->month;
        $tahunTerpilih = $this->data['tahun'] ?? Carbon::now()->year;

        $namaBulan = [
            1 => 'Januari',
            2 => 'Februari',
            3 => 'Maret',
            4 => 'April',
            5 => 'Mei',
            6 => 'Juni',
            7 => 'Juli',
            8 => 'Agustus',
            9 => 'September',
            10 => 'Oktober',
            11 => 'November',
            12 => 'Desember',
        ];

        return $namaBulan[$bulanTerpilih] . ' ' . $tahunTerpilih;
    }

    public function getSpkData()
    {
        $bulanTerpilih = (int) ($this->data['bulan'] ?? Carbon::now()->month);
        $tahunTerpilih = (int) ($this->data['tahun'] ?? Carbon::now()->year);

        $pegawais = User::where('id', '!=', 1)->get();
        $hasilAkhir = [];

        foreach ($pegawais as $pegawai) {
            $hariKerjaValid = $this->getHariKerjaAktif($tahunTerpilih, $bulanTerpilih, $pegawai->created_at);

            $hadirTepat = Attendance::where('user_id', $pegawai->id)
                ->whereMonth('date', $bulanTerpilih)->whereYear('date', $tahunTerpilih)
                ->where('status', 'hadir')->count();

            $terlambat = Attendance::where('user_id', $pegawai->id)
                ->whereMonth('date', $bulanTerpilih)->whereYear('date', $tahunTerpilih)
                ->where('status', 'terlambat')->count();

            $izin = Leave::where('user_id', $pegawai->id)
                ->whereMonth('start_date', $bulanTerpilih)->whereYear('start_date', $tahunTerpilih)
                ->where('status', 'approved')->count();

            $alpha = 0;
            if ($hariKerjaValid > 0) {
                $alpha = $hariKerjaValid - ($hadirTepat + $terlambat + $izin);
                if ($alpha < 0) {
                    $alpha = 0;
                }
            }

            $skorAwal = 100;
            $potonganTerlambat = $terlambat * 3;
            $potonganIzin = $izin * 1;           
            $potonganAlpha = $alpha * 5;

            $skorAkhir = $skorAwal - $potonganTerlambat - $potonganIzin - $potonganAlpha;

            if ($skorAkhir < 0) {
                $skorAkhir = 0;
            }

            $hasilAkhir[] = [
                'nama' => $pegawai->name,
                'c1' => $hadirTepat,
                'c2' => $terlambat,
                'c3' => $izin,
                'c4' => $alpha,
                'skor' => $skorAkhir
            ];
        }

        usort($hasilAkhir, function ($a, $b) {
            return $b['skor'] <=> $a['skor'];
        });

        foreach ($hasilAkhir as $index => $item) {
            $hasilAkhir[$index]['rank'] = $index + 1;
        }

        $perPage = 10;
        $currentPage = \Illuminate\Pagination\Paginator::resolveCurrentPage() ?: 1;
        $collection = collect($hasilAkhir);
        $pagedData = $collection->slice(($currentPage - 1) * $perPage, $perPage)->all();

        return new LengthAwarePaginator(
            $pagedData,
            $collection->count(),
            $perPage,
            $currentPage,
            ['path' => request()->url(), 'query' => request()->query()]
        );
    }
}