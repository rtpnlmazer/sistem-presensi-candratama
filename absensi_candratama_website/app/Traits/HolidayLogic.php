<?php

namespace App\Traits;

use Carbon\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use App\Models\CompanyHoliday;
use App\Models\Setting;

trait HolidayLogic
{
    public function getHariKerjaAktif($tahun, $bulan, $tanggalBergabung = null): int
    {
        $bulanTerpilih = Carbon::create($tahun, $bulan, 1)->startOfDay();
        $sekarang = Carbon::now();

        if ($bulanTerpilih->format('Y-m') > $sekarang->format('Y-m')) {
            return 0;
        }

        $startDate = $bulanTerpilih->copy();

        if ($tanggalBergabung) {
            $tglGabung = Carbon::parse($tanggalBergabung)->startOfDay();

            if ($bulanTerpilih->format('Y-m') < $tglGabung->format('Y-m')) {
                return 0;
            }

            if ($bulanTerpilih->format('Y-m') === $tglGabung->format('Y-m')) {
                $startDate = $tglGabung->copy();
            }
        }

        $pengaturan = Setting::first();
        $jamPulang = $pengaturan && $pengaturan->time_out_limit
            ? Carbon::parse($pengaturan->time_out_limit)->format('H:i')
            : '16:30';

        if ($sekarang->format('Y-m') === $bulanTerpilih->format('Y-m')) {
            if ($sekarang->format('H:i') >= $jamPulang) {
                $endDate = Carbon::today();
            } else {
                $endDate = Carbon::yesterday();
            }
        } else {
            $endDate = $bulanTerpilih->copy()->endOfMonth();
        }

        if ($startDate->gt($endDate)) {
            return 0;
        }

        $googleHolidaysList = [];
        $apiKey = env('GOOGLE_CALENDAR_API_KEY');

        if ($apiKey) {
            $calendarId = 'id.indonesian#holiday@group.v.calendar.google.com';
            $timeMin = $startDate->copy()->startOfDay()->toRfc3339String();
            $timeMax = $endDate->copy()->endOfDay()->toRfc3339String();

            $holidays = Cache::remember("holidays_month_{$tahun}_{$bulan}", 86400, function () use ($calendarId, $apiKey, $timeMin, $timeMax) {
                try {
                    $response = Http::timeout(5)->get('https://www.googleapis.com/calendar/v3/calendars/' . urlencode($calendarId) . '/events', [
                        'key' => $apiKey,
                        'timeMin' => $timeMin,
                        'timeMax' => $timeMax,
                        'singleEvents' => 'true',
                    ]);

                    if ($response->successful()) {
                        return $response->json('items') ?? [];
                    }
                } catch (\Exception $e) {
                }
                return [];
            });

            foreach ($holidays as $holiday) {
                if (isset($holiday['start']['date'])) {
                    $googleHolidaysList[] = Carbon::parse($holiday['start']['date'])->format('Y-m-d');
                }
            }
        }

        $companyHolidays = CompanyHoliday::where(function ($query) use ($startDate, $endDate) {
            $query->whereBetween('start_date', [$startDate, $endDate])
                ->orWhereBetween('end_date', [$startDate, $endDate])
                ->orWhere(function ($q) use ($startDate, $endDate) {
                    $q->where('start_date', '<=', $startDate)
                        ->where('end_date', '>=', $endDate);
                });
        })->get();

        $hariKerjaAktif = 0;
        $current = $startDate->copy();

        while ($current->lte($endDate)) {
            if ($current->isSunday()) {
                $current->addDay();
                continue;
            }

            if (in_array($current->format('Y-m-d'), $googleHolidaysList)) {
                $current->addDay();
                continue;
            }

            $isCompanyHoliday = false;
            foreach ($companyHolidays as $ch) {
                $startHol = Carbon::parse($ch->start_date)->startOfDay();
                $endHol = Carbon::parse($ch->end_date)->endOfDay();
                if ($current->between($startHol, $endHol)) {
                    $isCompanyHoliday = true;
                    break;
                }
            }

            if ($isCompanyHoliday) {
                $current->addDay();
                continue;
            }

            $hariKerjaAktif++;
            $current->addDay();
        }

        return $hariKerjaAktif;
    }
}