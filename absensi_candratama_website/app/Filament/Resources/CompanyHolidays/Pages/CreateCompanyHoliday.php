<?php

namespace App\Filament\Resources\CompanyHolidays\Pages;

use App\Filament\Resources\CompanyHolidays\CompanyHolidayResource;
use Filament\Resources\Pages\CreateRecord;

class CreateCompanyHoliday extends CreateRecord
{
    protected static string $resource = CompanyHolidayResource::class;

    protected static ?string $title = 'Tambah Libur Perusahaan Baru';

    protected ?string $heading = 'Tambah Libur Perusahaan Baru';

    protected static ?string $breadcrumb = 'Tambah Libur Perusahaan Baru';

    protected function getFormActions(): array
    {
        return [
            $this->getCreateFormAction(),
            $this->getCancelFormAction(),
        ];
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}