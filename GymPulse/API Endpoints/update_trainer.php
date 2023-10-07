//update_trainer.php
<?php
header('Content-Type: application/json');
include 'db_connection.php';

$data = json_decode(file_get_contents("php://input"));

// Check if trainer_id is set
if(isset($data->trainer_id)) {
    $fieldsToUpdate = [
        "first_name" => $data->first_name ?? null,
        "last_name" => $data->last_name ?? null,
        "email" => $data->email ?? null,
        "phone_number" => $data->phone_number ?? null,
        "location_id" => $data->location_id ?? null
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

    $query = "UPDATE trainers SET " . implode(", ", $updateFields) . " WHERE trainer_id = ?";
    $params[] = $data->trainer_id;

    $stmt = $pdo->prepare($query);
    $stmt->execute($params);
    
    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Trainer details updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "No changes made"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid input"]);
}
?>
