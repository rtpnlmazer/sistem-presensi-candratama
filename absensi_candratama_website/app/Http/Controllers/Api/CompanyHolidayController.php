<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CompanyHoliday;

class CompanyHolidayController extends Controller
{
    public function index()
    {
        $holidays = CompanyHoliday::orderBy('start_date', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $holidays
        ], 200);
    }
}