// update_client_password.php
<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->client_id) && isset($data->password)){
    // Hash the password before storing
    $hashedPassword = password_hash($data->password, PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("UPDATE clients SET password = ? WHERE client_id = ?");
    $stmt->execute([$hashedPassword, $data->client_id]);
    echo json_encode(["message" => "Client password updated successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
