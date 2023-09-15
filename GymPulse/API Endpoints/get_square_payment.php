<?php
include 'square_config.php';
require 'vendor/autoload.php';

use Square\SquareClient;

$config = include 'square_config.php';
$client = new SquareClient($config);

$paymentId = $_GET['payment_id'];

try {
    $response = $client->getPaymentsApi()->getPayment($paymentId);
    echo json_encode($response->getResult());
} catch (ApiException $e) {
    echo json_encode(["message" => "Failed to retrieve payment", "error" => $e->getResponseBody()]);
}
?>
