<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT * FROM payments");
$stmt->execute();
$payments = $stmt->fetchAll();

echo json_encode($payments);
?>
