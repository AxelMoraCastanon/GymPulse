<?php
include 'db_connection.php';

$trainer_id = $_GET['trainer_id'];

$stmt = $pdo->prepare("SELECT * FROM payments WHERE trainer_id = ?");
$stmt->execute([$trainer_id]);
$payments = $stmt->fetchAll();

echo json_encode($payments);
?>
