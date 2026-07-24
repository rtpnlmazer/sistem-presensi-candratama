<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use App\Models\CompanyHoliday;
use App\Models\Setting;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class MarkAlphaAttendance extends Command
{
    protected $signature = 'attendance:mark-alpha';
    protected $description = 'Menandai Karyawan sebagai Alpha jika tidak ada presensi masuk dan tidak ada izin/sakit';
    public function isHariLibur(Carbon $date): bool
    {
        if ($date->isSunday())
            return true;

        $isCompanyHoliday = CompanyHoliday::whereDate('start_date', '<=', $date->format('Y-m-d'))
            ->whereDate('end_date', '>=', $date->format('Y-m-d'))
            ->exists();

        if ($isCompanyHoliday)
            return true;

        $apiKey = env('GOOGLE_CALENDAR_API_KEY');
        if (!$apiKey)
            return false;

        $calendarId = 'id.indonesian#holiday@group.v.calendar.google.com';
        $timeMin = $date->copy()->startOfDay()->toRfc3339String();
        $timeMax = $date->copy()->endOfDay()->toRfc3339String();

        try {
            $response = Http::timeout(3)->get('https://www.googleapis.com/calendar/v3/calendars/' . urlencode($calendarId) . '/events', [
                'key' => $apiKey,
                'timeMin' => $timeMin,
                'timeMax' => $timeMax,
                'singleEvents' => 'true',
            ]);

            if ($response->successful() && !empty($response->json('items'))) {
                $targetDate = $date->format('Y-m-d');
                foreach ($response->json('items') as $item) {
                    $summary = strtolower($item['summary'] ?? '');
                    if (str_contains($summary, 'cuti bersama') || str_contains($summary, 'puasa') || str_contains($summary, 'ramadhan'))
                        continue;
                    if (($item['start']['date'] ?? null) === $targetDate)
                        return true;
                }
            }
        } catch (\Exception $e) {
        }

        return false;
    }

    public function handle()
    {
        $today = Carbon::today('Asia/Jakarta');
        $waktuSekarang = Carbon::now('Asia/Jakarta');

        $pengaturan = Setting::first();
        $jamPulang = $pengaturan && $pengaturan->time_out_limit
            ? Carbon::parse($pengaturan->time_out_limit, 'Asia/Jakarta')->format('H:i')
            : '16:30';

        if ($waktuSekarang->format('H:i') < $jamPulang) {
            $this->warn("Aksi Ditolak: Jam kerja belum selesai! Anda tidak bisa menandai Alpha sebelum jam {$jamPulang} WIB.");
            return;
        }

        if ($this->isHariLibur($today)) {
            $this->info("Aksi Dibatalkan: Sistem mendeteksi hari ini adalah Hari Libur Nasional / Perusahaan / Hari Minggu. Tidak ada pencatatan Alpha.");
            return;
        }

        $users = User::all();
        $count = 0;
        $tanggalHariIniString = $today->toDateString();

        foreach ($users as $user) {

            if ($user->role !== 'pegawai') {
                continue;
            }

            $hasStartedUsingApp = Attendance::where('user_id', $user->id)
                ->whereNotNull('time_in')
                ->exists();

            if (!$hasStartedUsingApp) {
                continue;
            }

            $hasAttendance = Attendance::where('user_id', $user->id)
                ->whereDate('date', $tanggalHariIniString)
                ->exists();

            $hasLeave = Leave::where('user_id', $user->id)
                ->where('status', 'approved')
                ->whereDate('start_date', '<=', $tanggalHariIniString)
                ->whereDate('end_date', '>=', $tanggalHariIniString)
                ->exists();

            if (!$hasAttendance && !$hasLeave) {
                Attendance::create([
                    'user_id' => $user->id,
                    'date' => $tanggalHariIniString,
                    'status' => 'tidak_hadir',
                    'notes' => 'Sistem Otomatis: Karyawan tidak hadir tanpa keterangan (Alpha).',
                ]);

                $count++;
            }
        }

        $this->info("Berhasil menandai {$count} karyawan sebagai Tidak Hadir (Alpha) pada tanggal {$tanggalHariIniString}.");
    }
}