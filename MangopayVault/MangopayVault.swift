//
//  File.swift
//  
//
//  Created by Elikem Savie on 22/02/2023.
//

import Foundation

public typealias MangopayCallBack = ((CardRegistration?, Error?) -> ())

public protocol MangopayVaultDelegate: AnyObject {
    func onSuccess(card: CardRegistration)
    func onFailure(error: Error)
}

public protocol MangopayVaultCreateCustomerDelegate: AnyObject {
    func onCustomerCreatedSuccessfully(customerId: String)
    func onCustomerCreationFailed(error: Error)
}

public enum Environment: String {
    case sandbox
    case prod

    public var url: URL {
        switch self {
        case .sandbox:
            return URL(string: "https://api.sandbox.mangopay.com")!
        case .prod:
            return URL(string: "https://api.mangopay.com")!
        }
    }
}

public class MangopayVault {
    
    private static var paylineClient: CardRegistrationClientProtocol?

    private static var clientId: String? = nil
    private static var environment: Environment = .sandbox

    public static func initialize(clientId: String, environment: Environment) {
        self.clientId = clientId
        self.environment = environment
    }

    func setPaylineClient(paylineClient: CardRegistrationClientProtocol) {
        MangopayVault.paylineClient = paylineClient
    }

    public static func tokenizeCard(
        card: Cardable,
        cardRegistration: CardRegistration? = nil,
        mangoPayVaultCallback: @escaping MangopayCallBack
    ) {
        do {
            let isValidCard = try validateCard(with: card)
            guard isValidCard else { return }
            guard let _cardRegistration = cardRegistration else { return }
            
            tokenizeMGP(
                with: card,
                cardRegistration: _cardRegistration,
                mangoPayVaultCallback: mangoPayVaultCallback
            )
        } catch {
            mangoPayVaultCallback(.none, error)
        }
    }

    private static func tokenizeMGP(
        with card: Cardable,
        cardRegistration: CardRegistration?,
        mangoPayVaultCallback: @escaping MangopayCallBack
    ) {

        guard let _cardRegistration = cardRegistration else { return }
        
        guard let _clientId = MangopayVault.clientId else { return }

        if paylineClient == nil {
            paylineClient = MangopayVaultClient(url: MangopayVault.environment.url)
        }

        Task {
            do {
                guard let url = _cardRegistration.registrationURL else { return }
                
                guard var _card = card as? CardInfo else { return }

                _card.accessKeyRef = _cardRegistration.accessKey
                _card.data = _cardRegistration.preregistrationData

                let redData = try await self.paylineClient!.postCardInfo(_card, url: url)
                
                guard !redData.RegistrationData.hasPrefix("errorCode") else {
                    let code = String(redData.RegistrationData.split(separator: "=").last ?? "")
                    DispatchQueue.main.async {
                        let error =  NSError(
                            domain: "Payline API error: \(redData.RegistrationData)",
                            code: Int(code) ?? 09101,
                            userInfo: ["Error": redData.RegistrationData]
                        )
                        mangoPayVaultCallback(.none, error)
                    }
                    return
                }
                guard let cardId = _cardRegistration.id else { return }
                
                let updateRes = try await paylineClient!.updateCardRegistration(
                    redData,
                    clientId: _clientId,
                    cardRegistrationId: cardId
                )
                DispatchQueue.main.async {
                    mangoPayVaultCallback(updateRes, .none)
                }
            } catch {
                DispatchQueue.main.async {
                    mangoPayVaultCallback(.none, error)
                }
            }
        }
        
    }

    static func validateCard(with cardInfo: Cardable) throws -> Bool {
        
        guard let cardNum = cardInfo.cardNumber else {
            throw CardValidationError.cardNumberRqd
        }
        
        guard let expirationDate = cardInfo.cardExpirationDate else {
            throw CardValidationError.expDateRqd
        }
        
        guard let cvv = cardInfo.cvc else {
            throw CardValidationError.cvvRqd
        }
        
        if !Validator.luhnCheck(cardNum) {
            throw CardValidationError.cardNumberInvalid
        }
        
        if !Validator.expDateValidation(dateStr: expirationDate) {
            throw CardValidationError.expDateInvalid
        }
        
        if !(cvv.count >= 3 && cvv.count <= 4) {
            throw CardValidationError.cvvInvalid
        }
        
        return true
    }
}

