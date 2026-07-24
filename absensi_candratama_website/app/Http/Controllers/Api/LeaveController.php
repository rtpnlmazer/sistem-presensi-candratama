<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Leave;
use App\Models\User;

class LeaveController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|string',
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'reason' => 'required|string',
            'attachment' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
        ]);

        $path = null;
        if ($request->hasFile('attachment')) {
            $path = $request->file('attachment')->store('leaves', 'public');
        }

        $leave = Leave::create([
            'user_id' => $request->user()->id,
            'type' => $request->type,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'reason' => $request->reason,
            'attachment' => $path,
            'status' => 'pending'
        ]);

        try {
            $admins = User::where('role', 'admin')->get();

            if ($admins->isNotEmpty()) {
                foreach ($admins as $admin) {
                    $notification = \Filament\Notifications\Notification::make()
                        ->title('Pengajuan Izin Baru!')
                        ->body($request->user()->name . ' mengajukan izin/sakit (' . $request->type . ') dan menunggu persetujuan Anda.')
                        ->warning()
                        ->persistent()
                        ->icon('heroicon-o-clipboard-document-list');

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
            \Illuminate\Support\Facades\Log::error('Gagal kirim notif izin ke Admin: ' . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil dikirim dan menunggu persetujuan Admin.'
        ], 200);
    }

    public function history(Request $request)
    {
        $leaves = Leave::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $leaves
        ], 200);
    }
}