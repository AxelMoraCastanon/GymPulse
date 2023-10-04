<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->first_name) && isset($data->last_name) && isset($data->email) && isset($data->password)){
    $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO clients (first_name, last_name, email, password) VALUES (?, ?, ?, ?)");
    $stmt->execute([$data->first_name, $data->last_name, $data->email, $hashed_password]);
    echo json_encode(["message" => "Registration successful"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
