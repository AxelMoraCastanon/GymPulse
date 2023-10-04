<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->first_name) && isset($data->last_name) && isset($data->email) && isset($data->phone_number) && isset($data->location_id) && isset($data->password)){
    $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);
    $stmt = $pdo->prepare("INSERT INTO trainers (first_name, last_name, email, phone_number, location_id, password) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data->first_name, $data->last_name, $data->email, $data->phone_number, $data->location_id, $hashed_password]);
    echo json_encode(["message" => "Trainer added successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
