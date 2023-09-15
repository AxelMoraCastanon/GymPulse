<?php
include 'db_connection.php';
include 'square_api.php'; // Assuming you have a separate file for Square API integration

$client_id = $_POST['client_id'];
$trainer_id = $_POST['trainer_id'];
$amount = $_POST['amount'];

// Use the Square API to make the payment
$payment_status = makePaymentWithSquare($amount); // This function should be defined in square_api.php

$query = "INSERT INTO payments (client_id, trainer_id, amount, payment_date, payment_status) VALUES (?, ?, ?, NOW(), ?)";
$stmt = $conn->prepare($query);
$stmt->bind_param("iiis", $client_id, $trainer_id, $amount, $payment_status);
$stmt->execute();

echo json_encode(["status" => "success", "message" => "Payment processed successfully"]);
?>
