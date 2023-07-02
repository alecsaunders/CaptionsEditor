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
        DocumentGroup(newDocument: CaptionsEditorDocument()) { configuration in
            ContentView(document: configuration.$document)
                .onAppear() {
                    playerController.subsURL = configuration.fileURL
                }
                .environmentObject(playerController)
        }
        .windowToolbarStyle(.unified(showsTitle: false))
    }
}
