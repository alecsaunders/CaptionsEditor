//
//  TimeShiftView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/30/23.
//

import SwiftUI

struct TimeShiftView: View {
    @Binding var document: CaptionsEditorDocument
    @Binding var cue: Cue
    @State var shiftValue: Double = 0.0
    var start: Bool
    @Binding var showPopover: Bool
    var isPositive: Bool {
        Int(shiftValue * 10.0) >= 0
    }
    var shiftSymbol: String {
        isPositive ? ">>" : "<<"
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                Text("New \(start ? "Start" : "End") Time: ")
                Text(String(Timestamp(start ? cue.startTimestamp.value : cue.endTimestamp.value + shiftValue)))
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
                Text("\(isPositive ? "+" : "-")\(String(format: "%.2f", abs(shiftValue)))")
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
                Spacer()

                ControlGroup {
                    Button(shiftSymbol) {
                        document.captions.shiftTimestamps(withValue: shiftValue, atCueWithId: cue.id, start: start)
                        showPopover = false
                    }
                        .disabled(Int(shiftValue * 1000) == 0)
                    Menu("") {
                        Text("Shift \(isPositive ? "forward" : "backward")")
                        Button("\(start ? "start" : "end") and remaining…") {
//                            shiftAllRemainingTimestamps()
//                            shiftControlOpts.resetOptions()
                            showPopover = false
                        }
                        Divider()
                        Button("\(start ? "start" : "end") only") {
//                            self.shiftSingleTimestamp()
//                            shiftControlOpts.resetOptions()
                            showPopover = false
                        }
                        Button("both") {
//                            self.shiftBothTimestamps()
//                            shiftControlOpts.resetOptions()
                            showPopover = false
                        }
                    }
                        .disabled(Int(shiftValue * 1000) == 0)
                }
                    .frame(minWidth: 50)
            }
        }
            .padding()
    }
}

struct TimeShiftView_Previews: PreviewProvider {
    static var previews: some View {
        TimeShiftView(document: .constant(CaptionsEditorDocument()), cue: .constant(Cue()), start: true, showPopover: .constant(false))
    }
}
