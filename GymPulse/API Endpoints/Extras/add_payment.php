<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->client_id) && isset($data->trainer_id) && isset($data->amount) && isset($data->payment_date) && isset($data->payment_status) && isset($data->payment_method)){
    $stmt = $pdo->prepare("INSERT INTO payments (client_id, trainer_id, amount, payment_date, payment_status, payment_method) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->execute([$data->client_id, $data->trainer_id, $data->amount, $data->payment_date, $data->payment_status, $data->payment_method]);
    echo json_encode(["message" => "Payment added successfully"]);
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
