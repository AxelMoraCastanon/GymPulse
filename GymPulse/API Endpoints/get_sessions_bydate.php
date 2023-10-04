<?php
include 'db_connection.php';

$date = $_GET['date'];

$stmt = $pdo->prepare("SELECT * FROM schedules WHERE session_date = ?");
$stmt->execute([$date]);
$sessions = $stmt->fetchAll();

echo json_encode($sessions);
?>
