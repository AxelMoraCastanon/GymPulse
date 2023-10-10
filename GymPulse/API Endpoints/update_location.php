<?php
header('Content-Type: application/json');
include 'db_connection.php';

// Log the received JSON payload to verify the server is receiving the correct data
file_put_contents('log.txt', file_get_contents("php://input"));

$data = json_decode(file_get_contents("php://input"));

// Check if location_id is set
if(isset($data->location_id)) {
    $fieldsToUpdate = [
        "gym_name" => $data->gym_name ?? null,
        "address" => $data->address ?? null
    ];

    $updateFields = [];
    $params = [];

    foreach ($fieldsToUpdate as $field => $value) {
        if (!is_null($value)) {
            $updateFields[] = "$field = ?";
            $params[] = $value;
        }
    }

    if(empty($updateFields)) {
        echo json_encode(["status" => "error", "message" => "No fields provided for update"]);
        exit;
    }

    $query = "UPDATE locations SET " . implode(", ", $updateFields) . " WHERE location_id = ?";
    $params[] = $data->location_id;

    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    
    // Check for SQL errors after executing the query and log them
    if ($stmt->error) {
        file_put_contents('log.txt', $stmt->error);
    }

    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Location details updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No changes made"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
