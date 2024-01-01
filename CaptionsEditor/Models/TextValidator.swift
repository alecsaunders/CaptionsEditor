//
//  TextValidator.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 12/28/23.
//

import Foundation


struct ValidationError: Identifiable {
    let id: String
    let name: String
    let description: String
    let validationLogic: (_ cue: Cue) -> Bool
}


let charactureLimitation = ValidationError(id: "I.1", name: "Character Limitation", description: "42 characters per line") { cue in
    for line in cue.text.split(separator: "\n") {
        if line.count > 42 {
            return true
        }
    }
    return false
}

let lineTreatment = ValidationError(id: "I.10", name: "Line Treatment", description: "Maximum two lines.") { cue in
    let textLines = cue.text.split(separator: "\n")
    if textLines.count > 2 {
        return true
    }
    return false
}

let readingSpeedLimits = ValidationError(id: "I.14", name: "Reading Speed Limits", description: "Up to 20 characters per second") { cue in
    let numCharacters = cue.text.count
    let charPerSecond = Double(numCharacters) / cue.duration
    if charPerSecond > 20 {
        return true
    }
    return false
}

let cueTextValidationErrors: [ValidationError] = [
    charactureLimitation,
    lineTreatment,
    readingSpeedLimits
]

