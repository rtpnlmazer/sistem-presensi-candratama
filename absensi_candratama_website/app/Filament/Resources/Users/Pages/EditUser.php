<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use Filament\Resources\Pages\EditRecord;
use Filament\Notifications\Notification;
use Filament\Actions\Action;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected static ?string $title = 'Ubah Data Karyawan';
    protected ?string $heading = 'Ubah Data Karyawan';
    protected static ?string $breadcrumb = 'Ubah Data Karyawan';

    protected function getHeaderActions(): array
    {
        return [];
    }

    protected function getSaveFormAction(): Action
    {
        return parent::getSaveFormAction()
            ->requiresConfirmation()
            ->modalIcon('heroicon-o-exclamation-triangle')
            ->modalIconColor('warning')
            ->modalHeading('Simpan Perubahan?')
            ->modalDescription('Apakah Anda yakin data karyawan ini sudah benar dan ingin menyimpannya ke sistem?')
            ->modalSubmitActionLabel('Ya, Simpan')
            ->modalCancelActionLabel('Batal');
    }

    protected function getSavedNotification(): ?Notification
    {
        return Notification::make()
            ->success()
            ->title('Berhasil!')
            ->body('Data karyawan berhasil diperbarui.')
            ->duration(3000);
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}