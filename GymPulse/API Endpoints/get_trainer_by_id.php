<?php
include 'db_connection.php';

$trainer_id = $_GET['trainer_id'];

$stmt = $pdo->prepare("SELECT trainer_id, first_name, last_name, email, phone_number, location_id FROM trainers WHERE trainer_id = ?");
$stmt->execute([$trainer_id]);
$trainer = $stmt->fetch();

echo json_encode($trainer);
?>
