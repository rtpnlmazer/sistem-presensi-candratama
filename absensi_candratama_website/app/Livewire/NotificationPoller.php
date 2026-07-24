<?php

namespace App\Livewire;

use Livewire\Component;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class NotificationPoller extends Component
{
    public $lastCheck;

    public function mount()
    {
        $this->lastCheck = now()->toDateTimeString();
    }

    public function checkNewNotifications()
    {
        if (!Auth::check())
            return;

        $adaYangBaru = DB::table('notifications')
            ->where('notifiable_id', Auth::id())
            ->where('created_at', '>', $this->lastCheck)
            ->exists();

        if ($adaYangBaru) {
            $totalBelumDibaca = DB::table('notifications')
                ->where('notifiable_id', Auth::id())
                ->whereNull('read_at')
                ->count();

            Notification::make()
                ->title('Ada Izin Baru Masuk!')
                ->body("Terdapat {$totalBelumDibaca} pengajuan izin/sakit yang belum Anda baca. Silakan cek ikon lonceng.")
                ->warning()
                ->send();
        }

        $this->lastCheck = now()->toDateTimeString();
    }

    public function render()
    {
        return <<<'HTML'
            <div wire:poll.5s="checkNewNotifications" style="position: fixed; bottom: 10px; right: 10px; z-index: 9999; font-size: 11px; color: gray; opacity: 0.6; pointer-events: none;">
            </div>
        HTML;
    }
}