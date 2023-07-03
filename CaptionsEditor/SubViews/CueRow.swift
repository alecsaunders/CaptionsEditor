//
//  CueRow.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct CueRow: View {
    @Binding var cue: Cue
    @Binding var selectedCue: Cue?
    @State var tempText: String
    @State var showTimePopover: Bool = false
    @State var showPopover: Bool = false
    @State var shiftControls: ShiftControls = ShiftControls()
    @FocusState private var isTextFieldFocused: Bool
    
    var onTextCommit: (_ oldText: String) -> Void
    
    @State private var oldText: String = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    CueIdPlayButton(cue: $cue, selectedCue: $selectedCue)
                    TimestampView(cue: $cue, showPopover: $showPopover, shiftControls: $shiftControls)
                }
                TextField("", text: $tempText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(3)
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { newValue in
                        if isTextFieldFocused {
                            // The TextField is now focused.
                            if cue.text != tempText {
                                onTextCommit(cue.text)
                            }
                            cue.text = tempText
                        }
                    }
                    .onSubmit {
                        // The commit handler registers an undo action using the old title.
                        if cue.text != tempText {
                            onTextCommit(cue.text)
                        }
                        cue.text = tempText
                        isTextFieldFocused = false
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidEndEditingNotification)) { obj in
                        isTextFieldFocused = false
                    }
            }
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 6)
                .background(cue.id == selectedCue?.id ? Color.secondary.opacity(0.07) : Color.clear)
                .cornerRadius(7)
                .padding([.leading, .trailing], 6)
                .popover(isPresented: $showPopover, attachmentAnchor: .point(UnitPoint(x: shiftControls.start ? 0.32 : 0.67, y: UnitPoint.top.y))) {
                    TimeShiftView(cue: $cue, start: shiftControls.start, showPopover: $showPopover)
                }
            Divider()
        }
    }
}

struct CueRow_Previews: PreviewProvider {
    
    // Define a shim for the preview of ChecklistRow.
    struct RowContainer: View {
        @State private var document = CaptionsEditorDocument()

        var body: some View {
            CueRow(cue: .constant(Cue()), selectedCue: .constant(nil), tempText: "temp text") { oldText in

            }
        }
    }
    
    static var previews: some View {
        RowContainer()
    }
}
