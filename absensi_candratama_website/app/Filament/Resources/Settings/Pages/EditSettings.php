<?php

namespace App\Filament\Resources\Settings\Pages;

use App\Filament\Resources\Settings\SettingResource;
use Filament\Resources\Pages\EditRecord;

class EditSetting extends EditRecord
{
    public array $pendingNotifications = [];

    public function getBreadcrumbs(): array
    {
        return [
            url('/admin') => 'Dasbor',
            $this->getResource()::getUrl('index') => 'Pengaturan Presensi',
            '' => 'Ubah Konfigurasi',
        ];
    }

    protected ?string $heading = 'Ubah Konfigurasi';
    protected static string $resource = SettingResource::class;

    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data['lokasi_kantor'] = [
            'lat' => (float) ($data['office_latitude'] ?? -7.815173),
            'lng' => (float) ($data['office_longitude'] ?? 111.997953),
        ];
        return $data;
    }

    protected function mutateFormDataBeforeSave(array $data): array
    {
        unset($data['lokasi_kantor']);

        $oldTimeIn = substr($this->record->time_in_limit ?? '', 0, 5);
        $newTimeIn = substr($data['time_in_limit'] ?? '', 0, 5);

        if ($oldTimeIn !== $newTimeIn) {
            $this->pendingNotifications[] = [
                'title' => 'Perubahan Jam Masuk Kerja',
                'body' => "Terdapat penyesuaian jam masuk kerja terbaru menjadi pukul {$newTimeIn} WIB.",
            ];
        }

        $oldTimeOut = substr($this->record->time_out_limit ?? '', 0, 5);
        $newTimeOut = substr($data['time_out_limit'] ?? '', 0, 5);

        if ($oldTimeOut !== $newTimeOut) {
            $this->pendingNotifications[] = [
                'title' => 'Perubahan Jam Pulang Kerja',
                'body' => "Terdapat penyesuaian jam pulang kerja terbaru menjadi pukul {$newTimeOut} WIB.",
            ];
        }

        $oldLat = round((float) ($this->record->office_latitude ?? 0), 5);
        $newLat = round((float) ($data['office_latitude'] ?? 0), 5);
        $oldLng = round((float) ($this->record->office_longitude ?? 0), 5);
        $newLng = round((float) ($data['office_longitude'] ?? 0), 5);

        if ($oldLat !== $newLat || $oldLng !== $newLng) {
            $this->pendingNotifications[] = [
                'title' => 'Perubahan Lokasi Kantor',
                'body' => 'Terdapat perubahan lokasi koordinat kantor terbaru. Harap periksa kembali jangkauan radius presensi di aplikasi.',
            ];
        }

        return $data;
    }

    protected function afterSave(): void
    {
        if (empty($this->pendingNotifications)) {
            return;
        }

        $daftarPegawai = \App\Models\User::where('role', 'pegawai')->get();

        foreach ($this->pendingNotifications as $notif) {
            foreach ($daftarPegawai as $pegawai) {

                \Illuminate\Support\Facades\DB::table('app_notifications')->insert([
                    'user_id' => $pegawai->id,
                    'title' => $notif['title'],
                    'body' => $notif['body'],
                    'is_read' => false,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                if ($pegawai->fcm_token) {
                    try {
                        \App\Services\FirebaseService::sendNotification(
                            $pegawai->fcm_token,
                            $notif['title'],
                            $notif['body']
                        );
                    } catch (\Exception $e) {
                        \Illuminate\Support\Facades\Log::error("Gagal mengirim FCM ke User ID {$pegawai->id}: " . $e->getMessage());
                    }
                }
            }
        }

        \Filament\Notifications\Notification::make()
            ->title('Konfigurasi Berhasil Disimpan')
            ->body('Notifikasi perubahan presensi telah disiarkan kepada seluruh karyawan.')
            ->success()
            ->send();
    }

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }
}