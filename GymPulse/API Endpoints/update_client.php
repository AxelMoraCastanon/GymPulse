<?php
include 'db_connection.php';

$client_id = $_POST['client_id'];
$first_name = $_POST['first_name'];
$last_name = $_POST['last_name'];
$email = $_POST['email'];
$phone_number = $_POST['phone_number'];

$query = "UPDATE clients SET first_name = ?, last_name = ?, email = ?, phone_number = ? WHERE client_id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssssi", $first_name, $last_name, $email, $phone_number, $client_id);
$stmt->execute();

echo json_encode(["status" => "success", "message" => "Client details updated successfully"]);
?>
