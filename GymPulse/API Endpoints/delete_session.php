<?php
header('Content-Type: application/json');
require 'db_connection.php';

// Log the received JSON payload to verify the server is receiving the correct data
file_put_contents('log.txt', file_get_contents("php://input"));

$data = json_decode(file_get_contents("php://input"));

// Initialize an array to store the response messages
$response = [];

// Delete from training_sessions table
if(isset($data->session_id)) {
    $session_id = $data->session_id;
    $sql = "DELETE FROM training_sessions WHERE session_id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$session_id]);

    // Check for SQL errors after executing the query and log them
    $errorInfo = $stmt->errorInfo();
    if ($errorInfo[0] !== '00000') { // '00000' means no error
        file_put_contents('log.txt', $errorInfo[2]); // Log the error message
        $response['training_sessions'] = ["status" => "error", "message" => $errorInfo[2]];
    } else {
        $response['training_sessions'] = ["status" => "success", "message" => "Training session deleted successfully"];
    }
} else {
    $response['training_sessions'] = ["status" => "error", "message" => "No session_id provided"];
}

// Delete from schedules table
if(isset($data->schedule_id)) {
    $schedule_id = $data->schedule_id;
    $sql = "DELETE FROM schedules WHERE schedule_id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$schedule_id]);

    // Check for SQL errors after executing the query and log them
    $errorInfo = $stmt->errorInfo();
    if ($errorInfo[0] !== '00000') { // '00000' means no error
        file_put_contents('log.txt', $errorInfo[2]); // Log the error message
        $response['schedules'] = ["status" => "error", "message" => $errorInfo[2]];
    } else {
        $response['schedules'] = ["status" => "success", "message" => "Schedule deleted successfully"];
    }
} else {
    $response['schedules'] = ["status" => "error", "message" => "No schedule_id provided"];
}

// Return the response in JSON format
echo json_encode($response);
?>
