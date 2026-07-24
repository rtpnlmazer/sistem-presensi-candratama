<?php

namespace App\Filament\Resources\Attendances\Pages;

use App\Filament\Resources\Attendances\AttendanceResource;
use Filament\Resources\Pages\ListRecords;

class ListAttendances extends ListRecords
{
    protected static string $resource = AttendanceResource::class;

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Manajemen Kehadiran',
            url()->current() => 'Riwayat Presensi',
        ];
    }

    protected function getHeaderActions(): array
    {
        return [
        ];
    }
}