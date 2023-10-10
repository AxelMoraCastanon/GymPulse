<?php
require 'db_connection.php';

$email = $_GET['email'];

$stmt = $pdo->prepare("SELECT trainer_id FROM trainers WHERE email = :email");
$stmt->execute(['email' => $email]);
$result = $stmt->fetch();

if ($result) {
    echo json_encode(['trainer_id' => $result['trainer_id']]);
} else {
    echo json_encode(['error' => 'No trainer found with the provided email']);
}
?>
