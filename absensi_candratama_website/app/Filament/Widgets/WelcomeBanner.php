<?php

namespace App\Filament\Widgets;

use Filament\Widgets\Widget;

class WelcomeBanner extends Widget
{
    protected string $view = 'filament.widgets.welcome-banner';

    protected static ?int $sort = 1;

    protected static bool $isLazy = false;

    protected int|string|array $columnSpan = 'full';
}