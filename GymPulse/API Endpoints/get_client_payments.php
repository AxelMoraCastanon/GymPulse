<?php
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

if(isset($data->client_id)){
    $stmt = $pdo->prepare("SELECT * FROM payments WHERE client_id = ?");
    $stmt->execute([$data->client_id]);
    $payments = $stmt->fetchAll();

    echo json_encode($payments);
} else {
    echo json_encode(["message" => "Invalid client ID"]);
}
?>
