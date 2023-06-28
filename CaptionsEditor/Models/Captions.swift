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
    var contents: String
}


struct Captions: Identifiable {
    var id = UUID()
    var items: [Caption] = []
    
    init(id: UUID = UUID(), items: [String]) {
        self.id = id
        self.items = self.captionsFromTextLines(textLines: items)
    }
    
    init(id: UUID = UUID(), fromText text: String) {
        self.id = id
        let textLines = self.textToLines(fullText: text)
        self.items = self.captionsFromTextLines(textLines: textLines)
    }
}

extension Captions {
    func textToLines(fullText text: String) -> [String] {
        var textLines: [String] = []
        text.enumerateLines { line, stop in
            textLines.append(line)
        }
        return textLines
    }
    
    func captionsFromTextLines(textLines: [String]) -> [Caption] {
        return textLines.map { Caption(contents: $0) }
    }
}
