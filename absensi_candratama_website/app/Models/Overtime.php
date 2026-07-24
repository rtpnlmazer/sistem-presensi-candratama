<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Overtime extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'date',
        'start_time',
        'end_time',
        'reason',
        'status',
        'reject_reason',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}