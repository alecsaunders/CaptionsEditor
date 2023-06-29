//
//  CaptionsEditorApp.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

@main
struct CaptionsEditorApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { CaptionsEditorDocument() }) { configuration in
            ContentView(file: configuration)
        }
    }
}
