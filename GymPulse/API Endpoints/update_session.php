<?php
header('Content-Type: application/json');
require 'db_connection.php';

// Log the received JSON payload to verify the server is receiving the correct data
file_put_contents('log.txt', file_get_contents("php://input"));

$data = json_decode(file_get_contents("php://input"));

// Check and update schedules
if(isset($data->schedule_id)) {
    $fields = [];
    $values = [];

    if(isset($data->session_date)) {
        $fields[] = "session_date = ?";
        $values[] = $data->session_date;
    }
    if(isset($data->start_time)) {
        $fields[] = "start_time = ?";
        $values[] = $data->start_time;
    }
    if(isset($data->end_time)) {
        $fields[] = "end_time = ?";
        $values[] = $data->end_time;
    }

    if(!empty($fields)) {
        $values[] = $data->schedule_id;
        $sql = "UPDATE schedules SET " . implode(", ", $fields) . " WHERE schedule_id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);

        // Check for SQL errors after executing the query and log them
        $errorInfo = $stmt->errorInfo();
        if ($errorInfo[0] !== '00000') { // '00000' means no error
            file_put_contents('log.txt', $errorInfo[2]); // Log the error message
            echo json_encode(["status" => "error", "message" => $errorInfo[2]]);
            exit;
        }
    }
}

// Check and update training_sessions
if(isset($data->session_id)) {
    $fields = [];
    $values = [];

    if(isset($data->workout_type)) {
        $fields[] = "workout_type = ?";
        $values[] = $data->workout_type;
    }
    if(isset($data->duration_minutes)) {
        $fields[] = "duration_minutes = ?";
        $values[] = $data->duration_minutes;
    }

    if(!empty($fields)) {
        $values[] = $data->session_id;
        $sql = "UPDATE training_sessions SET " . implode(", ", $fields) . " WHERE session_id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($values);

        // Check for SQL errors after executing the query and log them
        $errorInfo = $stmt->errorInfo();
        if ($errorInfo[0] !== '00000') { // '00000' means no error
            file_put_contents('log.txt', $errorInfo[2]); // Log the error message
            echo json_encode(["status" => "error", "message" => $errorInfo[2]]);
            exit;
        } else {
            echo json_encode(["status" => "success", "message" => "Both schedules and training sessions updated successfully!"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "No valid fields provided for training sessions"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No session_id provided"]);
}
?>
