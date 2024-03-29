<?php
header('Content-Type: application/json');
require 'db_connection.php';

// Log the received JSON payload to verify the server is receiving the correct data
file_put_contents('log.txt', file_get_contents("php://input"));

$data = json_decode(file_get_contents("php://input"));

// Check if required fields are set
if(isset($data->trainer_id) && isset($data->client_id) && isset($data->session_date) && isset($data->start_time) && isset($data->end_time)) {
    
    // If location_id is not set, fetch it using the trainer_id
    if(!isset($data->location_id)) {
        $stmt = $pdo->prepare("SELECT location_id FROM trainers WHERE trainer_id = :trainer_id");
        $stmt->execute(['trainer_id' => $data->trainer_id]);
        $result = $stmt->fetch();

        if($result) {
            $data->location_id = $result['location_id'];
        } else {
            echo json_encode(["status" => "error", "message" => "Trainer not found or location_id not set for trainer"]);
            exit;
        }
    }
    
    // Prepare the INSERT statement
    $stmt = $pdo->prepare("INSERT INTO schedules (trainer_id, client_id, session_date, start_time, end_time, location_id) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data->trainer_id, $data->client_id, $data->session_date, $data->start_time, $data->end_time, $data->location_id]);
    
    // Check for SQL errors after executing the query and log them
    $errorInfo = $stmt->errorInfo();
    if ($errorInfo[0] !== '00000') { // '00000' means no error
        file_put_contents('log.txt', $errorInfo[2]); // Log the error message
        echo json_encode(["status" => "error", "message" => $errorInfo[2]]);
    } else {
        echo json_encode(["status" => "success", "schedule_id" => $pdo->lastInsertId()]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
