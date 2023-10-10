<?php
include 'db_connection.php';

$trainer_id = $_GET['trainer_id'];

$stmt = $pdo->prepare("SELECT DISTINCT c.client_id, c.first_name, c.last_name, c.email, c.phone_number 
                       FROM clients c 
                       JOIN schedules s ON c.client_id = s.client_id 
                       WHERE s.trainer_id = ?");
$stmt->execute([$trainer_id]);
$clients = $stmt->fetchAll();

echo json_encode($clients);
?>
