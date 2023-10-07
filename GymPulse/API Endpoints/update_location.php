//update_location.php
<?php
header('Content-Type: application/json');
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

// Check if location_id is set
if(isset($data->location_id)) {
    $fieldsToUpdate = [
        "gym_name" => $data->gym_name ?? null,
        "address" => $data->address ?? null
    ];

    $updateFields = [];
    $params = [];

    // Loop through fields and build the query dynamically
    foreach ($fieldsToUpdate as $field => $value) {
        if (!is_null($value)) {
            $updateFields[] = "$field = ?";
            $params[] = $value;
        }
    }

    // Check if any fields were provided for the update
    if(empty($updateFields)) {
        echo json_encode(["status" => "error", "message" => "No fields provided for update"]);
        exit;
    }

    $query = "UPDATE locations SET " . implode(", ", $updateFields) . " WHERE location_id = ?";
    $params[] = $data->location_id;

    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Location details updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No changes made"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
