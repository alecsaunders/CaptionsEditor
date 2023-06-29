//
//  Timestamp.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import Foundation


struct Timestamp {
    var value: Double
    var stringValue: String
    
    init() {
        self.value = 0.0
        self.stringValue = self.value.toTimestampString()
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
        self.stringValue = self.value.toTimestampString()
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
        milStr = "\(milliseconds)".count == 3 ? "\(milliseconds)" : "0\(milliseconds)"
        
        return "\(hrStr):\(minStr):\(secStr).\(milStr)"
    }
}


extension String {
    init(_ timestamp: Timestamp) {
        self = timestamp.stringValue
    }
}
