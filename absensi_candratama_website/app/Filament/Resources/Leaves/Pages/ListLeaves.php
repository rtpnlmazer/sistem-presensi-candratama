<?php

namespace App\Filament\Resources\Leaves\Pages;

use App\Filament\Resources\Leaves\LeaveResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListLeaves extends ListRecords
{
    protected static string $resource = LeaveResource::class;

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Manajemen Kehadiran',
            url()->current() => 'Riwayat Izin & Sakit',
        ];
    }

    protected function getHeaderActions(): array
    {
        return [
        ];
    }
}