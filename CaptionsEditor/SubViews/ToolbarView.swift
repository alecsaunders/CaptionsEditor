//
//  ToolbarView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var playerController: PlayerController
    
    var body: some View {
        Button {
            playerController.loadPlayer()
        } label: {
            Image(systemName: "arrow.clockwise")
        }
            .keyboardShortcut("r", modifiers: .command)
        Button {
            playerController.chooseVideoURL()
        } label: {
            Label("Load Movie", systemImage: "film")
        }
            .buttonStyle(.bordered)
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView()
    }
}
