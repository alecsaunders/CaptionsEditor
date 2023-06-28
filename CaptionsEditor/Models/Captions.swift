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
        return self.captionsFromTextLines(textLines: textLines)
    }
    
    func textToLines(fullText text: String) -> [String] {
        var textLines: [String] = []
        text.enumerateLines { line, stop in
            textLines.append(line)
        }
        return textLines
    }
    
    func captionsFromTextLines(textLines: [String]) -> [Caption] {
        var captions: [Caption] = []
        
        for line in textLines {
            if line.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == "webvtt" {
                print("Found Webvtt line")
                print(line)
            } else {
                captions.append(Caption(contents: line))
            }
        }
        
        return captions
    }
}
