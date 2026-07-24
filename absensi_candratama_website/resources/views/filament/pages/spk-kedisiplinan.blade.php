<x-filament-panels::page>
    <x-filament::section>
        <x-slot name="heading">
            Peringkat Kedisiplinan Karyawan
        </x-slot>

        <x-slot name="description">
            Evaluasi tingkat kedisiplinan ini menggunakan sistem pengurangan poin (Penalti) untuk memantau kedisiplinan
            karyawan secara objektif. Setiap karyawan diberikan nilai sempurna <strong>100 Poin</strong> di awal bulan.
            Poin akan dikurangi berdasarkan rekam jejak presensi: <strong>Terlambat (-3 Poin/hari), Izin/Sakit (-1
                Poin/hari), dan Alpha/Tanpa Keterangan (-5 Poin/hari)</strong>.
        </x-slot>

        <div
            style="display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; margin-top: 1rem; margin-bottom: 1.5rem; padding-top: 1.5rem; border-top: 1px solid rgba(156, 163, 175, 0.2); gap: 1rem;">
            <div>
                <h3 style="font-size: 1.15rem; font-weight: 700; margin: 0;">Periode: {{ $this->getPeriodeTeks() }}</h3>
                <p style="font-size: 0.85rem; color: gray; margin: 0; margin-top: 4px;">Pilih periode untuk memuat
                    riwayat kedisiplinan.</p>
            </div>

            <div style="width: 100%; max-width: 320px;">
                {{ $this->form }}
            </div>
        </div>

        <div style="overflow-x: auto;">
            <table style="width: 100%; text-align: left; border-collapse: collapse; min-width: 800px;">
                <thead>
                    <tr style="border-bottom: 1px solid rgba(156, 163, 175, 0.2); text-align: center;">
                        <th style="padding: 12px 16px; font-weight: 600; opacity: 0.8; ">Peringkat</th>
                        <th style="padding: 12px 16px; font-weight: 600; opacity: 0.8;">Nama Karyawan</th>
                        <th style="padding: 12px 16px; font-weight: 600; color: #10b981;">Tepat Waktu</th>
                        <th style="padding: 12px 16px; font-weight: 600; color: #f59e0b;">Terlambat</th>
                        <th style="padding: 12px 16px; font-weight: 600; color: #0ea5e9;">Izin/Sakit</th>
                        <th style="padding: 12px 16px; font-weight: 600; color: #ef4444;">Alpha</th>
                        <th style="padding: 12px 16px; font-weight: 800; color: #3b82f6;">Total Poin</th>
                    </tr>
                </thead>
                <tbody>
                    @php
                        $dataSpk = $this->getSpkData();
                    @endphp

                    @forelse($dataSpk as $row)
                        @php $rank = $row['rank']; @endphp
                        <tr style="border-bottom: 1px solid rgba(156, 163, 175, 0.1); transition: all 0.2s;"
                            onmouseover="this.style.backgroundColor='rgba(156, 163, 175, 0.05)'"
                            onmouseout="this.style.backgroundColor='transparent'">
                            <td style="padding: 12px 16px; text-align: center;">
                                @if($rank == 1)
                                    <span
                                        style="background: rgba(234, 179, 8, 0.15); color: #eab308; padding: 4px 12px; border-radius: 999px; font-weight: 800; font-size: 0.85rem;">#1</span>
                                @elseif($rank == 2)
                                    <span
                                        style="background: rgba(156, 163, 175, 0.15); color: #9ca3af; padding: 4px 12px; border-radius: 999px; font-weight: 800; font-size: 0.85rem;">#2</span>
                                @elseif($rank == 3)
                                    <span
                                        style="background: rgba(249, 115, 22, 0.15); color: #f97316; padding: 4px 12px; border-radius: 999px; font-weight: 800; font-size: 0.85rem;">#3</span>
                                @else
                                    <span style="font-weight: 700; opacity: 0.7; padding-left: 12px;">#{{ $rank }}</span>
                                @endif
                            </td>
                            <td style="padding: 12px 16px; font-weight: 700; font-size: 1.05rem;">
                                {{ $row['nama'] }}
                            </td>
                            <td style="padding: 12px 16px; text-align: center;">{{ $row['c1'] }} Hari</td>
                            <td style="padding: 12px 16px; text-align: center;">{{ $row['c2'] }} Hari</td>
                            <td style="padding: 12px 16px; text-align: center;">{{ $row['c3'] }} Hari</td>
                            <td style="padding: 12px 16px; text-align: center;">{{ $row['c4'] }} Hari</td>
                            <td style="padding: 12px 16px; text-align: center;">
                                <span
                                    style="font-size: 1.25rem; font-weight: 900; color: #3b82f6; text-shadow: 0 1px 2px rgba(0,0,0,0.1);">
                                    {{ $row['skor'] }}
                                </span>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" style="padding: 40px; text-align: center; opacity: 0.5; font-style: italic;">
                                Belum ada data presensi karyawan untuk periode ini.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if ($dataSpk->hasPages())
            <div
                style="display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; padding-top: 1.5rem; margin-top: 1rem; border-top: 1px solid rgba(156, 163, 175, 0.2); gap: 1rem;">

                <div style="font-size: 0.875rem; color: #6b7280;">
                    Menampilkan <strong style="color: inherit;">{{ $dataSpk->firstItem() ?? 0 }}</strong> sampai <strong
                        style="color: inherit;">{{ $dataSpk->lastItem() ?? 0 }}</strong> dari <strong
                        style="color: inherit;">{{ $dataSpk->total() }}</strong> hasil
                </div>

                <div
                    style="display: inline-flex; border-radius: 0.5rem; border: 1px solid rgba(156, 163, 175, 0.3); overflow: hidden;">
                    <button wire:click="previousPage" @if($dataSpk->onFirstPage()) disabled @endif
                        style="padding: 0.5rem 0.75rem; background: {{ $dataSpk->onFirstPage() ? 'transparent' : 'rgba(156, 163, 175, 0.1)' }}; opacity: {{ $dataSpk->onFirstPage() ? '0.5' : '1' }}; cursor: {{ $dataSpk->onFirstPage() ? 'not-allowed' : 'pointer' }}; border-right: 1px solid rgba(156, 163, 175, 0.3); font-size: 0.875rem; font-weight: 600; color: inherit;">
                        &laquo; Prev
                    </button>

                    @foreach ($dataSpk->getUrlRange(max(1, $dataSpk->currentPage() - 1), min($dataSpk->lastPage(), $dataSpk->currentPage() + 1)) as $page => $url)
                        <button wire:click="gotoPage({{ $page }})"
                            style="padding: 0.5rem 1rem; font-weight: 600; font-size: 0.875rem; border-right: 1px solid rgba(156, 163, 175, 0.3); background: {{ $page == $dataSpk->currentPage() ? 'rgba(59, 130, 246, 0.1)' : 'transparent' }}; color: {{ $page == $dataSpk->currentPage() ? '#3b82f6' : 'inherit' }}; cursor: pointer;">
                            {{ $page }}
                        </button>
                    @endforeach

                    <button wire:click="nextPage" @if(!$dataSpk->hasMorePages()) disabled @endif
                        style="padding: 0.5rem 0.75rem; background: {{ !$dataSpk->hasMorePages() ? 'transparent' : 'rgba(156, 163, 175, 0.1)' }}; opacity: {{ !$dataSpk->hasMorePages() ? '0.5' : '1' }}; cursor: {{ !$dataSpk->hasMorePages() ? 'not-allowed' : 'pointer' }}; font-size: 0.875rem; font-weight: 600; color: inherit;">
                        Next &raquo;
                    </button>
                </div>
            </div>
        @endif
    </x-filament::section>
</x-filament-panels::page>