<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Overtime;
use App\Models\Attendance;
use App\Models\Setting;
use Carbon\Carbon;

class OvertimeController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'date' => 'required|date',
            'start_time' => 'required|string',
            'end_time' => 'required|string',
            'reason' => 'required|string',
        ]);

        $overtime = \App\Models\Overtime::create([
            'user_id' => $request->user()->id,
            'date' => $request->date,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'reason' => $request->reason,
            'status' => 'pending'
        ]);

        try {
            $admins = \App\Models\User::where('role', 'admin')->get();

            if ($admins->isNotEmpty()) {
                foreach ($admins as $admin) {
                    $notification = \Filament\Notifications\Notification::make()
                        ->title('Pengajuan Lembur Baru!')
                        ->body($request->user()->name . ' mengajukan lembur pada ' . $request->date . ' dan menunggu persetujuan Anda.')
                        ->warning()
                        ->persistent()
                        ->icon('heroicon-o-clock');

                    $notifData = $notification->toArray();
                    $notifData['format'] = 'filament';

                    \Illuminate\Support\Facades\DB::table('notifications')->insert([
                        'id' => $notifData['id'],
                        'type' => 'Filament\Notifications\DatabaseNotification',
                        'notifiable_type' => get_class($admin),
                        'notifiable_id' => $admin->id,
                        'data' => json_encode($notifData),
                        'read_at' => null,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::error('Gagal kirim notif lembur ke Admin: ' . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan lembur berhasil dikirim dan menunggu persetujuan Admin.'
        ], 200);
    }

    public function history(Request $request)
    {
        $user = $request->user();

        $history = \App\Models\Overtime::where('user_id', $user->id)
            ->orderBy('date', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $history
        ], 200);
    }
}