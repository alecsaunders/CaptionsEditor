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
    
    var body: some View {
        Button {
            if let targetCue = captions.cue(atTime: playerController.player?.currentItem?.currentTime()) {
                scrollTarget = targetCue.id
            }
        } label: {
            Image(systemName: "arrow.right.to.line")
        }
            .help("Scroll to nearest subtitle at playhead")
        Button {
            playerController.chooseVideoURL()
        } label: {
            Label("Load Movie", systemImage: "film")
        }
            .help("Load movie from file")
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView(captions: .constant(Captions(fromText: "")), scrollTarget: .constant(UUID()))
    }
}
