<?php

namespace App\Filament\Resources\Settings\Pages;

use App\Filament\Resources\Settings\SettingResource;
use Filament\Resources\Pages\ManageRecords;

class ManageSettings extends ManageRecords
{
    protected static string $resource = SettingResource::class;

    protected static ?string $title = 'Pengaturan Presensi';
    protected ?string $heading = 'Pengaturan Presensi';

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Pengaturan Sistem',
            url()->current() => 'Pengaturan Presensi',
        ];
    }

    protected function getHeaderActions(): array
    {
        return [];
    }
}