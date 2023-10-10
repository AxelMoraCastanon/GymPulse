<?php
include 'db_connection.php';

$trainer_id = $_GET['trainer_id'];

$stmt = $pdo->prepare("SELECT s.*, c.first_name as client_first_name, c.last_name as client_last_name 
          FROM schedules s 
          JOIN clients c ON s.client_id = c.client_id 
          WHERE s.trainer_id = ?");
$stmt->execute([$trainer_id]);
$sessions = $stmt->fetchAll();

echo json_encode($sessions);
?>
