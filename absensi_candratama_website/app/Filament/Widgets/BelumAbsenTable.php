<?php

namespace App\Filament\Widgets;

use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use Carbon\Carbon;

class BelumAbsenTable extends BaseWidget
{
    protected static ?int $sort = 5;

    protected static bool $isLazy = false;

    protected int|string|array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        $today = Carbon::today();

        $isCompanyHoliday = \App\Models\CompanyHoliday::whereDate('start_date', '<=', $today)
            ->whereDate('end_date', '>=', $today)
            ->exists();

        if ($today->isSunday() || $isCompanyHoliday) {
            return $table
                ->query(User::query()->where('id', 0))
                ->heading('Daftar Karyawan Belum Melakukan Presensi Hari Ini')
                ->emptyStateHeading('Hari Ini Libur')
                ->emptyStateDescription('Tidak ada kewajiban presensi untuk hari ini.')
                ->emptyStateIcon('heroicon-o-face-smile')
                ->columns([
                    Tables\Columns\TextColumn::make('name')->label('Nama Karyawan'),
                    Tables\Columns\TextColumn::make('email')->label('Email Karyawan'),
                ]);
        }

        $sudahAbsen = Attendance::whereDate('date', $today)->pluck('user_id')->toArray();

        $sedangIzin = Leave::where('status', 'approved')
            ->whereDate('start_date', '<=', $today)
            ->whereDate('end_date', '>=', $today)
            ->pluck('user_id')->toArray();

        $dikecualikan = array_merge($sudahAbsen, $sedangIzin);

        return $table
            ->query(
                User::query()
                    ->whereNotIn('id', $dikecualikan)
                    ->where('id', '!=', 1)
            )
            ->heading('Daftar Karyawan Belum Melakukan Presensi Hari Ini')
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Nama Karyawan')
                    ->searchable()
                    ->weight('bold'),

                Tables\Columns\TextColumn::make('email')
                    ->label('Email Karyawan')
                    ->color('gray'),
            ])
            ->paginated([5]);
    }
}