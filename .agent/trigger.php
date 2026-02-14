<?php
// trigger_update.php
// Triggers the dashboard update script using sudo for instant refresh

header('Content-Type: application/json');

// Command with sudo (requires NOPASSWD in sudoers)
$cmd = "sudo /usr/bin/python3 /root/.openclaw/workspace/scripts/update_dashboard_json.py --force-probe > /dev/null 2>&1 &";
exec($cmd, $output, $return_var);

// If sudo fails, create the flag file as fallback for cron pick-up
if ($return_var !== 0) {
    $flag_file = "/tmp/dashboard_probe_req";
    touch($flag_file);
    chmod($flag_file, 0666);
    echo json_encode(['status' => 'queued', 'message' => 'Probe queued via flag (sudo unavailable)']);
} else {
    echo json_encode(['status' => 'triggered', 'message' => 'Active probe executed instantly']);
}
?>
