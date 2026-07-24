<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Attendance;
use Carbon\Carbon;
use App\Models\User;
use App\Services\FirebaseService;

class AutoCheckout extends Command
{
    protected $signature = 'attendance:auto-checkout';

    protected $description = 'Melakukan auto-checkout untuk karyawan yang lupa presensi pulang pada jam 23:59';

    public function handle()
    {
        $today = Carbon::today('Asia/Jakarta')->toDateString();

        $lupaPresensiPulang = Attendance::where('date', $today)
            ->whereNull('time_out')
            ->get();

        $count = 0;

        foreach ($lupaPresensiPulang as $presensi) {
            /** @var \App\Models\Attendance $presensi */

            $presensi->time_out = '23:59:00';
            $presensi->is_auto_checkout = true;
            $presensi->notes = 'Sistem Auto-Checkout: Lupa Presensi Pulang';
            $presensi->save();

            $count++;

            $user = User::find($presensi->user_id);

            if ($user && $user->fcm_token) {
                $judul = "Sistem Auto-Checkout Presensi";
                $pesan = "Halo {$user->name}, Anda lupa melakukan presensi pulang hari ini. Sistem telah menutup presensi Anda secara otomatis.";

                FirebaseService::sendNotification($user->fcm_token, $judul, $pesan);
            }
        }

        $this->info("Robot Auto-Checkout selesai! Berhasil menutup {$count} data presensi yang menggantung.");
    }
}