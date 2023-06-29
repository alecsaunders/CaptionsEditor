//
//  ContentView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct ContentView: View {
    /// The document that the environment stores.
    @EnvironmentObject var document: CaptionsEditorDocument
    /// The undo manager that the environment stores.
    /// - Tag: UndoManager
    @Environment(\.undoManager) var undoManager
    
    @State var selectedCue: Cue?
    
    /// The internal selection state.
    @State private var selection = Set<UUID>()

    var body: some View {
        NavigationView {
            List {
                ForEach($document.captions.cues, id: \.id) { $cue in
                    CueRow(cue: $cue, selectedCue: $selectedCue) { oldText in
                        document.registerUndoTextChange(for: $cue.wrappedValue, oldText: oldText, undoManager: undoManager)
                    }
                    .onHover { isHovering in
                        if isHovering {
                            selectedCue = cue
                        }
                    }
                }
                    .onDelete(perform: onDelete)
            }
                .frame(minWidth: 305, maxWidth: 400)
        }
    }
    
    func onDelete(offsets: IndexSet) {
        document.delete(offsets: offsets, undoManager: undoManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(CaptionsEditorDocument())
    }
}
