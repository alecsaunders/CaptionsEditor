//
//  TimestampView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct TimestampView: View {
    @Binding var cue: Cue
    var body: some View {
        HStack(spacing: 4.0) {
            TimeButtonView(cue: $cue, start: true)
            Text("-->")
            TimeButtonView(cue: $cue, start: false)
        }
    }
}

struct TimestampView_Previews: PreviewProvider {
    static var previews: some View {
        TimestampView(cue: .constant(Cue()))
    }
}
