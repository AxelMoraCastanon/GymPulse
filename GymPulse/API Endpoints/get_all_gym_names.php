<?php
include 'db_connection.php';

$query = "SELECT gym_name FROM locations";
$stmt = $pdo->prepare($query);
$stmt->execute();

$gyms = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
echo json_encode($gyms);
?>
