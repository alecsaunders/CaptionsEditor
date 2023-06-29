//
//  Captions.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import Foundation


/// - Tag: DataModel
struct Cue: Identifiable {
    var id = UUID()
    var cueId: String?
    var startTimestamp: Timestamp
    var endTimestamp: Timestamp
    var text: String
    
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


struct Captions: Identifiable {
    var id = UUID()
    var cues: [Cue] = []
    
    init(id: UUID = UUID(), fromText text: String) {
        self.id = id
        self.cues = self.cues(fromText: text)
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
