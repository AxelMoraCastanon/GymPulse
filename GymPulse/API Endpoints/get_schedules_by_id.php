<?php
include 'db_connection.php';

$response = array();

if (isset($_GET['client_id'])) {
    $client_id = $_GET['client_id'];

    $stmt = $pdo->prepare("SELECT * FROM schedules WHERE client_id = ?");
    $stmt->execute([$client_id]);

} elseif (isset($_GET['trainer_id'])) {
    $trainer_id = $_GET['trainer_id'];

    $stmt = $pdo->prepare("SELECT * FROM schedules WHERE trainer_id = ?");
    $stmt->execute([$trainer_id]);
}

if ($stmt->rowCount() > 0) {
    $schedules = $stmt->fetchAll();
    $response['schedules'] = $schedules;
} else {
    $response['message'] = "No schedules found for the given ID.";
}

echo json_encode($response);
?>
