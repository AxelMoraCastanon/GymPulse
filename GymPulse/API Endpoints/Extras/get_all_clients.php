<?php
include 'db_connection.php';

$stmt = $pdo->prepare("SELECT client_id, first_name, last_name, email, phone_number FROM clients");
$stmt->execute();
$clients = $stmt->fetchAll();

echo json_encode($clients);
?>
