<?php
include 'db_connection.php';

$location_id = $_GET['location_id'];

$stmt = $pdo->prepare("SELECT address FROM locations WHERE location_id = ?");
$stmt->execute([$location_id]);
$row = $stmt->fetch();

echo json_encode($row);
?>
