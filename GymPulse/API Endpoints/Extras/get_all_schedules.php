<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT * FROM schedules");
$stmt->execute();
$schedules = $stmt->fetchAll();

echo json_encode($schedules);
?>
