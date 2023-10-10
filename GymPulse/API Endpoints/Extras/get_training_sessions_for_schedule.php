<?php
include 'db_connection.php';

$schedule_id = $_GET['schedule_id'];

$stmt = $pdo->prepare("SELECT * FROM training_sessions WHERE schedule_id = ?");
$stmt->execute([$schedule_id]);
$training_sessions = $stmt->fetchAll();

echo json_encode($training_sessions);
?>
