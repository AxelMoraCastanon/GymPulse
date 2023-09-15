<?php
include 'db_connection.php';

$trainer_id = $_GET['trainer_id'];

$query = "SELECT s.*, c.first_name as client_first_name, c.last_name as client_last_name 
          FROM schedules s 
          JOIN clients c ON s.client_id = c.client_id 
          WHERE s.trainer_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $trainer_id);
$stmt->execute();
$result = $stmt->get_result();

$sessions = [];
while ($row = $result->fetch_assoc()) {
    $sessions[] = $row;
}

echo json_encode($sessions);
?>
