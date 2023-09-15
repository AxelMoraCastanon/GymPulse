<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->first_name) && isset($data->last_name) && isset($data->email) && isset($data->phone_number)){
    $stmt = $pdo->prepare("INSERT INTO clients (first_name, last_name, email, phone_number) VALUES (?, ?, ?, ?)");
    $stmt->execute([$data->first_name, $data->last_name, $data->email, $data->phone_number]);
    echo json_encode(["message" => "Client added successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
