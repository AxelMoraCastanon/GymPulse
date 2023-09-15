<?php
include 'db_connection.php';

$first_name = $_POST['first_name'];
$last_name = $_POST['last_name'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

$query = "INSERT INTO clients (first_name, last_name, email, password) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($query);
$stmt->bind_param("ssss", $first_name, $last_name, $email, $password);
$stmt->execute();

echo json_encode(["status" => "success", "message" => "User registered successfully"]);
?>
