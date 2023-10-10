<?php
include 'db_connection.php';

$gym_name = $_GET['gym_name'];

$query = "SELECT * FROM locations WHERE gym_name = ?";
$stmt = $pdo->prepare($query);
$stmt->execute([$gym_name]);

$gym_info = $stmt->fetch();
echo json_encode($gym_info);
?>
