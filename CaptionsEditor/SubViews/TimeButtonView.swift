//
//  TimeButtonView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct TimeButtonView: View {
    @Binding var cue: Cue
    let start: Bool
    var body: some View {
        Button {
            print("button")
        } label: {
            Text(start ? cue.startTimestamp.stringValue : cue.endTimestamp.stringValue)
                .font(.system(size: 13).monospacedDigit())
        }
            .buttonStyle(.borderless)
    }
}

struct TimeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TimeButtonView(cue: .constant(Cue()), start: true)
    }
}
