//
//  File.swift
//  
//
//  Created by Elikem Savie on 17/10/2022.
//

import Foundation

public struct Validator {
    
    public static func luhnCheck(_ number: String) -> Bool {
        var sum = 0
        let digitStrings = number.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    public static func expDateValidation(dateStr: String) -> Bool {

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        var _tempDateStr = dateStr
        if dateStr.count < 5 {
            _tempDateStr.insert(contentsOf: "20", at: _tempDateStr.index(_tempDateStr.startIndex, offsetBy: 2))
        }

         guard let actualDate = Date(_tempDateStr, format: "MMyyyy") else { return false }
        let enteredYear = Calendar.current.dateComponents([.year], from: actualDate).year ?? 0
        let enteredMonth = Calendar.current.dateComponents([.month], from: actualDate).month ?? 0

        if enteredYear > currentYear {
            if (1 ... 12).contains(enteredMonth) {
                return true
            } else {
                return false
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if (1 ... 12).contains(enteredMonth) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }

    }

    public static func isTooFarInFuture(dateStr: String) -> Bool {
    
        let currentYear = Calendar.current.component(.year, from: Date())
        
        var _tempDateStr = dateStr
        if dateStr.count < 5 {
            _tempDateStr.insert(contentsOf: "20", at: _tempDateStr.index(_tempDateStr.startIndex, offsetBy: 2))
        }
        
        guard let actualDate = Date(_tempDateStr, format: "MMyyyy") else { return false }
        let enteredYear = Calendar.current.dateComponents([.year], from: actualDate).year ?? 0

        guard enteredYear > (currentYear + 20) else {
            return false
        }
        return true
    }

}
