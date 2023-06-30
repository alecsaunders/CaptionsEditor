//
//  TimeShiftView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/30/23.
//

import SwiftUI

struct TimeShiftView: View {
    @Binding var cue: Cue
    @State var shiftValue: Double = 0.0
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                Text("New Time: ")
                Text(String(Timestamp(cue.startTimestamp.value + shiftValue)))
                    .font(.system(size: 13).monospacedDigit())
            }
            Divider()
            HStack {
                Button {
                    if CGKeyCode.optionKeyPressed {
                        shiftValue -= 1.0
                    } else {
                        shiftValue -= 0.1
                    }
                } label: {
                    Image(systemName: "arrow.left.circle")
                }
                .buttonStyle(.borderless)
                Text("\(Int(shiftValue * 10.0) >= 0 ? "+" : "-")\(String(format: "%.2f", abs(shiftValue)))")
                    .font(.system(size: 14).monospacedDigit())
                Button {
                    if CGKeyCode.optionKeyPressed {
                        shiftValue += 1.0
                    } else {
                        shiftValue += 0.1
                    }
                } label: {
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(.borderless)
            }
        }
            .padding()
    }
}

struct TimeShiftView_Previews: PreviewProvider {
    static var previews: some View {
        TimeShiftView(cue: .constant(Cue()))
    }
}
