import Foundation
import UIKit
import StripePaymentSheet

class CheckoutViewController: UIViewController {

    private static let backendURL = URL(string: "http://ec2-54-219-186-173.us-west-1.compute.amazonaws.com/create.php")! // Adjust the URL as needed

    private var paymentIntentClientSecret: String?

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Pay now", for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 5
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        StripeAPI.defaultPublishableKey = "pk_test_51OBkFgHHUyq7ejf5KZgYKGJbbLoWduCLE8IJoubCtzYsSWJL8EbDOtf0l29syKToGjpS2bogtDkJnWJsoWymtzI30008OVRlKn"

        view.backgroundColor = .systemBackground
        view.addSubview(payButton)

        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        print("View loaded, fetching payment intent.")
        self.fetchPaymentIntent()
    }

    func fetchPaymentIntent() {
        print("Fetching Payment Intent")
        let url = Self.backendURL.appendingPathComponent("create-payment-intent")
        print("URL for Payment Intent: \(url)")

        let shoppingCartContent: [String: Any] = ["items": [["id": "xl-shirt"]]]
        print("Shopping Cart Content: \(shoppingCartContent)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: shoppingCartContent)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                self?.displayAlert(title: "Error", message: error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("No data received from the server")
                self?.displayAlert(title: "Error", message: "No data received from the server")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON Response: \(json)")
                    if let clientSecret = json["clientSecret"] as? String {
                        print("Received clientSecret: \(clientSecret)")
                        self?.paymentIntentClientSecret = clientSecret
                        DispatchQueue.main.async {
                            self?.payButton.isEnabled = true
                        }
                    } else {
                        print("clientSecret not found in JSON")
                        self?.displayAlert(title: "Error", message: "clientSecret not found")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                self?.displayAlert(title: "Error", message: "Error parsing JSON")
            }
        })

        task.resume()
    }

    func displayAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }

    @objc func pay() {
        guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
            print("No paymentIntentClientSecret available")
            return
        }

        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Example, Inc."

        print("Presenting payment sheet")
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: paymentIntentClientSecret, configuration: configuration)

        paymentSheet.present(from: self) { [weak self] (paymentResult) in
            switch paymentResult {
            case .completed:
                print("Payment completed")
                self?.displayAlert(title: "Payment complete!")
            case .canceled:
                print("Payment canceled")
            case .failed(let error):
                print("Payment failed: \(error.localizedDescription)")
                self?.displayAlert(title: "Payment failed", message: error.localizedDescription)
            }
        }
    }
}
