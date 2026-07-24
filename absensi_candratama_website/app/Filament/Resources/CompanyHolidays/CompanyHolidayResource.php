<?php

namespace App\Filament\Resources\CompanyHolidays;

use App\Filament\Resources\CompanyHolidays\Pages;
use App\Models\CompanyHoliday;

use Filament\Schemas\Schema;
use Filament\Tables\Table;
use Filament\Resources\Resource;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;

use Filament\Tables\Columns\TextColumn;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;

class CompanyHolidayResource extends Resource
{
    protected static ?string $model = CompanyHoliday::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-calendar-days';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-calendar-days';
    protected static ?string $navigationLabel = 'Libur Perusahaan';
    protected static ?string $pluralModelLabel = 'Libur Perusahaan';
    protected static ?string $modelLabel = 'Libur Perusahaan';

    protected static ?int $navigationSort = 4;

    public static function getNavigationGroup(): ?string
    {
        return 'Pengaturan Sistem';
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Schemas\Components\Section::make('Informasi Jadwal Libur')
                    ->description('Silakan lengkapi rentang tanggal dan keterangan libur di bawah ini.')
                    ->icon('heroicon-o-calendar')
                    ->schema([
                        DatePicker::make('start_date')
                            ->label('Tanggal Mulai')
                            ->required()
                            ->native(false)
                            ->minDate(now())
                            ->live()
                            ->prefixIcon('heroicon-m-calendar-days'),

                        DatePicker::make('end_date')
                            ->label('Tanggal Selesai')
                            ->required()
                            ->native(false)
                            ->minDate(fn($get) => $get('start_date') ?: now())
                            ->afterOrEqual('start_date')
                            ->prefixIcon('heroicon-m-calendar-days'),

                        TextInput::make('description')
                            ->label('Keterangan / Alasan')
                            ->placeholder('Contoh: Renovasi Kantor / Cuti Bersama Idul Fitri')
                            ->required()
                            ->maxLength(255)
                            ->prefixIcon('heroicon-m-document-text')
                            ->columnSpanFull(),
                    ])
                    ->columns(2)
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('start_date')
                    ->label('Tanggal Mulai')
                    ->date('d M Y')
                    ->sortable()
                    ->badge()
                    ->color('success')
                    ->alignCenter(),

                TextColumn::make('end_date')
                    ->label('Tanggal Selesai')
                    ->date('d M Y')
                    ->sortable()
                    ->badge()
                    ->color('danger')
                    ->alignCenter(),

                TextColumn::make('description')
                    ->label('Keterangan')
                    ->searchable()
                    ->wrap()
                    ->alignCenter(),
            ])
            ->filters([
                //
            ])
            ->actions([
                \Filament\Actions\Action::make('hapus_libur')
                    ->iconButton()
                    ->tooltip('Hapus Libur')
                    ->icon('heroicon-m-trash')
                    ->color('danger')
                    ->extraAttributes(fn($record) => [
                        'x-on:click.capture' => "
                            \$event.stopImmediatePropagation();
                            \$event.preventDefault();
                            Swal.fire({
                                title: 'Hapus Jadwal Libur?',
                                text: 'Data libur ini tidak akan dapat dikembalikan.',
                                icon: 'warning',
                                showCancelButton: true,
                                confirmButtonColor: '#ef4444',
                                cancelButtonColor: '#374151',
                                confirmButtonText: 'Ya, Hapus',
                                cancelButtonText: 'Batal',
                                background: '#1f2937',
                                color: '#ffffff'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    \$wire.mountTableAction('hapus_libur', '{$record->id}');
                                }
                            })
                        "
                    ])
                    ->action(function (\App\Models\CompanyHoliday $record) {
                        $record->delete();
                        \Filament\Notifications\Notification::make()
                            ->title('Jadwal libur berhasil dihapus!')
                            ->success()
                            ->send();
                    }),
            ])
            ->bulkActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make()
                        ->requiresConfirmation()
                        ->modalHeading('Hapus Libur Terpilih')
                        ->modalDescription('Apakah Anda yakin ingin menghapus semua jadwal libur yang dicentang?')
                        ->modalSubmitActionLabel('Ya, Hapus Semua')
                        ->successNotificationTitle('Jadwal libur terpilih berhasil dihapus!'),
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
            'index' => Pages\ListCompanyHolidays::route('/'),
            'create' => Pages\CreateCompanyHoliday::route('/create'),
            'edit' => Pages\EditCompanyHoliday::route('/{record}/edit'),
        ];
    }
}