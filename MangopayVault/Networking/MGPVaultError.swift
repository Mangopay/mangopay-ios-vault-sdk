//
//  NetworkError.swift
//  OZE
//
//  Created by Elikem Savie on 27/04/2022.
//

import Foundation

public enum MGPVaultError: Error {
    case noDataReturned
    case redirectError
    case clientError(additionalInfo: [String: Any]?, headerInfo: [AnyHashable: Any]?)
    case serverError(additionalInfo: [String: Any]?)
    case noResponse
    case notImplemented
    case unknownError

    case cardNumberRqd
    case cardNumberInvalid
    case expDateRqd
    case expDateInvalid
    case expInFuture
    case cvvRqd
    case cvvInvalid

    case cardRegFailed
    case cardTokenError

    var reason: String {
        switch self {
        case .noResponse:
            return "No response returned from server"
        case .noDataReturned:
            return "An error occurred while fetching data"
        case .notImplemented:
            return "Not implemented"
        case .unknownError:
            return "An unknown error occurred while fetching data"
        case .redirectError:
            return "Redirect errors occurred while processing request"
        case .clientError:
            return "A client error occurred while processing request"
        case .serverError:
            return "Server errors occurred while processing request"
        case .cardNumberRqd:
            return "Card Number Required"
        case .cardNumberInvalid:
            return "Card Number Invalid"
        case .expDateRqd:
            return "Expiration Date Required"
        case .expDateInvalid:
            return "Expiration Date Invalid"
        case .expInFuture:
            return "Card Expiry too far in the future"
        case .cvvRqd:
            return "CVV Required"
        case .cvvInvalid:
            return "CVV Invalid"
        case .cardRegFailed:
            return "CardRegistration error"
        case .cardTokenError:
            return "Token processing error"
        }
    }

    var description: String {
        switch self {
        case .cardNumberInvalid, .cardNumberRqd:
            return "The card number’s format provided for the card registration is invalid."
        case .expDateInvalid, .expDateRqd:
            return "The card’s expiry date information provided for the card registration is either invalid or missing."
        case .cvvRqd, .cvvInvalid:
            return "The card verification code information provided for the card registration is either invalid or missing."
        case .cardRegFailed, .noDataReturned, .noResponse:
            return "The card registration failed"
        case .cardTokenError:
            return "The token for the card wasn't created. This error occurs when the tokenization server does not receive any data during the tokenization HTTP call. It can be due to a timeout, or the call being blocked by an anti-virus, plugin, or extension."
        default:
            return self.reason
        }
    }

    var code: Int {
        switch self {
        case .clientError(additionalInfo: let _, headerInfo: let _):
            return -0005
        case .serverError(additionalInfo: let _):
            return -0004
        case .redirectError:
            return -0003
        case .notImplemented:
            return -0001
        case .unknownError:
            return -0002
        case .cardNumberInvalid, .expInFuture, .cardNumberRqd:
            return 105202
        case .expDateInvalid, .expDateRqd:
            return 105203
        case .cvvRqd, .cvvInvalid:
            return 105204
        case .cardRegFailed, .noDataReturned, .noResponse:
            return 101699
        case .cardTokenError:
            return 001599
        }
    }
}
