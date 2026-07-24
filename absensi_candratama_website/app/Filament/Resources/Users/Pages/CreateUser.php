<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use Filament\Resources\Pages\CreateRecord;
use Filament\Notifications\Notification;
use Filament\Actions\Action;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected static ?string $title = 'Tambah Karyawan Baru';
    protected ?string $heading = 'Tambah Karyawan Baru';
    protected static ?string $breadcrumb = 'Tambah Karyawan Baru';

    protected function getCreateFormAction(): Action
    {
        return parent::getCreateFormAction()
            ->requiresConfirmation()
            ->modalIcon('heroicon-o-user-plus')
            ->modalIconColor('primary')
            ->modalHeading('Tambahkan Karyawan?')
            ->modalDescription('Apakah Anda yakin semua form kredensial karyawan baru ini sudah terisi dengan benar?')
            ->modalSubmitActionLabel('Ya, Tambahkan')
            ->modalCancelActionLabel('Periksa Lagi');
    }

    protected function getCreatedNotification(): ?Notification
    {
        return Notification::make()
            ->success()
            ->title('Karyawan Ditambahkan!')
            ->body('Data karyawan baru telah berhasil direkam ke dalam sistem.')
            ->duration(3000);
    }

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