<?php

use App\Models\FuelRecord;

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$records = FuelRecord::where('vehicle_id', 14)->orderBy('refuel_date')->get();

echo "Fuel Records for Machmud (B 6263 UTJ):\n";
echo str_repeat('-', 90)."\n";

foreach ($records as $r) {
    echo sprintf(
        '%-12s | end_km: %8.2f | start_km: %s | fuel: %6.2fL | dist: %s | km/L: %s',
        $r->refuel_date->format('Y-m-d'),
        $r->kilometer,
        $r->start_km ?? '-',
        $r->fuel_amount,
        $r->distance_traveled ?? '-',
        $r->fuel_consumption ?? '-'
    ).PHP_EOL;
}
