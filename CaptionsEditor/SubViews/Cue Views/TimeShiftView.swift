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
    
    var buttonPadding: CGFloat = 4.0
    
    var shiftAllSymbol: String {
        "circle.grid.2x2.fill"
    }
    
    var shiftOne: String {
        start ? "circle.grid.2x1.left.filled" : "circle.grid.2x1.right.filled"
    }
    
    var shiftBoth: String {
        "circle.grid.2x1.fill"
    }
    
    var endAndStart: String {
        "arrow.up.left.and.arrow.down.right"
    }
    
    var shiftToPlayhead: String {
        "timeline.selection"
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
                    if CGKeyCode.optionKeyPressed && CGKeyCode.commandKeyPressed {
                        shiftValue -= 60.0
                    } else if CGKeyCode.optionKeyPressed {
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
                    if CGKeyCode.optionKeyPressed && CGKeyCode.commandKeyPressed {
                        shiftValue += 60.0
                    } else if CGKeyCode.optionKeyPressed {
                        shiftValue += 1.0
                    } else {
                        shiftValue += 0.1
                    }
                } label: {
                    Image(systemName: "arrow.right.circle")
                }
                .buttonStyle(.borderless)
                Spacer()
                HStack(spacing: 0)  {
                    // Shift all remaining
                    Button {
                        document.shiftTimeValues(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
                        showPopover = false
                    } label: {
                        Image(systemName: shiftAllSymbol)
                            .padding([.leading, .trailing], buttonPadding)
                    }
                        .disabled(Int(shiftValue * 1000) == 0)
                        .buttonStyle(.borderless)
                        .help("Shift \(start ? "start" : "end") of current cue and remaining...")
                    
                    Divider()
                    
                    // Shift One
                    Button {
                        document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
                        showPopover = false
                    } label: {
                        Image(systemName: shiftOne)
                            .padding([.leading, .trailing], buttonPadding)
                    }
                        .disabled(Int(shiftValue * 1000) == 0)
                        .buttonStyle(.borderless)
                        .help("Shift \(start ? "start" : "end") of current cue only")
                    
                    Divider()
                    
                    // Shift Both
                    Button {
                        document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: nil, undoManager: undoManager)
                        showPopover = false
                    } label: {
                        HStack {
                            Image(systemName: shiftBoth)
                                .padding(0)
                        }
                        .padding([.leading, .trailing], buttonPadding)
                    }
                        .disabled(Int(shiftValue * 1000) == 0)
                        .buttonStyle(.borderless)
                        .help("Shift both start and end of current cue")
                    if !start {
                        Divider()
                        // Shift end and start of next
                        Button {
                            document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: false, undoManager: undoManager)
                            let cueIndex = document.captions.getIndex(forCueID: cue.id)
                            let nextIndex = cueIndex + 1
                            let nextCue = document.captions.cues[nextIndex]
                            document.shiftTime(withValue: shiftValue, atCueWithId: nextCue.id, start: true, undoManager: undoManager)
                            showPopover = false
                        } label: {
                            Image(systemName: endAndStart)
                                .padding(0)
                                .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
                                .padding([.leading, .trailing], buttonPadding)
                        }
                        .disabled(Int(shiftValue * 1000) == 0)
                        .buttonStyle(.borderless)
                        .help("Shift end of current cue and start of next")
                    }
                    
                    Divider()
                    
                    // Shift To Playhead
                    Button {
                        print("Shift to playhead")
                    } label: {
                        HStack {
                            Image(systemName: shiftToPlayhead)
                                .padding(0)
                        }
                        .padding([.leading, .trailing], buttonPadding)
                    }
                        .buttonStyle(.borderless)
                        .help("Shift to playhead of video")
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary.opacity(0.5), lineWidth: 1)
                )

//                    .contextMenu {
//                        Section {
//                            Text("Shift \(isPositive ? "forward" : "backward")")
//                            Button("\(start ? "start" : "end") and remaining…") {
//                                document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
//                                showPopover = false
//                            }
//                        }
//                        
//                        Section {
//                            Button("\(start ? "start" : "end") only") {
//                                document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: start, undoManager: undoManager)
//                                showPopover = false
//                            }
//                            Button("both") {
//                                document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: nil, undoManager: undoManager)
//                                showPopover = false
//                            }
//                            if !start {
//                                Button("end and start of next") {
//                                    document.shiftTime(withValue: shiftValue, atCueWithId: cue.id, start: false, undoManager: undoManager)
//                                    let cueIndex = document.captions.getIndex(forCueID: cue.id)
//                                    let nextIndex = cueIndex + 1
//                                    let nextCue = document.captions.cues[nextIndex]
//                                    document.shiftTime(withValue: shiftValue, atCueWithId: nextCue.id, start: true, undoManager: undoManager)
//                                    showPopover = false
//                                }
//                            }
//                        }
//                    }
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
