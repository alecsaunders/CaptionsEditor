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
        let data = String(snapshot).data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}


// Provide operations on the checklist document.
extension CaptionsEditorDocument {
    
    /// Adds a new item, and registers an undo action.
    func addItem(title: String, undoManager: UndoManager? = nil) {
//        checklist.addItem(title: title)
//        let count = checklist.items.count
//        undoManager?.registerUndo(withTarget: self) { doc in
//            withAnimation {
//                doc.deleteItem(index: count - 1, undoManager: undoManager)
//            }
//        }
    }
    
    /// Replaces the existing items with a new set of items.
    func replaceItems(with newItems: [Cue], undoManager: UndoManager? = nil, animation: Animation? = .default) {
        let oldItems = captions.cues

        withAnimation(animation) {
            captions.cues = newItems
        }

        undoManager?.registerUndo(withTarget: self) { doc in
                // Because you recurse here, redo support is automatic.
            doc.replaceItems(with: oldItems, undoManager: undoManager, animation: animation)
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
    func registerUndoTextChange(for item: Cue, oldText: String, undoManager: UndoManager?) {
        let index = captions.cues.firstIndex(of: item)!

        // The change has already happened, so save the collection of new items.
        let newItems = captions.cues

        // Register the undo action.
        undoManager?.registerUndo(withTarget: self) { doc in
            doc.captions.cues[index].text = oldText

            // Register the redo action.
            undoManager?.registerUndo(withTarget: self) { doc in
                // Use the replaceItems symmetric undoable-redoable function.
                doc.replaceItems(with: newItems, undoManager: undoManager, animation: nil)
            }
        }
    }

}
