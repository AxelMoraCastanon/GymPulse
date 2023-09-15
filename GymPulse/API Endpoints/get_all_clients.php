<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT * FROM clients");
$stmt->execute();
$clients = $stmt->fetchAll();

echo json_encode($clients);
?>
