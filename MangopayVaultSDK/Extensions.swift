//
//  File.swift
//  
//
//  Created by Elikem Savie on 14/06/2023.
//

import Foundation

extension Encodable {
    func toDict() -> [String: Any]? {
        return (try? JSONSerialization.jsonObject(
            with: JSONEncoder().encode(self),
            options: .fragmentsAllowed)
        ) as? [String: Any]
    }
}

extension Date {
    public init?(_ string: String, format: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        guard let date = dateFormatter.date(from: string) else { return nil }
        self = date
    }

    func string(format: String = "d MMMM yyyy", shouldUseSuffix: Bool = false, timeZone: TimeZone? = nil) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        if let tz = timeZone {
            dateFormatter.timeZone = tz
        }
        return dateFormatter.string(from: self)
    }
}

extension URLSession {
    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func asyncData(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    @available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
    func asyncUploadData(for request: URLRequest, data: Data) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.uploadTask(with: request, from: data) { data, response, error in
                guard let data = data, let response = response else {
                    let error = error ?? URLError(.badServerResponse)
                    return continuation.resume(throwing: error)
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

}
