<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->client_id) && isset($data->first_name) && isset($data->last_name) && isset($data->email) && isset($data->phone_number)){
    $stmt = $pdo->prepare("UPDATE clients SET first_name = ?, last_name = ?, email = ?, phone_number = ? WHERE client_id = ?");
    $stmt->execute([$data->first_name, $data->last_name, $data->email, $data->phone_number, $data->client_id]);
    echo json_encode(["message" => "Client details updated successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
