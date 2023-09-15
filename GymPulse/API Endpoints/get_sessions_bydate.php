<?php
include 'db_connection.php';

$date = $_GET['date'];

$query = "SELECT * FROM schedules WHERE session_date = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $date);
$stmt->execute();
$result = $stmt->get_result();

$sessions = [];
while ($row = $result->fetch_assoc()) {
    $sessions[] = $row;
}

echo json_encode($sessions);
?>
