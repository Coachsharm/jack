<?php
// trigger_update.php
// Triggers the dashboard update script for instant refresh
// Called by the dashboard Refresh button via fetch()

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

// Run the actual update script (correct path!)
$cmd = "sudo /usr/bin/python3 /var/www/sites/dashboard/update_status.py > /dev/null 2>&1";
exec($cmd, $output, $return_var);

if ($return_var !== 0) {
    // Fallback: try without sudo (if running as root already)
    $cmd2 = "/usr/bin/python3 /var/www/sites/dashboard/update_status.py > /dev/null 2>&1";
    exec($cmd2, $output2, $return_var2);

    if ($return_var2 !== 0) {
        echo json_encode(['status' => 'error', 'message' => 'Failed to run update script']);
    } else {
        echo json_encode(['status' => 'ok', 'message' => 'Updated (no sudo)']);
    }
} else {
    echo json_encode(['status' => 'ok', 'message' => 'Dashboard updated']);
}
?>
