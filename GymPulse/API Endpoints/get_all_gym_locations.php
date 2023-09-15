<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT * FROM locations");
$stmt->execute();
$locations = $stmt->fetchAll();

echo json_encode($locations);
?>
