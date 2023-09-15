<?php
include 'db_connection.php';

$client_id = $_POST['client_id'];

$query = "DELETE FROM clients WHERE client_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("i", $client_id);
$stmt->execute();

echo json_encode(["status" => "success", "message" => "Client deleted successfully"]);
?>
