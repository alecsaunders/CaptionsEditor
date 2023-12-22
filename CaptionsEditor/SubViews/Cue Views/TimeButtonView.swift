//
//  TimeButtonView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct TimeButtonView: View {
    @Binding var cue: Cue
    @Binding var showPopover: Bool
    @Binding var shiftControls: ShiftControls
    let start: Bool
    
    var body: some View {
        Button {
            showPopover = true
            shiftControls.start = start
        } label: {
            Text(start ? cue.startTimestamp.stringValue : cue.endTimestamp.stringValue)
                .font(.system(size: 13).monospacedDigit())
                .foregroundColor(start ? cue.isOverlapPrev ? .red : .none : .none)
        }
            .buttonStyle(.borderless)
    }
}

struct TimeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TimeButtonView(cue: .constant(Cue()), showPopover: .constant(false), shiftControls: .constant(ShiftControls()), start: true)
    }
}
