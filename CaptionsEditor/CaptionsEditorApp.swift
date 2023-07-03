//
//  CaptionsEditorApp.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

@main
struct CaptionsEditorApp: App {
    @StateObject private var playerController = PlayerController()
    var body: some Scene {
        DocumentGroup(newDocument: { CaptionsEditorDocument() }) { configuration in
            ContentView()
                .onAppear() {
                    playerController.subsURL = configuration.fileURL
                }
                .environmentObject(playerController)
        }
        .commands {
            CommandMenu("Find") {
                Button("Find") {
                    if let toolbar = NSApp.keyWindow?.toolbar,
                        let search = toolbar.items.first(where: { $0.itemIdentifier.rawValue == "com.apple.SwiftUI.search" }) as? NSSearchToolbarItem {
                        search.beginSearchInteraction()
                    }
                }.keyboardShortcut("f", modifiers: .command)
            }
        }
    }
}
