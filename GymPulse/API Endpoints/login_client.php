<?php
include 'db_connection.php';

$email = $_POST['email'];
$password = $_POST['password'];

$query = "SELECT password FROM clients WHERE email = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

if (password_verify($password, $row['password'])) {
    echo json_encode(["status" => "success", "message" => "Login successful"]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
}
?>
