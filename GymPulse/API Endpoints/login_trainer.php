<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

// Check if email and password are set
if(isset($data->email) && isset($data->password)){
    $stmt = $pdo->prepare("SELECT trainer_id, first_name, last_name, password FROM trainers WHERE email = ?");
    $stmt->execute([$data->email]);
    $trainer = $stmt->fetch();

    // Check if trainer exists and password is correct
    if($trainer && password_verify($data->password, $trainer['password'])){
        // Unset password before sending trainer data
        unset($trainer['password']);
        echo json_encode(['status' => 'success', 'trainer' => $trainer]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid credentials']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}
?>
