<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Auth\Events\Login;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;
use Filament\Notifications\Notification;
use App\Models\User;
use Illuminate\Support\Facades\URL;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
    }

    public function boot(): void
    {
        Event::listen(function (Login $event) {

            $user = $event->user;

            if ($user instanceof User && request()->is('admin*')) {

                if ($user->role !== 'admin') {

                    Auth::logout();

                    Notification::make()
                        ->title('Akses Ditolak!')
                        ->body('Akun karyawan dilarang mengakses halaman Web Admin.')
                        ->danger()
                        ->persistent()
                        ->send();

                    throw ValidationException::withMessages([
                        'data.email' => 'Silakan gunakan aplikasi mobile untuk Karyawan.',
                    ]);
                }
            }
        });

        if (str_contains(request()->getHost(), 'ngrok')) {
            URL::forceScheme('https');
        }
    }
}