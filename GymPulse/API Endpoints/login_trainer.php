<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->email) && isset($data->password)){
    $stmt = $pdo->prepare("SELECT password FROM trainers WHERE email = ?");
    $stmt->execute([$data->email]);
    $trainer = $stmt->fetch();
    
    if(password_verify($data->password, $trainer['password'])){
        echo json_encode(["message" => "Login successful"]);
    } else {
        echo json_encode(["message" => "Invalid credentials"]);
    }
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
