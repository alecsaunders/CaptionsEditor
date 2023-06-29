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
    
    var file: ReferenceFileDocumentConfiguration<CaptionsEditorDocument>
    
    /// The undo manager that the environment stores.
    /// - Tag: UndoManager
    @Environment(\.undoManager) var undoManager
    
    @StateObject private var playerController = PlayerController()
    @State var selectedCue: Cue?
    @State private var scrollTarget: Int?
    @State private var searchResults: [Cue] = []

    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewReader { (proxy: ScrollViewProxy) in
                    LazyVStack {
                        ForEach($document.captions.cues, id: \.id) { $cue in
                            CueRow(cue: $cue, selectedCue: $selectedCue) { oldText in
                                document.registerUndoTextChange(for: $cue.wrappedValue, oldText: oldText, undoManager: undoManager)
                            }
                            .onHover { isHovering in
                                if isHovering {
                                    selectedCue = cue
                                } else {
                                    selectedCue = nil
                                }
                            }
                            .id(cue.id)
                        }
                        .onDelete(perform: onDelete)
                    }
                    .frame(minWidth: 310, maxWidth: 400)
                }
            }
            PlayerView()
        }
        .onAppear() {
            playerController.subsURL = file.fileURL
        }
        .toolbar {
            ToolbarView()
        }
        .environmentObject(playerController)
    }
    
    func onDelete(offsets: IndexSet) {
        document.delete(offsets: offsets, undoManager: undoManager)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environmentObject(CaptionsEditorDocument())
//    }
//}
