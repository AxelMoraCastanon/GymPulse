<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->schedule_id) && isset($data->session_date) && isset($data->start_time) && isset($data->end_time)){
    $stmt = $pdo->prepare("UPDATE schedules SET session_date = ?, start_time = ?, end_time = ? WHERE schedule_id = ?");
    $stmt->execute([$data->session_date, $data->start_time, $data->end_time, $data->schedule_id]);
    echo json_encode(["message" => "Schedule updated successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
