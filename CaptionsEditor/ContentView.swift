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
    @State var showTextEditorPopover: Bool = false

    var body: some View {
        NavigationSplitView {
            ScrollView {
                ScrollViewReader { (proxy: ScrollViewProxy) in
                    LazyVStack {
                        ForEach($document.captions.cues, id: \.self) { $cue in
                            CueRow(cue: $cue, selectedCue: $selectedCue, tempText: TempText(text: cue.text)) { oldText in
                                document.registerUndoTextChange(for: $cue.wrappedValue, oldText: oldText, undoManager: undoManager)
                            }
                            .id(cue.id)
                            .listStyle(.sidebar)
                            .onHover { isHovering in
                                if isHovering {
                                    selectedCue = cue
                                } else {
                                    selectedCue = nil
                                }
                            }
                        }
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
                }
            }
            .toolbar {
                ToolbarItemGroup{
                    Spacer()
                    ToolbarSidebarView(showTextEditorPopover: $showTextEditorPopover)
                }
            }
            .searchable(text: $searchText, prompt: "Search...") {
                SearchView(searchResults: $searchResults, scrollTarget: $scrollTarget)
            }
        } detail: {
            PlayerView()
                .toolbar {
                    ToolbarView(captions: $document.captions, scrollTarget: $scrollTarget)
                }
        }
        .onChange(of: searchText) { newValue in
            if searchText.isEmpty {
                searchResults = []
            } else {
                if searchText.count >= 2 {
                    searchResults = document.captions.cues.filter { $0.text.lowercased().contains(searchText.lowercased())}
                } else {
                    searchResults = []
                }
            }
        }
        .sheet(isPresented: $showTextEditorPopover) {
            FullTextView(showTextEditorPopover: $showTextEditorPopover)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { newValue in
            playerController.player?.pause()
            playerController.player = nil
        }
    }
}
