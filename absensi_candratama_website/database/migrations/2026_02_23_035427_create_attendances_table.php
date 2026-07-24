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
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');

            $table->date('date');
            $table->time('time_in');
            $table->time('time_out')->nullable();

            $table->string('lat_in')->nullable();
            $table->string('long_in')->nullable();
            $table->string('lat_out')->nullable();
            $table->string('long_out')->nullable();

            $table->string('photo_in')->nullable();
            $table->string('photo_out')->nullable();

            $table->enum('status', ['hadir', 'terlambat', 'izin', 'sakit', 'alpha'])->default('hadir');

            $table->boolean('is_auto_checkout')->default(false);
            $table->text('notes')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('attendances');
    }
};
