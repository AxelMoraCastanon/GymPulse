<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->gym_name) && isset($data->address)){
    $stmt = $pdo->prepare("INSERT INTO locations (gym_name, address) VALUES (?, ?)");
    $stmt->execute([$data->gym_name, $data->address]);
    $location_id = $pdo->lastInsertId();
    echo json_encode(["message" => "Location added successfully", "location_id" => $location_id]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
