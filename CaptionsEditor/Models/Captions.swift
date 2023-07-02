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
    var cueId: String?
    var startTimestamp: Timestamp
    var endTimestamp: Timestamp
    var text: String
    
    static func == (lhs: Cue, rhs: Cue) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(cueId: String? = nil, startTimestamp: Timestamp, endTimestamp: Timestamp, text: String) {
        self.cueId = cueId
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.text = text
    }
    
    init() {
        self.startTimestamp = Timestamp()
        self.endTimestamp = Timestamp()
        self.text = ""
    }
}

extension Cue {
    init(_ cue: Cue) {
        self = Cue(cueId: cue.cueId, startTimestamp: cue.startTimestamp, endTimestamp: cue.endTimestamp, text: cue.text)
    }
}

extension String {
    init(_ cue: Cue) {
        var cueText = ""
        if let cueId = cue.cueId {
            cueText = "\(cueId)\n"
        }
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
    
    mutating func shiftTimestamps(withValue: Double, atCueWithId cueID: UUID, start: Bool) {
        var atOrAfterCue = false
        for (cIdx, cue) in cues.enumerated() {
            if cue.id == cueID {
                atOrAfterCue = true
                if start {
                    cues[cIdx].startTimestamp.add(withValue)
                }
                cues[cIdx].endTimestamp.add(withValue)
            }
            if !atOrAfterCue {
                continue
            }
            
            if cue.id != cueID {
                cues[cIdx].startTimestamp.add(withValue)
                cues[cIdx].endTimestamp.add(withValue)
            }
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
    func cues(fromText text: String) -> [Cue] {
        let textLines = self.textToLines(fullText: text)
        let cueLinesCollection = cueLines(fromTextLines: textLines)
        
        var captions: [Cue] = []
        captions = cueLinesCollection.map { cue(fromCueLines: $0) }
        return captions
    }
    
    func textToLines(fullText text: String) -> [String] {
        var textLines: [String] = []
        text.enumerateLines { line, stop in
            textLines.append(line)
        }
        return textLines
    }
    
    func cueLines(fromTextLines textLines: [String]) -> [[String]] {
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
    
    func cue(fromCueLines cueLines: [String]) -> Cue {
        let id: String? = cueId(fromCueLines: cueLines)
        let timestampLine: String = timestampLine(fromCueLines: cueLines) ?? ""
        let startTimestamp = startTimestamp(fromTimestampLine: timestampLine)
        let endTimestamp = endTimestamp(fromTimestampLine: timestampLine)
        let text: String = cueText(fromCueLines: cueLines)
        
        return Cue(cueId: id, startTimestamp: startTimestamp, endTimestamp: endTimestamp, text: text)
    }
    
    func cueId(fromCueLines cueLines: [String]) -> String? {
        if let firstLine = cueLines.first {
            if firstLine.contains("-->") {
                return nil
            } else {
                return firstLine
            }
        }
        return nil
    }
    
    func timestampLine(fromCueLines cueLines: [String]) -> String? {
        for line in cueLines {
            if line.contains("-->") {
                return line
            }
        }
        return nil
    }
    
    func startTimestamp(fromTimestampLine tsLine: String) -> Timestamp {
        let timestampStr: String = String(tsLine.split(separator: "-->").first ?? "")
        return timestamp(fromString: timestampStr)
    }
    
    func endTimestamp(fromTimestampLine tsLine: String) -> Timestamp {
        let timestampStr: String = String(tsLine.split(separator: "-->").last ?? "")
        return timestamp(fromString: timestampStr)
    }
    
    func timestamp(fromString tsString: String) -> Timestamp {
        if !tsString.isEmpty {
            return Timestamp(tsString)
        }
        return Timestamp()
        
    }
           
    func cueText(fromCueLines cueLines: [String]) -> String {
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
