<?php

namespace App\Filament\Resources\Overtimes\Pages;

use App\Filament\Resources\Overtimes\OvertimeResource;
use Filament\Resources\Pages\ListRecords;

class ListOvertimes extends ListRecords
{
    protected static string $resource = OvertimeResource::class;

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Manajemen Kehadiran',
            url()->current() => 'Riwayat Lembur',
        ];
    }
}