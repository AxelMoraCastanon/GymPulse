<?php
include 'db_connection.php';

$location_id = $_GET['location_id'];

$query = "SELECT address FROM locations WHERE location_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $location_id);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

echo json_encode($row);
?>
