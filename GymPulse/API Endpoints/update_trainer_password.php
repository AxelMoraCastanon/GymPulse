// update_trainer_password.php
<?php
header('Content-Type: application/json');
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->trainer_id) && isset($data->password)){
    // Hash the password before storing
    $hashedPassword = password_hash($data->password, PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("UPDATE trainers SET password = ? WHERE trainer_id = ?");
    $stmt->execute([$hashedPassword, $data->trainer_id]);
    echo json_encode(["message" => "Trainer password updated successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
