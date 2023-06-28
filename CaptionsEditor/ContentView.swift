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
        ScrollView {
            VStack {
                ForEach($document.captions.cues) { $caption in
                    VStack {
                        Text(caption.cueId ?? "no id")
                        HStack {
                            Text(caption.startTimestamp.text)
                            Text(" --> ")
                            Text(caption.endTimestamp.text)
                        }
                        Text(caption.text)
                        Divider()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(CaptionsEditorDocument())
    }
}
