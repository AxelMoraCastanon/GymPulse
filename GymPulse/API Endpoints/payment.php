<?php
include 'db_connection.php';
require 'vendor/autoload.php';

use Square\SquareClient;
use Square\Exceptions\ApiException;
use Square\Models\CreatePaymentRequest;

$client = new SquareClient([
    'accessToken' => 'YOUR_ACCESS_TOKEN',
    'environment' => 'sandbox' // or 'production'
]);

$data = json_decode(file_get_contents("php://input"));

if(isset($data->amount) && isset($data->nonce)){
    $money = new \Square\Models\Money();
    $money->setAmount((int)($data->amount * 100)); // Convert to cents
    $money->setCurrency('USD');

    $request = new CreatePaymentRequest($data->nonce, uniqid(), $money);

    try {
        $response = $client->getPaymentsApi()->createPayment($request);
        echo json_encode(["message" => "Payment successful", "payment" => $response->getResult()->getPayment()]);
    } catch (ApiException $e) {
        echo json_encode(["message" => "Payment failed", "error" => $e->getResponseBody()]);
    }
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
