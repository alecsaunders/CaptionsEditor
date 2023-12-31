//
//  Timestamp.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import Foundation


struct Timestamp {
    var value: Double
    var stringValue: String {
        self.value.toTimestampString()
    }
    
    init(_ initValue: Double = 0.0) {
        self.value = initValue
    }
    
    init(_ initText: String) {
        self.value = 0.0
        var text = initText.trimmingCharacters(in: .whitespaces)
        
        if text.contains(":") && (text.contains(".") || text.contains(",")) {
            text.replace(",", with: ".")
            let parts = text.split(separator: ".")
            let hmsStr = parts[0]
            let milliseconds = Double(parts[1])!
            
            var hmsParts = hmsStr.split(separator: ":")
            let seconds = Double(hmsParts.popLast()!)!
            let minutes = Double(hmsParts.popLast()!)!
            let hours = Double(hmsParts.popLast() ?? "0")!
            
            self.value = (hours * 60.0 * 60.0) + (minutes * 60.0) + (seconds) + (milliseconds / 1000)
        } else {
            self.value = 0.0
        }
    }
    
    func add(_ addValue: Double) -> Timestamp {
        let newValue = self.value + addValue
        return Timestamp(newValue)
    }
}

extension Timestamp {
    static func < (left: Timestamp, right: Timestamp) -> Bool {
        return left.value < right.value
    }
    
    static func > (left: Timestamp, right: Timestamp) -> Bool {
        return left.value > right.value
    }
}

extension Double {
    func toTimestampString() -> String {
        let rounded = Int(self)
        let milliseconds = Int((self * 1000.0) - Double(rounded * 1000))
        let hours = rounded / 3600
        let minutesRemainder = rounded - (hours * 3600)
        let minutes = minutesRemainder / 60
        let seconds = minutesRemainder - (minutes * 60)
        
        let hrStr = "\(hours)".count == 2 ? "\(hours)" : "0\(hours)"
        let minStr = "\(minutes)".count == 2 ? "\(minutes)" : "0\(minutes)"
        let secStr = "\(seconds)".count == 2 ? "\(seconds)" : "0\(seconds)"
        var milStr = "\(milliseconds)".count == 3 ? "\(milliseconds)" : "0\(milliseconds)"
        milStr = "\(milStr)".count == 3 ? "\(milStr)" : "0\(milStr)"
        
        return "\(hrStr):\(minStr):\(secStr).\(milStr)"
    }
}


extension String {
    init(_ timestamp: Timestamp) {
        self = timestamp.stringValue
    }
}
