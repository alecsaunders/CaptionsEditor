//
//  cueIdPlayButton.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct CueIdPlayButton: View {
    @EnvironmentObject var playerController: PlayerController
    @Binding var cue: Cue
    @Binding var selectedCue: Cue?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 1.5) {
            Text(verbatim: "\(cue.cueId)")
                .font(.system(size: 12).monospacedDigit())
                .foregroundColor(.secondary)
            Label("", systemImage: "play.circle")
                .foregroundColor(cue.cueId == selectedCue?.cueId ? Color.blue : Color.clear)
        }
            .onTapGesture {
                playerController.jumpToPosition(atTimestamp: cue.startTimestamp.value)
            }
    }
}

struct cueIdPlayButton_Previews: PreviewProvider {
    static var previews: some View {
        CueIdPlayButton(cue: .constant(Cue()), selectedCue: .constant(nil))
    }
}
