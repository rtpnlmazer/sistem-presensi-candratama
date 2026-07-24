<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Filament\Models\Contracts\FilamentUser;
use Filament\Models\Contracts\HasAvatar;
use App\Models\Position;
use App\Models\Overtime;

class User extends Authenticatable implements FilamentUser, HasAvatar
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'position_id',
        'device_id',
        'photo',
        'nip',
        'role',
        'phone',
        'position',
        'address',
        'fcm_token',
    ];

    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function canAccessPanel(\Filament\Panel $panel): bool
    {
        if ($this->role === 'admin') {
            return true;
        }

        \Illuminate\Support\Facades\Auth::logout();

        throw \Illuminate\Validation\ValidationException::withMessages([
            'data.email' => 'PEGAWAI_ERROR_CODE',
        ]);
    }

    public function getFilamentAvatarUrl(): ?string
    {
        return $this->photo ? asset('storage/' . $this->photo) : null;
    }

    public function overtimes()
    {
        return $this->hasMany(Overtime::class, 'user_id');
    }

    public function jabatan()
    {
        return $this->belongsTo(Position::class, 'position_id');
    }
}
