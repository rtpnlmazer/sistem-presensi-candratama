<div x-data="{ open: false }" style="display: flex; justify-content: center;">
    @if ($getState())
        <img src="{{ asset('storage/' . $getState()) }}" @click.stop="open = true"
            style="width: 40px; height: 40px; object-fit: cover; border-radius: 6px; cursor: pointer; transition: transform 0.2s;"
            onmouseover="this.style.transform='scale(1.15)'" onmouseout="this.style.transform='scale(1)'"
            title="Klik untuk melihat bukti lampiran">

        <template x-teleport="body">
            <div x-show="open"
                style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 999999; background-color: rgba(0,0,0,0.85); display: flex; align-items: center; justify-content: center; padding: 20px;"
                @click="open = false" x-transition.opacity>

                <div style="position: relative;" @click.stop>
                    <button @click="open = false"
                        style="position: absolute; top: -15px; right: -15px; background-color: #ef4444; color: white; border-radius: 50%; width: 32px; height: 32px; font-weight: bold; border: 2px solid white; cursor: pointer; box-shadow: 0 4px 6px rgba(0,0,0,0.3);">
                        X
                    </button>

                    <img src="{{ asset('storage/' . $getState()) }}"
                        style="max-width: 100%; max-height: 90vh; border-radius: 8px; box-shadow: 0 10px 25px rgba(0,0,0,0.5);">
                </div>
            </div>
        </template>
    @else
        <span style="color: gray;">-</span>
    @endif
</div>