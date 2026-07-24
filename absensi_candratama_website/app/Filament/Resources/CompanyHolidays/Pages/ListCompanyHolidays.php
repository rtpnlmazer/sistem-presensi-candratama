<?php

namespace App\Filament\Resources\CompanyHolidays\Pages;

use App\Filament\Resources\CompanyHolidays\CompanyHolidayResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCompanyHolidays extends ListRecords
{
    protected static string $resource = CompanyHolidayResource::class;

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            '' => 'Pengaturan Sistem',
            url()->current() => 'Libur Perusahaan',
        ];
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('Tambah Libur Perusahaan Baru')
        ];
    }
}