//
//  CueRow.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct CueRow: View {
    @Binding var cue: Cue
    var body: some View {
        VStack {
            HStack {
                cueIdPlayButton(cue: $cue)
                TimestampView(cue: $cue)
            }
            TextField("\(cue.id)", text: $cue.text)
                .textFieldStyle(.plain)
            Divider()
        }
    }
}

struct CueRow_Previews: PreviewProvider {
    static var previews: some View {
        CueRow(cue: .constant(Cue()))
    }
}
