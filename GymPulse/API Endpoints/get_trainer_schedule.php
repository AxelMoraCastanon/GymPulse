<?php
include 'db_connection.php';

$trainer_id = $_GET['trainer_id'];

$query = "SELECT * FROM schedules WHERE trainer_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $trainer_id);
$stmt->execute();
$result = $stmt->get_result();

$schedules = [];
while ($row = $result->fetch_assoc()) {
    $schedules[] = $row;
}

echo json_encode($schedules);
?>
