// update_location.php
<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->location_id) && isset($data->gym_name) && isset($data->address)){
    $stmt = $pdo->prepare("UPDATE locations SET gym_name = ?, address = ? WHERE location_id = ?");
    $stmt->execute([$data->gym_name, $data->address, $data->location_id]);
    echo json_encode(["message" => "Location details updated successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
