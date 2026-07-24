<?php

namespace App\Filament\Resources\CompanyHolidays\Pages;

use App\Filament\Resources\CompanyHolidays\CompanyHolidayResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditCompanyHoliday extends EditRecord
{
    protected static string $resource = CompanyHolidayResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
