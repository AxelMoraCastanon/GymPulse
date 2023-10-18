<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

$response = array();

if (isset($data->schedule_id) && isset($data->workout_type) && isset($data->duration_minutes)) {
    $stmt = $pdo->prepare("INSERT INTO training_sessions (schedule_id, workout_type, duration_minutes) VALUES (?, ?, ?)");
    $result = $stmt->execute([$data->schedule_id, $data->workout_type, $data->duration_minutes]);

    if ($result) {
        $response['success'] = true;
        $response['message'] = "Session added successfully.";
    } else {
        $response['success'] = false;
        $response['message'] = "Failed to add session.";
    }
} else {
    $response['success'] = false;
    $response['message'] = "Required fields are missing.";
}

echo json_encode($response);
?>
