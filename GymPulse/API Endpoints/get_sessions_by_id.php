<?php
include 'db_connection.php';

$response = array();

if (isset($_GET['schedule_id'])) {
    $schedule_id = $_GET['schedule_id'];

    $stmt = $pdo->prepare("SELECT * FROM training_sessions WHERE schedule_id = ?");
    $stmt->execute([$schedule_id]);

    if ($stmt->rowCount() > 0) {
        $sessions = $stmt->fetchAll();
        $response['sessions'] = $sessions;
    } else {
        $response['message'] = "No sessions found for the given schedule ID.";
    }
} else {
    $response['message'] = "Schedule ID is required.";
}

echo json_encode($response);
?>
