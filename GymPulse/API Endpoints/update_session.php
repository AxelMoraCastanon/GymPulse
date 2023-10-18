<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

$response = array();

if (isset($data->session_id) && isset($data->schedule_id) && isset($data->workout_type) && isset($data->duration_minutes)) {
    $stmt = $pdo->prepare("UPDATE training_sessions SET schedule_id = ?, workout_type = ?, duration_minutes = ? WHERE session_id = ?");
    $result = $stmt->execute([$data->schedule_id, $data->workout_type, $data->duration_minutes, $data->session_id]);

    if ($result) {
        $response['success'] = true;
        $response['message'] = "Session updated successfully.";
    } else {
        $response['success'] = false;
        $response['message'] = "Failed to update session.";
    }
} else {
    $response['success'] = false;
    $response['message'] = "Required fields are missing.";
}

echo json_encode($response);
?>
