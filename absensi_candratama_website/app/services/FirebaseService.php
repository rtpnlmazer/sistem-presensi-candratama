<?php

namespace App\Services;

use Google_Client;
use Illuminate\Support\Facades\Http;
use App\Models\User;

class FirebaseService
{
    public static function sendNotification($fcmToken, $title, $body)
    {
        if (!$fcmToken)
            return false;

        $credentialsFilePath = storage_path('app/firebase_credentials.json');

        if (!file_exists($credentialsFilePath)) {
            \Log::error("File firebase_credentials.json tidak ditemukan!");
            return false;
        }

        $credentials = json_decode(file_get_contents($credentialsFilePath), true);
        $projectId = $credentials['project_id'];

        $client = new Google_Client();
        $client->setAuthConfig($credentialsFilePath);
        $client->addScope('https://www.googleapis.com/auth/firebase.messaging');

        $token = $client->fetchAccessTokenWithAssertion();
        $accessToken = $token['access_token'];

        $payload = [
            'message' => [
                'token' => $fcmToken,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'android' => [
                    'notification' => [
                        'icon' => 'ic_notification',
                        'color' => '#DA2128',
                        'channel_id' => 'high_importance_channel',
                    ]
                ]
            ],
        ];

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $accessToken,
            'Content-Type' => 'application/json',
        ])->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", $payload);

        return $response->successful();
    }

    public static function sendToAllUsers($title, $body)
    {
        $users = User::whereNotNull('fcm_token')->where('role', 'pegawai')->get();
        $successCount = 0;

        foreach ($users as $user) {
            $isSent = self::sendNotification($user->fcm_token, $title, $body);
            if ($isSent) {
                $successCount++;
            }
        }

        return $successCount;
    }
}