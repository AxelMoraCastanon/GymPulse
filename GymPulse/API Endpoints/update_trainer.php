<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->trainer_id) && isset($data->first_name) && isset($data->last_name) && isset($data->email) && isset($data->phone_number) && isset($data->location_id)){
    $stmt = $pdo->prepare("UPDATE trainers SET first_name = ?, last_name = ?, email = ?, phone_number = ?, location_id = ? WHERE trainer_id = ?");
    $stmt->execute([$data->first_name, $data->last_name, $data->email, $data->phone_number, $data->location_id, $data->trainer_id]);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Trainer details updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No changes made"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
