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
            List($document.captions.cues) { $cue in
                HStack {
                    Text(cue.cueId ?? "no id")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .leading)
                    TimestampView(cue: $cue)
                }
                TextEditor(text: $cue.text)
                Divider()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(CaptionsEditorDocument())
    }
}
