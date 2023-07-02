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
    
    @EnvironmentObject var playerController: PlayerController
    @State var selectedCue: Cue?
    @State var searchText: String = ""
    @State private var scrollTarget: UUID?
    @State private var searchResults: [Cue] = []

    var body: some View {
        NavigationView {
            ScrollView {
                ScrollViewReader { (proxy: ScrollViewProxy) in
                    LazyVStack {
                        ForEach($document.captions.cues, id: \.self) { $cue in
                            CueRow(cue: $cue, selectedCue: $selectedCue, tempText: cue.text) { oldText in
                                document.registerUndoTextChange(for: $cue.wrappedValue, oldText: oldText, undoManager: undoManager)
                            }
                            .id(cue.id)
//                            .searchable(text: $searchText, placement: .sidebar) {
//                                SearchView(searchResults: $searchResults, scrollTarget: $scrollTarget)
//                            }
                            .navigationTitle("Searching")
                            .onHover { isHovering in
                                if isHovering {
                                    selectedCue = cue
                                } else {
                                    selectedCue = nil
                                }
                            }
                            .contextMenu {
                                Button("Delete row") {
                                    document.deleteItem(withID: cue.id, undoManager: undoManager)
                                }
                            }
                        }
                        .onDelete(perform: onDelete)
                    }
                    .frame(minWidth: 310, maxWidth: 400)
                    .onChange(of: scrollTarget) { target in
                        if let target = target {
                            scrollTarget = nil

                            withAnimation {
                                proxy.scrollTo(target, anchor: .top)
                            }
                        }
                    }
                    .onChange(of: searchText) { newValue in
                        if searchText.isEmpty {
                            searchResults = []
                        } else {
                            searchResults = document.captions.cues.filter { $0.text.lowercased().contains(searchText.lowercased())}
                        }
                    }
                }
            }
            PlayerView()
        }
        .toolbar {
            ToolbarView(captions: $document.captions, scrollTarget: $scrollTarget)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
            playerController.player?.pause()
            playerController.player = nil
        }
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
