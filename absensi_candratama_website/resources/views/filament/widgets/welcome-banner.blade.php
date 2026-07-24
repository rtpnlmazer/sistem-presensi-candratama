<x-filament-widgets::widget>
    <style>
        @keyframes gradientMove {
            0% {
                background-position: 0% 50%;
            }

            50% {
                background-position: 100% 50%;
            }

            100% {
                background-position: 0% 50%;
            }
        }

        @keyframes floatIcon {
            0% {
                transform: translateY(0px);
            }

            50% {
                transform: translateY(-4px);
            }

            100% {
                transform: translateY(0px);
            }
        }
    </style>

    <x-filament::section
        style="background: linear-gradient(135deg, #1e3a8a, #3b82f6, #1E63D8); background-size: 200% 200%; animation: gradientMove 6s ease infinite; border: none; box-shadow: 0 10px 15px -3px rgba(30, 99, 216, 0.3); transition: transform 0.3s ease;"
        onmouseover="this.style.transform='scale(1.01)'" onmouseout="this.style.transform='scale(1)'">

        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h2
                    style="font-size: 1.75rem; font-weight: 800; color: white; margin: 0; line-height: 1.2; text-shadow: 0 2px 4px rgba(0,0,0,0.2);">
                    Selamat Datang, {{ auth()->user()->name ?? 'Admin' }}!
                </h2>
                <p style="color: #e0e7ff; margin-top: 0.5rem; font-size: 0.9rem; margin-bottom: 0;">
                    Berikut adalah ringkasan aktivitas presensi karyawan Anda hari ini.
                </p>
            </div>

            <div
                style="background: rgba(255, 255, 255, 0.15); backdrop-filter: blur(10px); padding: 0.6rem 1.2rem; border-radius: 0.75rem; border: 1px solid rgba(255,255,255,0.2); display: flex; align-items: center; gap: 0.5rem; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <span
                    style="font-weight: 600; color: white; font-size: 0.9rem; display: flex; align-items: center; gap: 8px;">
                    <span style="display: inline-block; animation: floatIcon 3s ease-in-out infinite;"></span>
                    {{ \Carbon\Carbon::now()->translatedFormat('d F Y') }}
                </span>
            </div>
        </div>
    </x-filament::section>
</x-filament-widgets::widget>