<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT * FROM training_sessions");
$stmt->execute();
$training_sessions = $stmt->fetchAll();

echo json_encode($training_sessions);
?>
