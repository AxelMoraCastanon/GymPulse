<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

// Check if email and password are set
if(isset($data->email) && isset($data->password)){
    $stmt = $pdo->prepare("SELECT client_id, first_name, last_name, password FROM clients WHERE email = ?");
    $stmt->execute([$data->email]);
    $user = $stmt->fetch();

    // Check if user exists and password is correct
    if($user && password_verify($data->password, $user['password'])){
        // Unset password before sending user data
        unset($user['password']);
        echo json_encode(['status' => 'success', 'user' => $user]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Invalid credentials']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
}
?>
