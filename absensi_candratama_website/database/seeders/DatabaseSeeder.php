<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Setting;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        User::create([
            'nip' => '00001',
            'name' => 'Admin',
            'email' => 'admin@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Manager',
        ]);

        User::create([
            'nip' => '00002',
            'name' => 'Amirada Nur Laily',
            'email' => 'amirada@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Kepala Divisi Marketing',
        ]);

        User::create([
            'nip' => '00003',
            'name' => 'Fatimatusyafa Alfafa',
            'email' => 'alfafa@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Marketing',
        ]);

        User::create([
            'nip' => '00004',
            'name' => 'Muamar Maulana Alvarez',
            'email' => 'alvarez@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Marketing',
        ]);

        User::create([
            'nip' => '00005',
            'name' => 'Daniar Isti Rahmawati',
            'email' => 'daniar@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Marketing',
        ]);

        User::create([
            'nip' => '0006',
            'name' => 'Reza Maulana Putra',
            'email' => 'reza@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Marketing',
        ]);

        User::create([
            'nip' => '0007',
            'name' => 'Tabea Al-Haq',
            'email' => 'tabea@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Finance',
        ]);

        User::create([
            'nip' => '0008',
            'name' => 'Putri Nur Aisyah',
            'email' => 'putri@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Finance',
        ]);

        User::create([
            'nip' => '0009',
            'name' => 'Rizki Kurniawan',
            'email' => 'rizki@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Finance',
        ]);

        User::create([
            'nip' => '0010',
            'name' => 'Ahmad Khoirudin',
            'email' => 'ahmad@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Warehouse',
        ]);

        User::create([
            'nip' => '0011',
            'name' => 'Achmad Fauzi',
            'email' => 'achmad@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Cleaning Service',
        ]);

        User::create([
            'nip' => '0012',
            'name' => 'Rafika Pungki',
            'email' => 'rafika@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'pegawai',
            'phone' => '081234567890',
            'address' => 'Kota Kediri, Jawa Timur',
            'position' => 'Finance',
        ]);

        Setting::create([
            'office_latitude' => '-7.815173468366822',
            'office_longitude' => '111.99795326461442',
            'radius' => 25,
            'time_in_limit' => '07:30:00',
            'time_out_limit' => '16:30:00',
        ]);
    }
}