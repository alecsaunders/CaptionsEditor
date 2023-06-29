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
    
    /// The internal selection state.
    @State private var selection = Set<UUID>()

    var body: some View {
        NavigationView {
            List {
                ForEach($document.captions.cues, id: \.id) { $cue in
                    VStack {
                        HStack {
                            cueIdPlayButton(cue: $cue)
                            TimestampView(cue: $cue)
                        }
                        TextEditor(text: $cue.text)
                        Divider()
                    }
                }
                    .onDelete(perform: onDelete)
            }
                .frame(minWidth: 280, maxWidth: 400)
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
