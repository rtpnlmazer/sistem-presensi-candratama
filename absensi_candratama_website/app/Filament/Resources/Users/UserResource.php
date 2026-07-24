<?php

namespace App\Filament\Resources\Users;

use App\Models\User;

use Filament\Resources\Resource;
use App\Filament\Resources\Users\Pages;

use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;

use Filament\Tables\Table;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;

use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ActionGroup;

use Illuminate\Support\HtmlString;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-users';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-users';
    protected static ?string $navigationLabel = 'Data Karyawan';
    protected static ?string $pluralModelLabel = 'Data Karyawan';
    protected static ?int $navigationSort = 3;

    public static function getNavigationGroup(): ?string
    {
        return 'Pengaturan Sistem';
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Foto Karyawan')
                    ->description(new HtmlString('Unggah pas foto resmi.
                        <style>
                            .kartu-kiri, .kartu-kanan { height: 100% !important; }
                            
                            .kartu-kiri > section, .kartu-kanan > section { 
                                height: 100% !important; 
                                display: flex; 
                                flex-direction: column; 
                                overflow: visible !important;
                            }
                            
                            .kartu-kiri > section > div:last-child { 
                                flex-grow: 1; 
                                display: flex; 
                                flex-direction: column; 
                                justify-content: center; 
                                overflow: visible !important;
                            }

                            .fi-section {
                                overflow: visible !important;
                            }
                        </style>
                    '))
                    ->schema([
                        FileUpload::make('photo')
                            ->hiddenLabel()
                            ->avatar()
                            ->disk('public')
                            ->directory('photos')
                            ->alignCenter(),
                    ])
                    ->columnSpan(['default' => 1, 'md' => 1])
                    ->extraAttributes(['class' => 'kartu-kiri']),

                Section::make('Informasi Akun Karyawan')
                    ->description('Lengkapi data diri dan kredensial akses.')
                    ->schema([
                        TextInput::make('name')
                            ->label('Nama Lengkap')
                            ->required()
                            ->maxLength(255),

                        TextInput::make('email')
                            ->label('Alamat Email')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->validationMessages([
                                'unique' => 'Data email tidak boleh sama. Email ini sudah digunakan oleh karyawan lain!',
                            ])
                            ->maxLength(255),

                        Select::make('position_id')
                            ->label('Divisi')
                            ->relationship('jabatan', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),

                        TextInput::make('phone')
                            ->label('Nomor HP / WhatsApp')
                            ->tel()
                            ->maxLength(255),

                        TextInput::make('nip')
                            ->label('NIK (Nomor Induk Karyawan)')
                            ->maxLength(50),

                        TextInput::make('address')
                            ->label('Alamat Lengkap Karyawan')
                            ->maxLength(255),

                        TextInput::make('password')
                            ->label('Kata Sandi Baru')
                            ->password()
                            ->revealable()
                            ->required(fn(string $context): bool => $context === 'create')
                            ->dehydrated(fn($state) => filled($state))
                            ->maxLength(255),
                    ])
                    ->columns(2)
                    ->columnSpan(['default' => 1, 'md' => 2])
                    ->extraAttributes(['class' => 'kartu-kanan']),
            ])
            ->columns(3);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('photo')
                    ->label('Foto')
                    ->disk('public')
                    ->circular()
                    ->defaultImageUrl(url('https://ui-avatars.com/api/?background=random&name=P'))
                    ->toggleable()
                    ->alignCenter(),

                TextColumn::make('name')
                    ->label('Nama Karyawan')
                    ->searchable()
                    ->sortable()
                    ->wrap()
                    ->alignCenter(),

                TextColumn::make('nip')
                    ->label('NIK')
                    ->searchable()
                    ->sortable()
                    ->copyable()
                    ->copyMessage('NIK berhasil disalin')
                    ->alignCenter(),

                TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->alignCenter(),

                TextColumn::make('jabatan.name')
                    ->label('Divisi')
                    ->searchable()
                    ->sortable()
                    ->badge()
                    ->color('info')
                    ->wrap()
                    ->alignCenter(),

                TextColumn::make('phone')
                    ->label('No HP / Whatsapp')
                    ->searchable()
                    ->sortable()
                    ->alignCenter(),

                TextColumn::make('created_at')
                    ->label('Terdaftar Pada')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true)
                    ->alignCenter(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                //
            ])
            ->actions([
                \Filament\Actions\EditAction::make()
                    ->iconButton()
                    ->tooltip('Ubah Data Karyawan'),

                \Filament\Actions\Action::make('reset_device')
                    ->iconButton()
                    ->tooltip('Reset Device ID')
                    ->icon('heroicon-o-device-phone-mobile')
                    ->color('warning')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Reset Device ID?',
                                text: 'Lakukan ini HANYA JIKA karyawan ganti HP atau HP rusak!',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#f59e0b',
                                cancelButtonColor: '#374151',
                                confirmButtonText: 'Ya, Reset Sekarang',
                                cancelButtonText: 'Batal',
                                background: '#1f2937',
                                color: '#ffffff'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    \$wire.mountTableAction('reset_device', '{$record->id}');
                                }
                            })
                        "
                    ])
                    ->action(function (\App\Models\User $record) {
                        $record->update(['device_id' => null]);
                        \Filament\Notifications\Notification::make()
                            ->title('Perangkat Berhasil Direset!')
                            ->success()
                            ->send();
                    }),
                \Filament\Actions\Action::make('hapus_pegawai')
                    ->iconButton()
                    ->tooltip('Hapus Kaeryawan')
                    ->icon('heroicon-m-trash')
                    ->color('danger')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Hapus Data Karyawan?',
                                text: 'Semua data yang terkait tidak akan dapat dikembalikan.',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#ef4444',
                                cancelButtonColor: '#374151',
                                confirmButtonText: 'Ya, Hapus Karyawan',
                                cancelButtonText: 'Batal',
                                background: '#1f2937',
                                color: '#ffffff'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    \$wire.mountTableAction('hapus_pegawai', '{$record->id}');
                                }
                            })
                        "
                    ])
                    ->action(function (\App\Models\User $record) {
                        $record->delete();
                        \Filament\Notifications\Notification::make()
                            ->title('Data karyawan berhasil dihapus!')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make()
                        ->requiresConfirmation()
                        ->modalHeading('Hapus Karyawan Terpilih')
                        ->modalDescription('Apakah Anda yakin ingin menghapus semua karyawan yang dicentang?')
                        ->modalSubmitActionLabel('Ya, Hapus Semua')
                        ->successNotificationTitle('Karyawan terpilih berhasil dihapus!'),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): \Illuminate\Database\Eloquent\Builder
    {
        return parent::getEloquentQuery()->where('role', '!=', 'admin');
    }
}