<?php
header('Content-Type: application/json');
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->client_id) && isset($data->password)){
    // Hash the password before storing
    $hashedPassword = password_hash($data->password, PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("UPDATE clients SET password = ? WHERE client_id = ?");
    $stmt->execute([$hashedPassword, $data->client_id]);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Client password updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No changes made"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
