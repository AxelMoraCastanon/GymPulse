<?php
include 'square_config.php';
require 'vendor/autoload.php';

use Square\SquareClient;

$config = include 'square_config.php';
$client = new SquareClient($config);

$paymentId = $_POST['payment_id'];

try {
    $response = $client->getPaymentsApi()->cancelPayment($paymentId);
    echo json_encode($response->getResult());
} catch (ApiException $e) {
    echo json_encode(["message" => "Failed to cancel payment", "error" => $e->getResponseBody()]);
}
?>
