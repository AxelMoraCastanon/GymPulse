<?php
include 'db_connection.php';

$client_id = $_GET['client_id'];

$stmt = $pdo->prepare("SELECT * FROM schedules WHERE client_id = ?");
$stmt->execute([$client_id]);
$sessions = $stmt->fetchAll();

echo json_encode($sessions);
?>
