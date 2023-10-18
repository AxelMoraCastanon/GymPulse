<?php
include 'db_connection.php';

$response = array();

if (isset($_GET['client_id'])) {
    $client_id = $_GET['client_id'];

    $stmt = $pdo->prepare("SELECT schedule_id FROM schedules WHERE client_id = ?");
    $stmt->execute([$client_id]);

} elseif (isset($_GET['trainer_id'])) {
    $trainer_id = $_GET['trainer_id'];

    $stmt = $pdo->prepare("SELECT schedule_id FROM schedules WHERE trainer_id = ?");
    $stmt->execute([$trainer_id]);
}

if ($stmt->rowCount() > 0) {
    $schedule = $stmt->fetch();
    $response['schedule_id'] = $schedule['schedule_id'];
} else {
    $response['message'] = "No schedule found for the given ID.";
}

echo json_encode($response);
?>
