//
//  File.swift
//  
//
//  Created by Elikem Savie on 26/02/2023.
//

import Foundation

public protocol CardRegistrationClientProtocol {
    func postCardInfo(_ cardInfo: CardInfo, url: URL, tenant: Tenant) async throws -> CardInfo.RegistrationData
    func updateCardRegistration(
        _ regData: CardInfo.RegistrationData,
        clientId: String,
        cardRegistrationId: String
    ) async throws -> CardRegistration
}

public final class MangopayVaultClient: NetworkUtil, CardRegistrationClientProtocol {
    
    var baseUrl: URL!

    public init(url: URL) {
        self.baseUrl = url
    }

    public init(env: Environment) {
        self.baseUrl = env.url
    }
    
    public func postCardInfo(
        _ cardInfo: CardInfo,
        url: URL,
        tenant: Tenant
    ) async throws -> CardInfo.RegistrationData {

        return try await request(
            url: url,
            method: .post,
            additionalHeaders: [
                "Content-Type" : "application/x-www-form-urlencoded",
                "x-tentant-id": tenant.rawValue
            ],
            bodyParam: cardInfo.toDict(),
            expecting: CardInfo.RegistrationData.self,
            verbose: true,
            useXXForm: true,
            decodeAsString: true
        )
    }

    public func updateCardRegistration(
        _ regData: CardInfo.RegistrationData,
        clientId: String,
        cardRegistrationId: String
    ) async throws -> CardRegistration {
        
        let url = baseUrl.appendingPathComponent(
            "/\(apiVersion)/\(clientId)/CardRegistrations/\(cardRegistrationId)",
            isDirectory: false
        )

        return try await request(
            url: url,
            method: .put,
            additionalHeaders: [
                "Content-Type": "application/json",
            ],
            bodyParam: regData.toDict(),
            expecting: CardRegistration.self,
            verbose: true
        )
    }

    public func createCardRegistration(
        _ card: CardRegistration.Initiate,
        clientId: String,
        apiKey: String
    ) async throws -> CardRegistration {

        let url = baseUrl.appendingPathComponent(
            "/\(apiVersion)/\(clientId)/cardregistrations",
            isDirectory: false
        )

        return try await request(
            url: url,
            method: .post,
            additionalHeaders: [
                "Content-Type" : "application/json",
            ],
            bodyParam: card.toDict(),
            expecting: CardRegistration.self,
            basicAuthDict: [
                "Username" : clientId,
                "Password": apiKey
            ],
            apiKey: apiKey,
            verbose: true
        )
    }
}
