<?php
include 'square_config.php';
require 'vendor/autoload.php';

use Square\SquareClient;

$config = include 'square_config.php';
$client = new SquareClient($config);

try {
    $response = $client->getPaymentsApi()->listPayments();
    echo json_encode($response->getResult());
} catch (ApiException $e) {
    echo json_encode(["message" => "Failed to list payments", "error" => $e->getResponseBody()]);
}
?>
