//
//  TimestampView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct TimestampView: View {
    @Binding var cue: Cue
    @Binding var showTimePopover: Bool
    
    var body: some View {
        HStack(spacing: 4.0) {
            TimeButtonView(cue: $cue, showTimePopover: $showTimePopover, start: true)
            Text("-->")
            TimeButtonView(cue: $cue, showTimePopover: $showTimePopover, start: false)
        }
    }
}

struct TimestampView_Previews: PreviewProvider {
    static var previews: some View {
        TimestampView(cue: .constant(Cue()), showTimePopover: .constant(false))
    }
}
