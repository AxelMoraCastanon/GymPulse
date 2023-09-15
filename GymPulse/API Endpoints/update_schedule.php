<?php
include 'db_connection.php';

$schedule_id = $_POST['schedule_id'];
$session_date = $_POST['session_date'];
$start_time = $_POST['start_time'];
$end_time = $_POST['end_time'];

$query = "UPDATE schedules SET session_date = ?, start_time = ?, end_time = ? WHERE schedule_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("sssi", $session_date, $start_time, $end_time, $schedule_id);
$stmt->execute();

echo json_encode(["status" => "success", "message" => "Schedule updated successfully"]);
?>
