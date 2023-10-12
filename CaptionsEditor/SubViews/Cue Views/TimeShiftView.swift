//
//  TimeShiftView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/30/23.
//

import SwiftUI

struct TimeShiftView: View {
    @EnvironmentObject var document: CaptionsEditorDocument
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
    
    /// The undo manager that the environment stores.
    /// - Tag: UndoManager
    @Environment(\.undoManager) var undoManager
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                Text("New \(start ? "Start" : "End") Time: ")
                Text(String(Timestamp((start ? cue.startTimestamp.value : cue.endTimestamp.value) + shiftValue)))
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
                        document.shiftTimeValues(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
                        showPopover = false
                    }
                    Menu("") {
                        Text("Shift \(isPositive ? "forward" : "backward")")
                        Button("\(start ? "start" : "end") and remaining…") {
                            document.shiftTimeValues(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
                            showPopover = false
                        }
                        Divider()
                        Button("\(start ? "start" : "end") only") {
                            document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
                            showPopover = false
                        }
                        Button("both") {
                            document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: nil, undoManager: undoManager)
                            showPopover = false
                        }
                        if !start {
                            Button("end and start of next") {
                                document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: false, undoManager: undoManager)
                                let nextIndex = document.captions.getIndex(forCueID: cue.id) + 1
                                let nextCue = document.captions.cues[nextIndex]
                                document.shiftTime(withValue: shiftValue, atCueWithId: nextCue.id, start: true, undoManager: undoManager)
                                showPopover = false
                            }
                        }
                    }
                }
                    .frame(minWidth: 50)
                    .disabled(Int(shiftValue * 1000) == 0)
            }
        }
            .padding()
    }
}

struct TimeShiftView_Previews: PreviewProvider {
    static var previews: some View {
        TimeShiftView(cue: .constant(Cue()), start: true, showPopover: .constant(false))
    }
}
