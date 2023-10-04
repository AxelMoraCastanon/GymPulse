<?php
include 'db_connection.php';

$client_id = $_GET['client_id'];

$stmt = $pdo->prepare("SELECT client_id, first_name, last_name, email, phone_number FROM clients WHERE client_id = ?");
$stmt->execute([$client_id]);
$client = $stmt->fetch();

echo json_encode($client);
?>
