<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Setting extends Model
{
    use HasFactory;

    protected $fillable = [
        'office_latitude',
        'office_longitude',
        'radius',
        'start_time',
        'time_in_limit',
        'time_out_limit',
    ];
}