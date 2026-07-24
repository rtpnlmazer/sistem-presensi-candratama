<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\AppNotification;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class CompanyHoliday extends Model
{
    use HasFactory;

    protected $fillable = [
        'start_date',
        'end_date',
        'description',
    ];

    protected static function booted()
    {
        static::created(function ($holiday) {
            $mulai = Carbon::parse($holiday->start_date)->locale('id')->translatedFormat('d F Y');
            $selesai = Carbon::parse($holiday->end_date)->locale('id')->translatedFormat('d F Y');
            $teksTanggal = ($mulai === $selesai) ? $mulai : "$mulai sampai $selesai";

            $users = User::whereNotNull('fcm_token')->get();
            $tokens = [];

            foreach ($users as $user) {
                AppNotification::create([
                    'user_id' => $user->id,
                    'title' => 'Pengumuman Libur',
                    'body' => "Kantor akan diliburkan pada $teksTanggal. Keterangan: {$holiday->description}",
                ]);
                $tokens[] = $user->fcm_token;
            }

            if (count($tokens) > 0) {
                try {
                    $messaging = app('firebase.messaging');
                    $message = CloudMessage::new()->withNotification(
                        Notification::create('Pengumuman Libur', "Kantor akan diliburkan pada $teksTanggal. Keterangan: {$holiday->description}")
                    );

                    $messaging->sendMulticast($message, $tokens);
                } catch (\Exception $e) {
                    Log::error('Gagal kirim FCM Libur Masal: ' . $e->getMessage());
                }
            }
        });
    }
}