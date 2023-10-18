<?php
include 'db_connection.php';

$response = array();

if (isset($_GET['session_id'])) {
    $session_id = $_GET['session_id'];

    $stmt = $pdo->prepare("DELETE FROM training_sessions WHERE session_id = ?");
    $result = $stmt->execute([$session_id]);

    if ($result) {
        $response['success'] = true;
        $response['message'] = "Session deleted successfully.";
    } else {
        $response['success'] = false;
        $response['message'] = "Failed to delete session.";
    }
} else {
    $response['success'] = false;
    $response['message'] = "Session ID is required.";
}

echo json_encode($response);
?>
