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
    @State var slowMotion: Bool = false
    
    var body: some View {
        Button {
            if let targetCue = captions.cue(atTime: playerController.currentTime) {
                scrollTarget = targetCue.id
            }
        } label: {
            Image(systemName: "arrow.right.to.line")
        }
            .help("Scroll to nearest subtitle at playhead")
        Button {
            slowMotion.toggle()
            if slowMotion {
                playerController.playerRate = 0.4
            } else {
                playerController.playerRate = 1.0
            }
        } label: {
            Label("Slow", systemImage: slowMotion ? "play.fill" : "tortoise.fill")
        }
            .help("Play in slow motion")
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
