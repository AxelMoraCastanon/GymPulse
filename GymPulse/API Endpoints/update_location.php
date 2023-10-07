<?php
header('Content-Type: application/json');
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->location_id) && isset($data->gym_name) && isset($data->address)){
    $stmt = $pdo->prepare("UPDATE locations SET gym_name = ?, address = ? WHERE location_id = ?");
    $stmt->execute([$data->gym_name, $data->address, $data->location_id]);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Location details updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No changes made"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
