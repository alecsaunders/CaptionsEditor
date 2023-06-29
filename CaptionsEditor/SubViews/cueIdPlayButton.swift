//
//  cueIdPlayButton.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct cueIdPlayButton: View {
    @Binding var cue: Cue
    var body: some View {
        Text(cue.cueId ?? "no id")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            .frame(width: 30, alignment: .leading)
    }
}

struct cueIdPlayButton_Previews: PreviewProvider {
    static var previews: some View {
        cueIdPlayButton(cue: .constant(Cue()))
    }
}
