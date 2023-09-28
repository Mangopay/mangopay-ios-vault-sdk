//
//  ViewController.swift
//  VaultDemo
//
//  Created by Elikem Savie on 15/06/2023.
//

import UIKit
import MangopayVault

class ViewController: UIViewController {

    @IBOutlet weak var apiKeyTextfield: UITextField!
    @IBOutlet weak var userIdTextfield: UITextField!
    @IBOutlet weak var clientIDTextfield: UITextField!

    @IBOutlet weak var cardNumberTextfield: UITextField!
    @IBOutlet weak var cvvTextfield: UITextField!
    @IBOutlet weak var cardNameField: UITextField!
    
    @IBOutlet weak var mmExpiryField: UITextField!
    @IBOutlet weak var yyExpiryField: UITextField!
    
    @IBOutlet weak var activityMonitor: UIActivityIndicatorView!

    var clientId: String = ""
    var userId: String = ""
    var apiKey: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        showLoader(false)

        apiKeyTextfield.text = "7fOfvt3ozv6vkAp1Pahq56hRRXYqJqNXQ4D58v5QCwTocCVWWC"
        clientIDTextfield.text = "checkoutsquatest"
        userIdTextfield.text = "158091557"
        cvvTextfield.text = "123"
        cardNumberTextfield.text = "4242424242424242"
        mmExpiryField.text = "12"
        yyExpiryField.text = "23"
    }

    @IBAction func didTapPay(_ sender: UIButton) {
        clientId = clientIDTextfield.text ?? ""
        apiKey = apiKeyTextfield.text ?? ""
        userId = userIdTextfield.text ?? ""

        guard let card = grabData() else {
            return
        }

        Task {
            if let createdObj = await createCardReg(
                cardReg: CardRegistration.Initiate(
                    UserId: userId,
                    Currency: "EUR",
                    CardType: "CB_VISA_MASTERCARD"),
                clientId: clientId,
                apiKey: apiKey
            ) {
                performVaultTokenisation(card: card, cardRegistration: createdObj)
            }
        }
    }

    func grabData() -> CardInfo? {
        
        guard let cardNum = cardNumberTextfield.text,
              let cardName = cardNameField.text,
              let cvv = cvvTextfield.text,
              let month = mmExpiryField.text,
              let year = yyExpiryField.text else { return nil }
        
        let expStr = month + year
        
        return CardInfo(
            cardNumber: cardNum,
            cardHolderName: cardName,
            cardExpirationDate: expStr,
            cardCvx: cvv
        )
    }

    func showLoader(_ show: Bool) {
        activityMonitor.isHidden = !show
        if show {
            activityMonitor.startAnimating()
        } else {
            activityMonitor.stopAnimating()
        }
    }

    func createCardReg(
        cardReg: CardRegistration.Initiate,
        clientId: String,
        apiKey: String
    ) async -> CardRegistration? {
        do {
            showLoader(true)
            
            let regResponse = try await MangopayVaultClient(
                env: .sandbox
            ).createCardRegistration(
                cardReg,
                clientId: clientId,
                apiKey: apiKey
            )
            showLoader(false)
            
            return regResponse
        } catch {
            print("❌ Error Creating Card Registration")
            showLoader(false)
            return nil
        }
    }
  
    func performVaultTokenisation(card: CardInfo, cardRegistration: CardRegistration) {
        
        MangopayVault.initialize(clientId: clientId, environment: .sandbox)
        
        showLoader(true)
        
        MangopayVault.tokenizeCard(
            card: card,
            cardRegistration: cardRegistration) { card, error in
                guard let _ = card else {
                    print("✅ failed", error)
                    self.showLoader(false)
                    self.showAlert(with: error?.localizedDescription ?? "", title: "Failed ❌")
                    return
                }
                self.showLoader(false)
                self.showAlert(with: "", title: "Successful 🎉")
            }
    }

}

extension ViewController {
    private func showAlert(with cardToken: String, title: String) {
        let alert = UIAlertController(
            title: title,
            message: cardToken,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .default
        ) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
