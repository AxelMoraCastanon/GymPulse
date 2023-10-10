<?php
include 'db_connection.php';

$location_id = $_GET['location_id'];

$query = "SELECT * FROM trainers WHERE location_id = ?";
$stmt = $pdo->prepare($query);
$stmt->execute([$location_id]);

$trainers = $stmt->fetchAll();
echo json_encode($trainers);
?>
