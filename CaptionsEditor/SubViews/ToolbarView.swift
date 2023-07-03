    //
//  ToolbarView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var playerController: PlayerController
    @Binding var captions: Captions
    @Binding var scrollTarget: UUID?
    @Binding var showTextEditorPopover: Bool
    
    var body: some View {
        Button {
            if let targetCue = captions.cue(atTime: playerController.player?.currentItem?.currentTime()) {
                scrollTarget = targetCue.id
            }
        } label: {
            Image(systemName: "arrow.right.to.line")
        }
        Button {
            Task {
                await playerController.loadPlayer()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
            .keyboardShortcut("r", modifiers: .command)
        Button {
            showTextEditorPopover = true
        } label: {
            Image(systemName: "doc.text")
        }
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
        ToolbarView(captions: .constant(Captions(fromText: "")), scrollTarget: .constant(UUID()), showTextEditorPopover: .constant(false))
    }
}
