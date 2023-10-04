<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT trainer_id, first_name, last_name, email, phone_number, location_id FROM trainers");
$stmt->execute();
$trainers = $stmt->fetchAll();

echo json_encode($trainers);
?>
