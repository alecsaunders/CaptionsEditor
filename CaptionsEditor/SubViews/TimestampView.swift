//
//  TimestampView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct TimestampView: View {
    @Binding var cue: Cue
    @Binding var showPopover: Bool
    @Binding var shiftControls: ShiftControls
    
    var body: some View {
        HStack(spacing: 4.0) {
            TimeButtonView(cue: $cue, showPopover: $showPopover, shiftControls: $shiftControls, start: true)
            Text("-->")
            TimeButtonView(cue: $cue, showPopover: $showPopover, shiftControls: $shiftControls, start: false)
        }
    }
}

struct TimestampView_Previews: PreviewProvider {
    static var previews: some View {
        TimestampView(cue: .constant(Cue()), showPopover: .constant(false), shiftControls: .constant(ShiftControls()))
    }
}
