<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Position;

class PositionSeeder extends Seeder
{
    public function run()
    {
        $positions = [
            'HR Manager',
            'Kepala Divisi Marketing',
            'Kepala Divisi Interior Consultant',
            'Kepala Divisi Finance',
            'Kepala Divisi Warehouse',
            'Kepala Divisi Administrasi',
            'Administrasi',
            'Marketing',
            'Interior Consultant',
            'Finance',
            'Warehouse',
            'Ekspedisi',
            'Produksi',
            'Cleaning Service'
        ];

        foreach ($positions as $position) {
            Position::create(['name' => $position]);
        }
    }
}