<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->email) && isset($data->password)){
    $stmt = $pdo->prepare("INSERT INTO users (email, password) VALUES (?, ?)");
    $stmt->execute([$data->email, password_hash($data->password, PASSWORD_DEFAULT)]);
    echo json_encode(["message" => "Registration successful"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
