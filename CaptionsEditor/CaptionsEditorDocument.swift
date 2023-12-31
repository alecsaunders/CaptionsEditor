//
//  CaptionsEditorDocument.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var webVTTDocumentType: UTType {
        UTType(importedAs: "com.custom.vtt")
    }
}

class CaptionsEditorDocument: ReferenceFileDocument {
    typealias Snapshot = Captions
    @Published var captions: Captions
    var text: String {
        get {
            String(captions)
        }
        set {
            captions = Captions(fromText: newValue)
        }
    }

    init() {
        captions = Captions(fromText: "WebVTT\n\n1\n1 --> 2\nsometext")
    }

    static var readableContentTypes: [UTType] { [.webVTTDocumentType] }

    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        captions = Captions(fromText: string)
    }
    
    func snapshot(contentType: UTType) throws -> Captions {
        captions
    }
    
    func fileWrapper(snapshot: Captions, configuration: WriteConfiguration) throws -> FileWrapper {
        let snapStr = String(snapshot)
        let data = snapStr.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}


// Provide operations on the checklist document.
extension CaptionsEditorDocument {
    
    /// Adds a new item, and registers an undo action.
    func addItem(atIndex: Int, undoManager: UndoManager? = nil) {
        var newCue = Cue(cueId: 1, startTimestamp: Timestamp(0), endTimestamp: Timestamp(1.0), text: "new subtitle")
        if atIndex > 0 {
            let previousCue = captions.cues[atIndex - 1]
            newCue = Cue(cueId: atIndex, startTimestamp: previousCue.endTimestamp.add(0.1), endTimestamp: previousCue.endTimestamp.add(1.1), text: "new subtitle")
        }
        withAnimation {
            self.captions.cues.insert(newCue, at: atIndex)
            self.captions.resetCueIds()
        }
        
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.deleteItem(withID: newCue.id, undoManager: undoManager)
        }
    }
    
    /// Replaces the existing items with a new set of items.
    func replaceItems(with newItems: [Cue], undoManager: UndoManager? = nil) {
        let oldItems = captions.cues

        withAnimation {
            captions.cues = newItems
        }

        undoManager?.registerUndo(withTarget: self) { doc in
                // Because you recurse here, redo support is automatic.
            doc.replaceItems(with: oldItems, undoManager: undoManager)
        }
    }
    
    /// Deletes the items with specified IDs.
    func deleteItem(withID id: UUID, undoManager: UndoManager? = nil) {
        var indexSet: IndexSet = IndexSet()

        let enumerated = captions.cues.enumerated()
        for (index, item) in enumerated where id == item.id {
            indexSet.insert(index)
        }

        delete(offsets: indexSet, undoManager: undoManager)
    }

    /// Deletes the items at a specified set of offsets, and registers an undo action.
    func delete(offsets: IndexSet, undoManager: UndoManager? = nil) {
        let oldItems = captions.cues
        withAnimation {
            captions.cues.remove(atOffsets: offsets)
            captions.resetCueIds()
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceItems(with: oldItems, undoManager: undoManager)
        }
    }
    
    /// Registers an undo action and a redo action for a title change.
    func registerUndoTextChange(withOldValue: String, atCueWithId cueID: UUID, undoManager: UndoManager? = nil) {
        let theIndex = captions.getIndex(forCueID: cueID)
        var oldItems = captions.cues
        oldItems[theIndex].text = withOldValue

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceItems(with: oldItems, undoManager: undoManager)
        }
    }

    /// Registers timeshift, and registers an undo action.
    func shiftTimeValues(withValue: Double, atCueWithId cueID: UUID, start: Bool, undoManager: UndoManager? = nil) {
        let oldItems = captions.cues
        
        withAnimation {
            captions.shiftTimestamps(withValue: withValue, atCueWithId: cueID, start: start)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceItems(with: oldItems, undoManager: undoManager)
        }
    }
    
    /// Registers timeshift, and registers an undo action.
    func shiftTime(withValue: Double, atCueWithId cueID: UUID, start: Bool?, undoManager: UndoManager? = nil) {
        let oldItems = captions.cues
        
        withAnimation {
            self.captions.shiftTimestamp(withValue: withValue, atCueWithId: cueID, start: start)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceItems(with: oldItems, undoManager: undoManager)
        }
    }
    
    /// Registers timeshift, and registers an undo action.
    func setTime(withValue: Double, atCueWithId cueID: UUID, start: Bool, undoManager: UndoManager? = nil) {
        let oldItems = captions.cues
        
        withAnimation {
            self.captions.setTime(withValue: withValue, atCueWithId: cueID, start: start)
        }

        undoManager?.registerUndo(withTarget: self) { doc in
            doc.replaceItems(with: oldItems, undoManager: undoManager)
        }
    }
}
