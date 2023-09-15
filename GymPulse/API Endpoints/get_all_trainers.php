<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT * FROM trainers");
$stmt->execute();
$trainers = $stmt->fetchAll();

echo json_encode($trainers);
?>
