<?php
header('Content-Type: application/json');
include 'db_connection.php';

// Log the received JSON payload to verify the server is receiving the correct data
file_put_contents('log.txt', file_get_contents("php://input"));

$data = json_decode(file_get_contents("php://input"));

// Data validation
if (!isset($data->workout_type) || !isset($data->duration_minutes) || !is_numeric($data->duration_minutes) || !isset($data->schedule_id)) {
    echo json_encode(["status" => "error", "message" => "Invalid data provided."]);
    exit;
}

$schedule_id = $data->schedule_id;
$workout_type = $data->workout_type;
$duration_minutes = $data->duration_minutes;

// Using prepared statements to prevent SQL injection
$stmt = $pdo->prepare("INSERT INTO training_sessions (schedule_id, workout_type, duration_minutes) VALUES (?, ?, ?)");
$stmt->execute([$schedule_id, $workout_type, $duration_minutes]);

// Check for SQL errors after executing the query and log them
if ($stmt->error) {
    file_put_contents('log.txt', $stmt->error);
    echo json_encode(["status" => "error", "message" => $stmt->error]);
} else {
    echo json_encode(["status" => "success", "message" => "Training session added successfully!"]);
}
?>
