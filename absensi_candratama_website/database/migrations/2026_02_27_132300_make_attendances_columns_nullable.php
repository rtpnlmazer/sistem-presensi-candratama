<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->time('time_in')->nullable()->change();
            $table->string('photo_in')->nullable()->change();
            $table->string('lat_in')->nullable()->change();
            $table->string('long_in')->nullable()->change();

            $table->time('time_out')->nullable()->change();
            $table->string('photo_out')->nullable()->change();
            $table->string('lat_out')->nullable()->change();
            $table->string('long_out')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            //
        });
    }
};
