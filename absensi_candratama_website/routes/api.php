<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\LeaveController;
use App\Http\Controllers\Api\OvertimeController;
use App\Models\Setting;
use App\Models\AppNotification;

Route::post('/login', [AuthController::class, 'login']);

Route::get('/pengaturan-absensi', function () {
    $pengaturan = Setting::first();

    return response()->json([
        'success' => true,
        'data' => $pengaturan
    ]);
});

Route::middleware('auth:sanctum')->group(function () {

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/overtimes', [OvertimeController::class, 'store']);
    Route::get('/overtimes', [OvertimeController::class, 'history']);

    Route::get('/overtimes/history', [OvertimeController::class, 'history']);

    Route::get('/company-holidays', [\App\Http\Controllers\Api\CompanyHolidayController::class, 'index']);

    Route::post('/logout', [AuthController::class, 'logout']);

    Route::post('/update-profile-photo', [AuthController::class, 'updatePhoto']);

    Route::post('/update-profile', [AuthController::class, 'updateProfile']);

    Route::post('/change-password', [AuthController::class, 'changePassword']);

    Route::post('/attendances', [AttendanceController::class, 'store']);
    Route::get('/attendance/statistics', [App\Http\Controllers\Api\AttendanceController::class, 'getStatistics']);
    Route::get('/attendances/history', [AttendanceController::class, 'history']);

    Route::post('/leave-request', [LeaveController::class, 'store']);
    Route::get('/leave-history', [LeaveController::class, 'history']);
    Route::post('/leave-request/{id}/update', [LeaveController::class, 'update']);

    Route::post('/save-fcm-token', [AuthController::class, 'saveToken']);

    Route::get('/notifications', function (Illuminate\Http\Request $request) {
        $notifs = AppNotification::where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notifs
        ]);
    });

    Route::get('/notifications/unread-count', function (Illuminate\Http\Request $request) {
        $count = AppNotification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json(['success' => true, 'data' => $count]);
    });

    Route::post('/notifications/mark-read', function (Illuminate\Http\Request $request) {
        AppNotification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['success' => true]);
    });

    Route::get('/company-holidays', function () {
        return response()->json([
            'data' => \App\Models\CompanyHoliday::all()
        ], 200);
    });

    Route::post('/save-fcm-token', function (\Illuminate\Http\Request $request) {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $user = $request->user();
        $user->update(['fcm_token' => $request->fcm_token]);

        return response()->json(['message' => 'Token FCM berhasil disimpan.']);
    });

    Route::delete('/notifications/{id}', function ($id) {
        \Illuminate\Support\Facades\DB::table('app_notifications')
            ->where('id', $id)
            ->delete();

        return response()->json(['message' => 'Notifikasi berhasil dihapus'], 200);
    });

});