<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->trainer_id) && isset($data->client_id) && isset($data->session_date) && isset($data->start_time) && isset($data->end_time) && isset($data->location_id)){
    $stmt = $pdo->prepare("INSERT INTO schedules (trainer_id, client_id, session_date, start_time, end_time, location_id) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data->trainer_id, $data->client_id, $data->session_date, $data->start_time, $data->end_time, $data->location_id]);
    echo json_encode(["message" => "Schedule added successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
