<?php

namespace App\Filament\Resources\Settings;

use App\Models\Setting;
use Filament\Resources\Resource;
use App\Filament\Resources\Settings\Pages;

use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\TimePicker;
use Filament\Forms\Components\Hidden;

use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Actions\EditAction;

use Cheesegrits\FilamentGoogleMaps\Fields\Map;

class SettingResource extends Resource
{
    protected static ?string $model = Setting::class;

    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-cog-8-tooth';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-cog-8-tooth';
    protected static ?string $navigationLabel = 'Pengaturan Presensi';
    protected static ?string $pluralModelLabel = 'Pengaturan Presensi';
    protected static ?string $modelLabel = 'Pengaturan Presensi';
    protected static ?string $breadcrumb = 'Pengaturan Presensi';

    protected static ?int $navigationSort = 4;

    public static function getNavigationGroup(): ?string
    {
        return 'Pengaturan Sistem';
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->columns(3)
            ->components([
                Section::make('Titik Lokasi Kantor')
                    ->compact()
                    ->columnSpan(2)
                    ->extraAttributes(['class' => 'h-full'])
                    ->schema([
                        Map::make('lokasi_kantor')
                            ->hiddenLabel()
                            ->defaultLocation([-7.815173, 111.997953])
                            ->geolocate()
                            ->geolocateLabel('Lokasi Saat Ini')
                            ->clickable()
                            ->live(onBlur: true)
                            ->extraAttributes([
                                'style' => 'min-height: 270px !important; height: 270px !important;'
                            ])
                            ->afterStateUpdated(function ($state, callable $set) {
                                if (is_array($state)) {
                                    $set('office_latitude', $state['lat']);
                                    $set('office_longitude', $state['lng']);
                                }
                            })
                            ->columnSpanFull(),

                        Hidden::make('office_latitude'),
                        Hidden::make('office_longitude'),
                    ]),

                Section::make('Batas & Aturan')
                    ->compact()
                    ->columnSpan(1)
                    ->extraAttributes(['class' => 'h-full'])
                    ->schema([
                        TextInput::make('radius')
                            ->label('Batas Radius (Meter)')
                            ->required()
                            ->numeric()
                            ->helperText('Batas toleransi jarak presensi Karyawan.')
                            ->columnSpanFull(),

                        TimePicker::make('start_time')
                            ->label('Jam Presensi Dibuka')
                            ->required()
                            ->seconds(false)
                            ->columnSpanFull(),

                        TimePicker::make('time_in_limit')
                            ->label('Batas Presensi Jam Masuk')
                            ->required()
                            ->seconds(false)
                            ->columnSpanFull(),

                        TimePicker::make('time_out_limit')
                            ->label('Batas Presensi Jam Pulang')
                            ->required()
                            ->seconds(false)
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->paginated(false)
            ->columns([
                TextColumn::make('office_latitude')
                    ->label('Titik Koordinat (Peta)')
                    ->formatStateUsing(fn($record) => number_format($record->office_latitude, 5) . ', ' . number_format($record->office_longitude, 5))
                    ->icon('heroicon-m-map-pin')
                    ->color('primary')
                    ->alignCenter(),

                TextColumn::make('radius')
                    ->label('Batas Radius')
                    ->formatStateUsing(fn($state) => $state . ' Meter')
                    ->badge()
                    ->color('success')
                    ->alignCenter(),

                TextColumn::make('time_in_limit')
                    ->label('Jam Kerja (WIB)')
                    ->formatStateUsing(fn($record) => substr($record->time_in_limit, 0, 5) . ' - ' . substr($record->time_out_limit, 0, 5))
                    ->icon('heroicon-m-clock')
                    ->color('warning')
                    ->alignCenter(),
            ])
            ->actions([
                EditAction::make()
                    ->label('Ubah Konfigurasi')
                    ->icon('heroicon-m-adjustments-horizontal'),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ManageSettings::route('/'),
            'edit' => Pages\EditSetting::route('/{record}/edit'),
        ];
    }
}