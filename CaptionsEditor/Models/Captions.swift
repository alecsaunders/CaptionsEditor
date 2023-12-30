//
//  Captions.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import Foundation
import CoreMedia


/// - Tag: DataModel
struct Cue: Identifiable, Equatable, Hashable {
    var id = UUID()
    var cueId: Int
    var startTimestamp: Timestamp
    var endTimestamp: Timestamp
    var text: String
    var isOverlapPrev: Bool = false
    var validationErrors: [ValidationError] = []
    var duration: Double {
        return endTimestamp.value - startTimestamp.value
    }
    
    static func == (lhs: Cue, rhs: Cue) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(cueId: Int, startTimestamp: Timestamp, endTimestamp: Timestamp, text: String, isOverlapPrev: Bool = false) {
        self.cueId = cueId
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.text = text
        self.postEditText()
    }
    
    init() {
        self.cueId = 1
        self.startTimestamp = Timestamp()
        self.endTimestamp = Timestamp()
        self.text = ""
    }
    
    mutating func setOverlap(_ isOverlap: Bool = true) {
        self.isOverlapPrev = isOverlap
    }
    
    mutating func postEditText() {
        if self.text.contains("...") {
            self.text = self.text.replacing("...", with: "…")
        }
        self.text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.validationErrors = []
        for valErr in cueTextValidationErrors {
            if valErr.validationLogic(self) {
                self.validationErrors.append(valErr)
            }
        }
    }
}

extension Cue {
    init(_ cue: Cue) {
        self = Cue(cueId: cue.cueId, startTimestamp: cue.startTimestamp, endTimestamp: cue.endTimestamp, text: cue.text)
    }
}

extension String {
    init(_ cue: Cue) {
        var cueText = "\(cue.cueId)\n"
        cueText += "\(cue.startTimestamp.stringValue) --> \(cue.endTimestamp.stringValue)\n"
        cueText += cue.text
        self = cueText
    }
}

struct Captions: Identifiable {
    var id: UUID = UUID()
    var cues: [Cue] = []
    
    init(fromText text: String) {
        self.cues = self.cues(fromText: text)
        self.resetCueIds()
    }
    
    func cue(atTime: CMTime?) -> Cue? {
        if cues.isEmpty {
            return nil
        }
        var theCue = cues[0]
        if let time = atTime?.seconds {
            for (cIdx, cue) in self.cues.enumerated() {
                if cIdx == 0 {
                    continue
                }
                
                let prevCue = self.cues[cIdx - 1]
                
                if time > prevCue.endTimestamp.value && time <= cue.endTimestamp.value {
                    theCue = cue
                }
            }
        }
        return theCue
    }
    
    func getIndex(forCueID cueID: UUID) -> Int {
        var cIdx = 0
        for (_cIdx, cue) in cues.enumerated() {
            if cue.id == cueID {
                cIdx = _cIdx
            }
        }
        return cIdx
    }
    
    mutating func shiftTimestamps(withValue: Double, atCueWithId cueID: UUID, start: Bool) {
        let theIndex = self.getIndex(forCueID: cueID)
        
        // Shift current cue timestamps
        
        // Shift end whether `start` is true or false
        self.shiftTimestamp(atIndex: theIndex, withValue: withValue, start: start)
        if start {
            // Shift start if `start` is true
            self.shiftTimestamp(atIndex: theIndex, withValue: withValue, start: false)
        }
        
        // Shift remaining timestamps
        for cIdx in (theIndex + 1)..<cues.count {
            if cues[cIdx].id != cueID {
                self.shiftTimestamp(atIndex: cIdx, withValue: withValue, start: nil)
            }
        }
    }
    
    mutating func shiftTimestamp(withValue: Double, atCueWithId cueID: UUID, start: Bool?) {
        let cIdx = self.getIndex(forCueID: cueID)
        self.shiftTimestamp(atIndex: cIdx, withValue: withValue, start: start)
    }
    
    mutating private func shiftTimestamp(atIndex idx: Int, withValue value: Double, start: Bool?) {
        let newStartTime = cues[idx].startTimestamp.add(value)
        let newEndTime = cues[idx].endTimestamp.add(value)
        if let start = start {
            if start {
                cues[idx].startTimestamp = newStartTime
            } else {
                cues[idx].endTimestamp = newEndTime
            }
        } else {
            cues[idx].startTimestamp = newStartTime
            cues[idx].endTimestamp = newEndTime
        }
    }
}

extension String {
    init(_ captions: Captions) {
        let cueList = captions.cues.map { String($0) }
        let cueContents = cueList.joined(separator: "\n\n")
        self = "WEBVTT\n\n\(cueContents)"
    }
}

extension Captions {
    private func cues(fromText text: String) -> [Cue] {
        let textLines = self.textToLines(fullText: text)
        let cueLinesCollection = cueLines(fromTextLines: textLines)
        
        var cues: [Cue] = []
        cues = cueLinesCollection.map { cue(fromCueLines: $0) }
        // TODO: Check for overlap
        return cues
    }
    
    private func textToLines(fullText text: String) -> [String] {
        var textLines: [String] = []
        text.enumerateLines { line, stop in
            textLines.append(line)
        }
        return textLines
    }
    
    private func cueLines(fromTextLines textLines: [String]) -> [[String]] {
        var cleanLines: [String] = []
        for line in textLines {
            if line.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) != "webvtt" {
                cleanLines.append(line)
            }
        }

        var cueLinesCollection: [[String]] = []
        var cueLines: [String] = []
        for line in cleanLines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !cueLines.isEmpty {
                    cueLinesCollection.append(cueLines)
                    cueLines = []
                }
            } else {
                cueLines.append(line)
            }
        }
        cueLinesCollection.append(cueLines)
        return cueLinesCollection
    }
    
    private func cue(fromCueLines cueLines: [String]) -> Cue {
        let id: Int = cueId(fromCueLines: cueLines)
        let timestampLine: String = timestampLine(fromCueLines: cueLines) ?? ""
        let startTimestamp = startTimestamp(fromTimestampLine: timestampLine)
        let endTimestamp = endTimestamp(fromTimestampLine: timestampLine)
        let text: String = cueText(fromCueLines: cueLines)
        
        return Cue(cueId: id, startTimestamp: startTimestamp, endTimestamp: endTimestamp, text: text, isOverlapPrev: false)
    }
    
    private func cueId(fromCueLines cueLines: [String]) -> Int {
        if let firstLine = cueLines.first {
            if firstLine.contains("-->") {
                return 1
            } else {
                return Int(firstLine.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 1
            }
        }
        return 1
    }
    
    private func timestampLine(fromCueLines cueLines: [String]) -> String? {
        for line in cueLines {
            if line.contains("-->") {
                return line
            }
        }
        return nil
    }
    
    private func startTimestamp(fromTimestampLine tsLine: String) -> Timestamp {
        let timestampStr: String = String(tsLine.split(separator: "-->").first ?? "")
        return timestamp(fromString: timestampStr)
    }
    
    private func endTimestamp(fromTimestampLine tsLine: String) -> Timestamp {
        let timestampStr: String = String(tsLine.split(separator: "-->").last ?? "")
        return timestamp(fromString: timestampStr)
    }
    
    private func timestamp(fromString tsString: String) -> Timestamp {
        if !tsString.isEmpty {
            return Timestamp(tsString)
        }
        return Timestamp()
        
    }
           
    private func cueText(fromCueLines cueLines: [String]) -> String {
        var foundTimestampLine = false
        var cueText = ""
        for line in cueLines {
            if foundTimestampLine {
                if cueText.isEmpty {
                    cueText = line
                } else {
                    cueText = "\(cueText)\n\(line)"
                }
            } else if line.contains("-->") {
                foundTimestampLine = true
            }
        }
        return cueText.trimmingCharacters(in: .newlines)
    }
}

extension Captions {
    mutating func resetCueIds() {
        for cIdx in 0..<cues.count {
            cues[cIdx].cueId = cIdx + 1
        }
    }
}
