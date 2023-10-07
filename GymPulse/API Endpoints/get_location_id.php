// get_location_id.php
<?php
require 'db_connection.php';

$trainer_id = isset($_GET['trainer_id']) ? $_GET['trainer_id'] : null;
$location_id = isset($_GET['location_id']) ? $_GET['location_id'] : null;

if ($trainer_id) {
    $stmt = $pdo->prepare("SELECT location_id FROM trainers WHERE trainer_id = :trainer_id");
    $stmt->execute(['trainer_id' => $trainer_id]);
} elseif ($location_id) {
    $stmt = $pdo->prepare("SELECT location_id FROM locations WHERE location_id = :location_id");
    $stmt->execute(['location_id' => $location_id]);
} else {
    echo json_encode(['error' => 'Please provide either trainer_id or location_id']);
    exit;
}

$result = $stmt->fetch();

if ($result) {
    echo json_encode(['location_id' => $result['location_id']]);
} else {
    echo json_encode(['error' => 'No location found with the provided criteria']);
}
?>
