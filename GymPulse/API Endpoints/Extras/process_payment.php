<?php
include 'db_connection.php';
include 'square_config.php'; // Include Square configuration
require 'vendor/autoload.php';

use Square\SquareClient;
use Square\Exceptions\ApiException;
use Square\Models\CreatePaymentRequest;

// Get Square configurations
$config = include 'square_config.php';
$client = new SquareClient($config);

$data = json_decode(file_get_contents("php://input"));

if(isset($data->client_id) && isset($data->trainer_id) && isset($data->amount) && isset($data->nonce)){
    $money = new \Square\Models\Money();
    $money->setAmount((int)($data->amount * 100)); // Convert to cents
    $money->setCurrency('USD');

    $request = new CreatePaymentRequest($data->nonce, uniqid(), $money);

    try {
        $response = $client->getPaymentsApi()->createPayment($request);
        
        // If payment is successful, add to database
        $stmt = $pdo->prepare("INSERT INTO payments (client_id, trainer_id, amount, payment_date, payment_status, payment_method) VALUES (?, ?, ?, NOW(), ?, ?)");
        $stmt->execute([$data->client_id, $data->trainer_id, $data->amount, $response->getResult()->getPayment()->getStatus(), 'Square']);
        
        echo json_encode(["message" => "Payment successful and added to database", "payment" => $response->getResult()->getPayment()]);
    } catch (ApiException $e) {
        echo json_encode(["message" => "Payment failed", "error" => $e->getResponseBody()]);
    }
} else {
    echo json_encode(["message" => "Invalid input"]);
}
?>
