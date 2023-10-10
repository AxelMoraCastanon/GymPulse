<?php
require 'db_connection.php';

$email = $_GET['email'];

$stmt = $pdo->prepare("SELECT client_id FROM clients WHERE email = :email");
$stmt->execute(['email' => $email]);
$result = $stmt->fetch();

if ($result) {
    echo json_encode(['client_id' => $result['client_id']]);
} else {
    echo json_encode(['error' => 'No client found with the provided email']);
}
?>
