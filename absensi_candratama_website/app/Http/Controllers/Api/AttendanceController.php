<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Attendance;
use App\Models\Setting;
use App\Models\Leave;
use App\Models\CompanyHoliday;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'latitude' => 'required',
            'longitude' => 'required',
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
            'type' => 'required|in:Masuk,Keluar',
        ]);

        $user = $request->user();
        $today = Carbon::today('Asia/Jakarta')->toDateString();
        $currentTime = Carbon::now('Asia/Jakarta')->toTimeString();

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('attendances', 'public');
        }

        $latePhotoPath = null;
        if ($request->hasFile('late_photo')) {
            $latePhotoPath = $request->file('late_photo')->store('attendances/late', 'public');
        }

        $setting = Setting::first();
        if (!$setting) {
            return response()->json(['success' => false, 'message' => 'Pengaturan kantor belum dikonfigurasi.'], 500);
        }

        $distance = $this->calculateDistance($request->latitude, $request->longitude, $setting->office_latitude, $setting->office_longitude);
        if ($distance > $setting->radius) {
            return response()->json(['success' => false, 'message' => 'Anda berada di luar radius! Jarak: ' . round($distance) . 'm.'], 400);
        }

        $attendance = Attendance::where('user_id', $user->id)->where('date', $today)->first();

        if ($request->type == 'Masuk') {
            if ($attendance) {
                return response()->json(['success' => false, 'message' => 'Gagal! Anda sudah melakukan Presensi Masuk hari ini.'], 400);
            }

            $statusKehadiran = ($currentTime > $setting->time_in_limit) ? 'terlambat' : 'hadir';
            $newAttendance = Attendance::create([
                'user_id' => $user->id,
                'date' => $today,
                'time_in' => $currentTime,
                'lat_in' => $request->latitude,
                'long_in' => $request->longitude,
                'photo_in' => $imagePath,
                'status' => $statusKehadiran,
                'late_reason' => $request->late_reason,
                'late_photo' => $latePhotoPath,
            ]);

            return response()->json(['success' => true, 'message' => 'Berhasil Melakukan Presensi Masuk', 'data' => $newAttendance], 200);
        } else if ($request->type == 'Keluar') {
            if (!$attendance) {
                return response()->json(['success' => false, 'message' => 'Gagal! Anda belum melakukan Presensi Masuk hari ini.'], 400);
            }

            if ($attendance->time_out != null) {
                return response()->json(['success' => false, 'message' => 'Gagal! Anda sudah melakukan Presensi Keluar hari ini.'], 400);
            }
            $attendance->update([
                'time_out' => $currentTime,
                'lat_out' => $request->latitude,
                'long_out' => $request->longitude,
                'photo_out' => $imagePath,
            ]);

            return response()->json(['success' => true, 'message' => 'Berhasil Melakukan Presensi Keluar', 'data' => $attendance], 200);
        }
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371000;
        $latFrom = deg2rad($lat1);
        $lonFrom = deg2rad($lon1);
        $latTo = deg2rad($lat2);
        $lonTo = deg2rad($lon2);

        $latDelta = $latTo - $latFrom;
        $lonDelta = $lonTo - $lonFrom;

        $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
        return $angle * $earthRadius;
    }

    public function history(Request $request)
    {
        $user = $request->user();
        $month = $request->input('month');
        $year = $request->input('year');

        $query = Attendance::where('user_id', $user->id);

        if ($month && $year) {
            $query->whereMonth('date', $month)->whereYear('date', $year);
        }

        $history = $query->orderBy('date', 'desc')->get();

        if ($history->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Belum ada data riwayat presensi.',
                'data' => []
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Berhasil mengambil data riwayat presensi',
            'data' => $history
        ], 200);
    }

    public function getStatistics(Request $request)
    {
        $user = $request->user();
        $isAllTime = $request->query('all_time') === 'true';

        $waktuSekarang = Carbon::now('Asia/Jakarta');
        $hariIni = Carbon::today('Asia/Jakarta');
        $kemarin = Carbon::yesterday('Asia/Jakarta');

        $pengaturan = Setting::first();
        $jamPulangKantor = $pengaturan && $pengaturan->time_out_limit ? $pengaturan->time_out_limit : '16:30:00';
        $batasWaktuPulang = Carbon::parse($hariIni->format('Y-m-d') . ' ' . $jamPulangKantor);

        $batasDataNyata = $hariIni;
        $batasAlpha = $waktuSekarang->gt($batasWaktuPulang) ? $hariIni : $kemarin;

        if ($isAllTime) {
            $awalMulai = $user->created_at ? Carbon::parse($user->created_at)->startOfDay() : Carbon::now('Asia/Jakarta')->startOfMonth();
        } else {
            $bulan = $request->input('month', Carbon::now('Asia/Jakarta')->month);
            $tahun = $request->input('year', Carbon::now('Asia/Jakarta')->year);

            $awalBulan = Carbon::create($tahun, $bulan, 1, 0, 0, 0, 'Asia/Jakarta');
            $akhirBulan = $awalBulan->copy()->endOfMonth();

            if ($bulan == $hariIni->month && $tahun == $hariIni->year) {
                $batasDataNyata = $hariIni;
                $batasAlpha = $waktuSekarang->gt($batasWaktuPulang) ? $hariIni : $kemarin;
            } elseif ($awalBulan->isFuture()) {
                $batasDataNyata = $awalBulan->copy()->subDay();
                $batasAlpha = $batasDataNyata;
            } else {
                $batasDataNyata = $akhirBulan;
                $batasAlpha = $akhirBulan;
            }

            $tanggalGabung = $user->created_at ? Carbon::parse($user->created_at)->startOfDay() : $awalBulan->copy();
            $awalMulai = $tanggalGabung->gt($awalBulan) ? $tanggalGabung : $awalBulan;
        }

        if ($awalMulai->gt($batasDataNyata)) {
            return response()->json([
                'success' => true,
                'message' => 'Belum ada akumulasi statistik.',
                'data' => [
                    'tepat_waktu' => 0,
                    'terlambat' => 0,
                    'izin_sakit' => 0,
                    'alpha' => 0,
                    'akumulasi_menit_terlambat' => '0 Menit',
                ]
            ]);
        }

        $holidayDates = [];
        foreach (CompanyHoliday::all() as $h) {
            $start = Carbon::parse($h->start_date);
            $end = Carbon::parse($h->end_date);
            for ($d = $start->copy(); $d->lte($end); $d->addDay()) {
                $holidayDates[] = $d->format('Y-m-d');
            }
        }

        $googleHolidays = Cache::remember('kalender_libur_terbaru_' . $awalMulai->year, 86400, function () use ($awalMulai) {
            $apiKey = env('GOOGLE_CALENDAR_API_KEY');
            $h = [];
            if ($apiKey) {
                try {
                    $calendarId = urlencode('id.indonesian#holiday@group.v.calendar.google.com');
                    $timeMin = $awalMulai->copy()->startOfYear()->toRfc3339String();
                    $timeMax = $awalMulai->copy()->endOfYear()->toRfc3339String();
                    $url = "https://www.googleapis.com/calendar/v3/calendars/{$calendarId}/events?key={$apiKey}&timeMin={$timeMin}&timeMax={$timeMax}&singleEvents=true&timeZone=Asia/Jakarta";

                    $response = Http::timeout(5)->get($url);
                    if ($response->successful() && !empty($response->json('items'))) {
                        foreach ($response->json('items') as $item) {
                            $summary = strtolower($item['summary'] ?? '');
                            if (!str_contains($summary, 'cuti bersama') && !str_contains($summary, 'puasa') && !str_contains($summary, 'ramadhan')) {

                                $dateStr = null;
                                if (isset($item['start']['date'])) {
                                    $dateStr = substr($item['start']['date'], 0, 10);
                                } elseif (isset($item['start']['dateTime'])) {
                                    $dateStr = Carbon::parse($item['start']['dateTime'])->setTimezone('Asia/Jakarta')->format('Y-m-d');
                                }

                                if ($dateStr) {
                                    $h[] = $dateStr;
                                }
                            }
                        }
                    }
                } catch (\Exception $e) {
                }
            }
            return array_unique($h);
        });

        $hadirTepatWaktu = Attendance::where('user_id', $user->id)
            ->whereIn('status', ['hadir', 'Tepat Waktu'])
            ->whereBetween('date', [$awalMulai->format('Y-m-d'), $batasDataNyata->format('Y-m-d')])
            ->count();

        $terlambatRecords = Attendance::where('user_id', $user->id)
            ->where('status', 'terlambat')
            ->whereBetween('date', [$awalMulai->format('Y-m-d'), $batasDataNyata->format('Y-m-d')])
            ->get();

        $totalTerlambatHari = $terlambatRecords->count();

        $totalMenitTerlambat = 0;
        $jamMasukKantor = $pengaturan ? $pengaturan->time_in_limit : '07:30:00';
        foreach ($terlambatRecords as $absen) {
            $waktuMasuk = Carbon::parse($absen->date . ' ' . $absen->time_in);
            $batasWaktu = Carbon::parse($absen->date . ' ' . $jamMasukKantor);
            if ($waktuMasuk->gt($batasWaktu)) {
                $totalMenitTerlambat += $batasWaktu->diffInMinutes($waktuMasuk);
            }
        }
        $jam = floor($totalMenitTerlambat / 60);
        $menit = $totalMenitTerlambat % 60;
        $teksTerlambat = $jam > 0 ? "{$jam} Jam {$menit} Mnt" : "{$menit} Menit";

        $attendanceDatesNyata = Attendance::where('user_id', $user->id)
            ->whereIn('status', ['hadir', 'Tepat Waktu', 'terlambat'])
            ->whereBetween('date', [$awalMulai->format('Y-m-d'), $batasDataNyata->format('Y-m-d')])
            ->pluck('date')->toArray();

        $totalIzin = 0;
        $izinRecords = Leave::where('user_id', $user->id)->where('status', 'approved')->get();
        foreach ($izinRecords as $izin) {
            $start = Carbon::parse($izin->start_date);
            $end = Carbon::parse($izin->end_date);
            for ($d = $start->copy(); $d->lte($end); $d->addDay()) {
                $dateStr = $d->format('Y-m-d');
                if ($d->between($awalMulai, $batasDataNyata) && !$d->isSunday() && !in_array($dateStr, $holidayDates) && !in_array($dateStr, $googleHolidays)) {
                    if (!in_array($dateStr, $attendanceDatesNyata)) {
                        $totalIzin++;
                    }
                }
            }
        }

        $totalHariKerjaUntukAlpha = 0;
        for ($d = $awalMulai->copy(); $d->lte($batasAlpha); $d->addDay()) {
            $dateStr = $d->format('Y-m-d');
            if (!$d->isSunday() && !in_array($dateStr, $holidayDates) && !in_array($dateStr, $googleHolidays)) {
                $totalHariKerjaUntukAlpha++;
            }
        }

        $kehadiranAlpha = Attendance::where('user_id', $user->id)
            ->whereIn('status', ['hadir', 'Tepat Waktu', 'terlambat'])
            ->whereBetween('date', [$awalMulai->format('Y-m-d'), $batasAlpha->format('Y-m-d')])
            ->pluck('date')->toArray();

        $totalKehadiranAlpha = count(array_unique($kehadiranAlpha));

        $izinAlpha = 0;
        foreach ($izinRecords as $izin) {
            $start = Carbon::parse($izin->start_date);
            $end = Carbon::parse($izin->end_date);
            for ($d = $start->copy(); $d->lte($end); $d->addDay()) {
                $dateStr = $d->format('Y-m-d');
                if ($d->between($awalMulai, $batasAlpha) && !$d->isSunday() && !in_array($dateStr, $holidayDates) && !in_array($dateStr, $googleHolidays)) {
                    if (!in_array($dateStr, $kehadiranAlpha)) {
                        $izinAlpha++;
                    }
                }
            }
        }

        $alpha = max(0, $totalHariKerjaUntukAlpha - ($totalKehadiranAlpha + $izinAlpha));

        return response()->json([
            'success' => true,
            'message' => 'Berhasil memuat statistik karyawan.',
            'data' => [
                'tepat_waktu' => $hadirTepatWaktu,
                'terlambat' => $totalTerlambatHari,
                'izin_sakit' => $totalIzin,
                'alpha' => $alpha,
                'akumulasi_menit_terlambat' => $teksTerlambat,
            ]
        ], 200);
    }
}