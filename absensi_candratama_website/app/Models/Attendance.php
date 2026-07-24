<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $fillable = [
        'user_id',
        'date',
        'time_in',
        'time_out',
        'lat_in',
        'long_in',
        'lat_out',
        'long_out',
        'photo_in',
        'photo_out',
        'status',
        'is_auto_checkout',
        'notes',
        'late_reason',
        'late_photo',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}