//
//  Captions.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import Foundation


/// - Tag: DataModel
struct Caption: Identifiable {
    var id = UUID()
//    var cueId: Int
    var contents: String
}


struct Captions: Identifiable {
    var id = UUID()
    var items: [Caption] = []
    
    init(id: UUID = UUID(), fromText text: String) {
        self.id = id
        self.items = self.captions(fromText: text)
    }
}

extension Captions {
    func captions(fromText text: String) -> [Caption] {
        let textLines = self.textToLines(fullText: text)
        let cueLinesCollection = cueLines(fromTextLines: textLines)
        
        var captions: [Caption] = []
        captions = cueLinesCollection.map { Caption(contents: $0.joined(separator: "\n")) }
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
                cueLinesCollection.append(cueLines)
                cueLines = []
            } else {
                cueLines.append(line)
            }
        }
        return cueLinesCollection
    }
}
