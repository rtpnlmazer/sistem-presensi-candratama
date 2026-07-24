<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;
use Filament\View\PanelsRenderHook;
use Illuminate\Support\HtmlString;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('admin')
            ->path('admin')
            ->login()
            ->profile(\App\Filament\Pages\Auth\EditProfile::class, isSimple: false)
            ->brandName('Presensi Candratama')
            ->favicon(asset('images/logo.png?v=' . time()))

            ->brandLogo(fn() => new HtmlString('
                <div x-data="{}" x-bind:class="{ \'mutlak-collapsed\': typeof $store.sidebar !== \'undefined\' && ! $store.sidebar.isOpen }" class="mutlak-logo-wrapper">
                    <img src="' . asset('images/logo.png') . '" alt="Logo" class="mutlak-logo-icon">
                    <div class="mutlak-logo-text">
                        <span class="mutlak-logo-subtitle">Presensi Online</span>
                        <span class="mutlak-logo-title">PT. Candratama Grup Nusantara</span>
                    </div>
                </div>
            '))
            ->font('Poppins')
            ->brandLogoHeight('3.5rem')
            ->databaseNotifications()
            ->databaseNotificationsPolling('30s')

            ->sidebarCollapsibleOnDesktop()
            ->collapsedSidebarWidth('5rem')
            ->maxContentWidth('full')
            ->spa()
            ->unsavedChangesAlerts()

            ->renderHook(
                PanelsRenderHook::HEAD_END,
                fn(): string => '
                <style>
                    .mutlak-logo-wrapper { 
                        display: flex; align-items: center; gap: 0.75rem; 
                        overflow: hidden; white-space: nowrap; 
                        transition: gap 300ms cubic-bezier(0.4, 0, 0.2, 1); 
                    }
                    .mutlak-logo-icon { 
                        height: 3.5rem !important; width: auto !important; flex-shrink: 0; 
                        filter: drop-shadow(0 2px 4px rgba(0,0,0,0.15)); 
                    }
                    .mutlak-logo-text { 
                        display: flex; flex-direction: column; line-height: 1.2; 
                        opacity: 1; max-width: 400px; overflow: hidden;
                        transition: max-width 300ms cubic-bezier(0.4, 0, 0.2, 1), opacity 200ms ease; 
                    }
                    .mutlak-logo-subtitle { font-size: 0.8rem; opacity: 0.8; white-space: nowrap; }
                    .mutlak-logo-title { font-size: 1.05rem; font-weight: 800; white-space: nowrap; line-height: 1.2; }

                    .mutlak-collapsed { gap: 0 !important; justify-content: center; }
                    .mutlak-collapsed .mutlak-logo-text { 
                        max-width: 0 !important; 
                        opacity: 0 !important; 
                        pointer-events: none; 
                    }

                    .fi-layout, .fi-main, .fi-topbar, .fi-sidebar, aside.fi-sidebar, header.fi-topbar { 
                        transition: all 400ms cubic-bezier(0.2, 0.8, 0.2, 1) !important; 
                        will-change: padding-inline-start, width, margin, transform;
                    }
                    .fi-main > section, .fi-main > div, .fi-card, .fi-wi-stats-overview-stat, .fi-wi-chart section, .fi-wi-chart canvas {
                        transition: all 400ms cubic-bezier(0.2, 0.8, 0.2, 1) !important;
                    }

                    .fi-sidebar-nav::-webkit-scrollbar { display: none !important; width: 0 !important; height: 0 !important; }
                    .fi-sidebar-nav { scrollbar-width: none !important; -ms-overflow-style: none !important; }
                    
                    ::-webkit-scrollbar { width: 8px !important; height: 8px !important; }
                    ::-webkit-scrollbar-track { 
                        background: #0f172a !important; /* Biru/Hitam sangat gelap */
                    }
                    ::-webkit-scrollbar-thumb { 
                        background: #1e293b !important; /* Hitam elegan */
                        border-radius: 10px !important; 
                        border: 1px solid #0f172a !important; 
                    }
                    ::-webkit-scrollbar-thumb:hover { 
                        background: #334155 !important; 
                    }

                    .fi-wi-chart > section { height: 100%; }
                    .fi-wi-chart canvas { min-height: 260px !important; }

                    :root { --loader-bg: rgba(248, 250, 252, 0.85); --loader-text: #64748b; --loader-track: #e2e8f0; --loader-fill: #3b82f6; }
                    html.dark { --loader-bg: rgba(15, 23, 42, 0.85); --loader-text: #94a3b8; --loader-track: #1e293b; --loader-fill: #3b82f6; }
                    .mutlak-loader-wrapper { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 999999; background-color: var(--loader-bg); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); display: flex; align-items: center; justify-content: center; transition: opacity 0.5s cubic-bezier(0.4, 0, 0.2, 1), visibility 0.5s; }
                    .mutlak-loader-content { display: flex; flex-direction: column; align-items: center; gap: 2.5rem; transform: translateY(20px); opacity: 0; animation: loaderFadeInUp 0.6s ease-out forwards; }
                    .mutlak-loader-logo { height: 9rem; filter: drop-shadow(0 15px 20px rgba(59, 130, 246, 0.3)); animation: mutlakFloat 3s ease-in-out infinite; }
                    .mutlak-progress-bar { width: 260px; height: 6px; background-color: var(--loader-track); border-radius: 9999px; overflow: hidden; position: relative; box-shadow: inset 0 1px 2px rgba(0,0,0,0.1); }
                    .mutlak-progress-value { position: absolute; top: 0; left: -100%; width: 50%; height: 100%; background-color: var(--loader-fill); border-radius: 9999px; animation: mutlakProgress 1.5s ease-in-out infinite; }
                    .mutlak-loader-text { font-family: "Poppins", sans-serif; font-size: 1.15rem; font-weight: 600; color: var(--loader-text); letter-spacing: 0.08em; animation: mutlakPulseText 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
                    @keyframes loaderFadeInUp { to { transform: translateY(0); opacity: 1; } }
                    @keyframes mutlakFloat { 0%, 100% { transform: translateY(0); } 50% { transform: translateY(-15px); } }
                    @keyframes mutlakProgress { 0% { left: -50%; width: 40%; } 50% { left: 30%; width: 80%; } 100% { left: 100%; width: 40%; } }
                    @keyframes mutlakPulseText { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
                </style>
                ' . (str_contains(request()->url(), '/login') ? '
                <style>
                    .fi-simple-layout { background-image: linear-gradient(rgba(15, 23, 42, 0.7), rgba(30, 58, 138, 0.8)), url("' . asset('images/furniture.jpg') . '") !important; background-size: cover !important; background-position: center !important; background-attachment: fixed !important; height: 100vh !important; overflow: hidden !important; padding: 0 !important; }
                    .fi-simple-main { max-width: 420px !important; width: 100% !important; animation: mutlakFadeInUp 1.2s cubic-bezier(0.22, 1, 0.36, 1) forwards !important; }
                    @keyframes mutlakFadeInUp { 0% { opacity: 0 !important; transform: translateY(60px) scale(0.95) !important; } 100% { opacity: 1 !important; transform: translateY(0) scale(1) !important; } }
                    .fi-simple-main .fi-card, .fi-simple-main > div > section, .fi-simple-main > section { backdrop-filter: blur(16px) saturate(180%) !important; -webkit-backdrop-filter: blur(16px) saturate(180%) !important; border-radius: 1.5rem !important; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7), 0 0 40px rgba(30, 99, 216, 0.15) !important; padding: 2.5rem 2rem !important; }
                    html:not(.dark) .fi-simple-main .fi-card, html:not(.dark) .fi-simple-main > div > section, html:not(.dark) .fi-simple-main > section { background: rgba(255, 255, 255, 0.85) !important; border: 1px solid rgba(255, 255, 255, 0.5) !important; }
                    html.dark .fi-simple-main .fi-card, html.dark .fi-simple-main > div > section, html.dark .fi-simple-main > section { background: rgba(17, 24, 39, 0.75) !important; border: 1px solid rgba(255, 255, 255, 0.12) !important; border-top: 1px solid rgba(255, 255, 255, 0.25) !important; }
                    .fi-simple-main .fi-logo { height: auto !important; max-height: none !important; }
                    
                    .fi-simple-layout .mutlak-logo-wrapper { flex-direction: column !important; align-items: center !important; text-align: center !important; gap: 0.5rem !important; justify-content: center !important; }
                    .fi-simple-layout .mutlak-logo-icon { height: 6rem !important; margin-bottom: 0.5rem !important; filter: drop-shadow(0 4px 6px rgba(0,0,0,0.5)) !important; }
                    .fi-simple-layout .mutlak-logo-text { display: flex !important; flex-direction: column !important; opacity: 1 !important; max-width: none !important; width: auto !important; }
                    html:not(.dark) .fi-simple-layout .mutlak-logo-text { color: #111827 !important; }
                    html.dark .fi-simple-layout .mutlak-logo-text { color: #ffffff !important; }
                    .fi-simple-layout .mutlak-logo-subtitle { font-size: 1rem !important; font-weight: 500 !important; opacity: 0.9; letter-spacing: 0.5px; white-space: normal !important; }
                    .fi-simple-layout .mutlak-logo-title { font-size: 1.25rem !important; font-weight: 800 !important; line-height: 1.2; white-space: normal !important; }
                </style>
                <script>sessionStorage.removeItem("loader_telah_muncul");</script>
                ' : '')
            )

            ->renderHook(
                PanelsRenderHook::BODY_START,
                fn(): string => str_contains(request()->url(), '/login') ? '' : '
                <div id="mutlak-global-loader" class="mutlak-loader-wrapper" style="display: none;">
                    <div class="mutlak-loader-content">
                        <img src="' . asset('images/logo.png') . '" alt="Logo Loading" class="mutlak-loader-logo">
                        <div class="mutlak-progress-bar"><div class="mutlak-progress-value"></div></div>
                        <span class="mutlak-loader-text">Memuat halaman...</span>
                    </div>
                </div>
                <script>
                    (function() {
                        var loader = document.getElementById("mutlak-global-loader");
                        if (loader) {
                            var dariLogin = document.referrer.includes("/login");
                            var sudahMuncul = sessionStorage.getItem("loader_telah_muncul");
                            if (dariLogin && !sudahMuncul) {
                                loader.style.display = "flex";
                                sessionStorage.setItem("loader_telah_muncul", "true");
                                setTimeout(function() {
                                    loader.style.opacity = "0"; loader.style.visibility = "hidden";
                                    setTimeout(function() { if (loader.parentNode) loader.remove(); }, 500);
                                }, 1200);
                            } else {
                                loader.remove();
                            }
                        }
                    })();
                </script>
                '
            )

            ->renderHook(
                PanelsRenderHook::BODY_END,
                fn(): string => (auth()->check() ? \Illuminate\Support\Facades\Blade::render("@livewire('notification-poller')") : "") . '
                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                <script>
                    function getSwalTheme() {
                        const isDark = document.documentElement.classList.contains("dark");
                        return { background: isDark ? "#1e293b" : "#ffffff", color: isDark ? "#ffffff" : "#111827", backdrop: isDark ? "rgba(15, 23, 42, 0.85)" : "rgba(255, 255, 255, 0.65)" };
                    }
                    document.addEventListener("DOMContentLoaded", () => {
                        const observer = new MutationObserver(() => {
                            let errorNodes = document.querySelectorAll("p, span, .text-danger-600");
                            errorNodes.forEach(node => {
                                let text = node.textContent || node.innerText;
                                if (text && text.includes("PEGAWAI_ERROR_CODE")) {
                                    node.innerHTML = ""; node.style.display = "none";
                                    if (!Swal.isVisible()) Swal.fire({ icon: "error", title: "Akses Ditolak!", text: "Akun Karyawan dilarang masuk ke halaman Web Admin.", confirmButtonText: "Mengerti", confirmButtonColor: "#3b82f6", background: getSwalTheme().background, color: getSwalTheme().color, backdrop: getSwalTheme().backdrop, allowOutsideClick: false });
                                } else if (text && text.includes("Kredensial yang diberikan tidak dapat ditemukan")) {
                                    node.innerHTML = ""; node.style.display = "none";
                                    if (!Swal.isVisible()) Swal.fire({ icon: "warning", title: "Login Gagal!", text: "Alamat Email atau Kata Sandi yang Anda masukkan salah.", confirmButtonText: "Coba Lagi", confirmButtonColor: "#ef4444", background: getSwalTheme().background, color: getSwalTheme().color, backdrop: getSwalTheme().backdrop, allowOutsideClick: false });
                                }
                            });
                        });
                        observer.observe(document.body, { childList: true, subtree: true, characterData: true });

                        window.addEventListener("click", function(e) {
                            let form = e.target.closest("form");
                            if (form && form.action && form.action.includes("logout")) {
                                e.preventDefault(); e.stopPropagation(); 
                                Swal.fire({ title: "Konfirmasi Keluar", text: "Apakah Anda yakin ingin keluar dari aplikasi Presensi Candratama?", icon: "question", showCancelButton: true, confirmButtonColor: "#ef4444", cancelButtonColor: "#64748b", confirmButtonText: "Ya, Keluar", cancelButtonText: "Batal", background: getSwalTheme().background, color: getSwalTheme().color, backdrop: getSwalTheme().backdrop }).then((result) => { if (result.isConfirmed) form.submit(); });
                            }
                        }, true); 
                    });
                </script>
                ' . (str_contains(request()->url(), '/login') ? '
                <script>
                    document.addEventListener("alpine:init", () => {
                        Alpine.nextTick(() => {
                            const loginCard = document.querySelector(".fi-simple-main");
                            if(loginCard) {
                                loginCard.style.opacity = "0"; loginCard.style.transform = "translateY(40px)"; loginCard.style.transition = "all 1s cubic-bezier(0.2, 0.8, 0.2, 1)";
                                requestAnimationFrame(() => { setTimeout(() => { loginCard.style.opacity = "1"; loginCard.style.transform = "translateY(0)"; }, 50); });
                            }
                        });
                    });
                </script>
                ' : '')
            )

            ->colors([
                'primary' => Color::hex('#1E63D8'),
                'gray' => Color::Slate,
                'danger' => Color::Rose,
                'info' => Color::Blue,
                'success' => Color::Emerald,
                'warning' => Color::Orange,
            ])

            ->discoverResources(in: app_path('Filament/Resources'), for: 'App\Filament\Resources')
            ->discoverPages(in: app_path('Filament/Pages'), for: 'App\Filament\Pages')
            ->pages([
                \App\Filament\Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Widgets'), for: 'App\\Filament\\Widgets')
            ->widgets([
                \App\Filament\Widgets\WelcomeBanner::class,
                \App\Filament\Widgets\AttendanceOverview::class,
                \App\Filament\Widgets\AttendanceChart::class,
                \App\Filament\Widgets\StatusKehadiranChart::class,
                \App\Filament\Widgets\BelumAbsenTable::class,
            ])
            ->middleware([EncryptCookies::class, AddQueuedCookiesToResponse::class, StartSession::class, AuthenticateSession::class, ShareErrorsFromSession::class, VerifyCsrfToken::class, SubstituteBindings::class, DisableBladeIconComponents::class, DispatchServingFilamentEvent::class])
            ->authMiddleware([Authenticate::class]);
    }
}