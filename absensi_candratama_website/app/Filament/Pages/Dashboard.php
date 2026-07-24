<?php

namespace App\Filament\Pages;

class Dashboard extends \Filament\Pages\Dashboard
{
    protected static string|\BackedEnum|null $navigationIcon = 'heroicon-o-home';
    protected static string|\BackedEnum|null $activeNavigationIcon = 'heroicon-s-home';
}