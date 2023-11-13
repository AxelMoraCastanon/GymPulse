<?php

require_once 'vendor/autoload.php';
require_once 'secrets.php';

error_log("Stripe PHP library loaded.");
$stripe = new \Stripe\StripeClient($stripeSecretKey);

function calculateOrderAmount(array $items): int {
    error_log("Calculating order amount.");
    // Calculation logic
    return 1400;
}

header('Content-Type: application/json');

try {
    error_log("Attempting to retrieve JSON from POST body.");
    $jsonStr = file_get_contents('php://input');
    error_log("Received data: " . $jsonStr);

    $jsonObj = json_decode($jsonStr);
    error_log("Decoded JSON object.");

    error_log("Creating PaymentIntent.");
    $paymentIntent = $stripe->paymentIntents->create([
        'amount' => calculateOrderAmount($jsonObj->items),
        'currency' => 'usd',
        'automatic_payment_methods' => ['enabled' => true],
    ]);

    error_log("PaymentIntent created: " . $paymentIntent->client_secret);
    $output = ['clientSecret' => $paymentIntent->client_secret];
    echo json_encode($output);
} catch (Error $e) {
    http_response_code(500);
    error_log("Error: " . $e->getMessage());
    echo json_encode(['error' => $e->getMessage()]);
}
?>
