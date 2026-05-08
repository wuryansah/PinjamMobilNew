<?php

use App\Models\FuelRecord;

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$f = FuelRecord::first();
if ($f) {
    echo 'ID: '.$f->id."\n";
    echo 'refuel_date: '.($f->refuel_date ?? 'NULL')."\n";
    echo 'vehicle_id: '.$f->vehicle_id."\n";
    echo 'kilometer: '.$f->kilometer."\n";
} else {
    echo 'No fuel records';
}
