<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->schedule_id) && isset($data->workout_type) && isset($data->duration_minutes)){
    $stmt = $pdo->prepare("INSERT INTO training_sessions (schedule_id, workout_type, duration_minutes) VALUES (?, ?, ?)");
    $stmt->execute([$data->schedule_id, $data->workout_type, $data->duration_minutes]);
    echo json_encode(["message" => "Training session added successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
