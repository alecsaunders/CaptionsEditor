//
//  cueIdPlayButton.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct CueIdPlayButton: View {
    @Binding var cue: Cue
    @Binding var selectedCue: Cue?
    var body: some View {
        HStack(alignment: .bottom, spacing: 1.5) {
            Text(cue.cueId ?? "no id")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Label("", systemImage: "play.circle")
                .foregroundColor(cue.cueId == selectedCue?.cueId ? Color.blue : Color.clear)
        }
            .onSubmit {
                print("on submit")
            }
            .onTapGesture {
                print("on tap")
            }
            .frame(width: 55, height: 16, alignment: .leading)
    }
}

struct cueIdPlayButton_Previews: PreviewProvider {
    static var previews: some View {
        CueIdPlayButton(cue: .constant(Cue()), selectedCue: .constant(nil))
    }
}
