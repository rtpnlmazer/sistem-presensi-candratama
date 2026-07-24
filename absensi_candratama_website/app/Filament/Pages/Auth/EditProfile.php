<?php

namespace App\Filament\Pages\Auth;

use Filament\Auth\Pages\EditProfile as BaseEditProfile;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Notifications\Notification;

class EditProfile extends BaseEditProfile
{
    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Informasi Akun')
                    ->description('Kelola detail profil lengkap Anda di sini.')
                    ->schema([
                        FileUpload::make('photo') 
                            ->hiddenLabel() 
                            ->avatar()
                            ->disk('public')
                            ->directory('profile-photos')
                            ->columnSpanFull()
                            ->extraFieldWrapperAttributes([
                                'style' => 'display: flex; justify-content: center; width: 100%;' 
                            ]),

                        $this->getNameFormComponent(),
                        $this->getEmailFormComponent(),

                        TextInput::make('phone')
                            ->label('Nomor HP / WhatsApp')
                            ->tel()
                            ->placeholder('Contoh: 081234567890')
                            ->maxLength(20),

                        $this->getPasswordFormComponent(),
                        $this->getPasswordConfirmationFormComponent(),
                    ])->columns(2)
            ]);
    }

    protected function getSavedNotification(): ?Notification
    {
        return null;
    }

    protected function afterSave(): void
    {
        $this->js(<<<JS
            const isDark = document.documentElement.classList.contains('dark');
            Swal.fire({
                icon: 'success',
                title: 'Berhasil Disimpan!',
                text: 'Perubahan data profil dan kata sandi Anda telah berhasil diperbarui.',
                confirmButtonText: 'Tutup',
                confirmButtonColor: '#3b82f6',
                background: isDark ? '#1e293b' : '#ffffff',
                color: isDark ? '#ffffff' : '#111827',
                backdrop: isDark ? 'rgba(15, 23, 42, 0.85)' : 'rgba(255, 255, 255, 0.65)',
                allowOutsideClick: false
            }).then(() => {
                window.location.reload();
            });
        JS);
    }
}