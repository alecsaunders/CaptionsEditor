//
//  CueRow.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI


struct TempText: Equatable {
    var text: String
    
    static func == (lhs: TempText, rhs: TempText) -> Bool {
        lhs.text == rhs.text
    }
}

struct CueRow: View {
    @EnvironmentObject var document: CaptionsEditorDocument
    @Environment(\.undoManager) var undoManager
    @Binding var cue: Cue
    @Binding var selectedCue: Cue?
    @State var showTimePopover: Bool = false
    @State var showPopover: Bool = false
    @State var showAddPopover: Bool = false
    @State var shiftControls: ShiftControls = ShiftControls()
    @State var oldText: String
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    CueIdPlayButton(cue: $cue, selectedCue: $selectedCue)
                    TimestampView(cue: $cue, showPopover: $showPopover, shiftControls: $shiftControls)
                    Spacer()
                    // FIXME: Use popover
                    // Have to use popover instead of a Menu, which looks and acts cleaner
                    // When using a menu, every time an item is selected get an "AttributeGraph" error
                    // and the video player gets removed, so that you have to re-select a video
                    Button {
                        cue.runCueRulesValidation()
                        showAddPopover = true
                    } label: {
                        Label("", systemImage: "chevron.down")
                    }
                        .foregroundStyle(cue == selectedCue ? .primary : Color.clear)
                        .buttonStyle(.borderless)
                        .popover(isPresented: $showAddPopover, arrowEdge: .bottom) {
                            VStack(alignment: .leading) {
                                Button("Add cue above...") {
                                    document.addItem(atIndex: cue.cueId - 1, undoManager: undoManager)
                                    showAddPopover = false
                                }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(.borderless)
                                Button("Add cue below...") {
                                    document.addItem(atIndex: cue.cueId, undoManager: undoManager)
                                    showAddPopover = false
                                }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(.borderless)
                                Divider()
                                Button("Delete cue") {
                                    document.deleteItem(withID: cue.id, undoManager: undoManager)
                                    showAddPopover = false
                                }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(.borderless)
                                Divider()
                                Button(cue.text.contains("<i>") ? "Remove italics" : "Italicize text") {
                                    if cue.text.contains("<i>") {
                                        cue.text.replace("<i>", with: "")
                                        cue.text.replace("</i>", with: "")
                                    } else {
                                        cue.text = "<i>\(cue.text)</i>"
                                    }
                                    isTextFieldFocused = false
                                    document.registerUndoTextChange(withOldValue: oldText, atCueWithId: cue.id, undoManager: undoManager)
                                    oldText = cue.text
                                    showAddPopover = false
                                }
                                    .foregroundStyle(.primary)
                                    .buttonStyle(.borderless)
                                if !cue.validationErrors.isEmpty {
                                    Divider()
                                    Text("Errors:")
                                        .foregroundStyle(.red)
                                        .bold()
                                    ForEach(cue.validationErrors) {valErr in
                                        HStack {
                                            Text("-")
                                            Text(valErr.description)
                                        }
                                        
                                    }
                                }
                            }
                                .padding()
                        }
                }
                .padding([.leading, .trailing])
                TextField("", text: $cue.text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(3)
                    .focused($isTextFieldFocused)
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isTextFieldFocused ? Color.secondary.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
                    .background(isTextFieldFocused ? Color.secondary.opacity(0.1) : Color.clear)
                    .padding([.leading, .trailing], 10)
                    .onAppear {
                        self.isTextFieldFocused = false
                    }
                    .onDisappear() {
                        self.isTextFieldFocused = false
                    }
                    .onSubmit {
                        isTextFieldFocused = false
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: NSTextField.textDidEndEditingNotification)) { obj in
                            isTextFieldFocused = false
                            if cue.text != oldText {
                                formatCueText()
                                document.registerUndoTextChange(withOldValue: oldText, atCueWithId: cue.id, undoManager: undoManager)
                                oldText = cue.text
                            }
                    }
            }
                .padding([.top, .bottom], 6)
                .background(cue.validationErrors.isEmpty ? .clear : Color.red.opacity(0.25))
                .cornerRadius(7)
                .popover(isPresented: $showPopover, attachmentAnchor: .point(UnitPoint(x: shiftControls.start ? 0.32 : 0.67, y: UnitPoint.top.y))) {
                    TimeShiftView(cue: $cue, start: shiftControls.start, showPopover: $showPopover)
                }
            Divider()
        }
    }
    
    func calculateBackground() -> Color {
        if cue.isOverlapPrev {
            return Color.red.opacity(0.25)
        }
        else if !cue.validationErrors.isEmpty {
            return Color.red.opacity(0.25)
        }
        else if cue.id == selectedCue?.id {
            return Color.secondary.opacity(0.07)
        }
        return Color.clear
    }
    
    func formatCueText() {
        if cue.text.contains("...") {
            cue.text = cue.text.replacing("...", with: "…")
        }
        cue.text = cue.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CueRow_Previews: PreviewProvider {
    
    // Define a shim for the preview of ChecklistRow.
    struct RowContainer: View {
        @State private var document = CaptionsEditorDocument()

        var body: some View {
            CueRow(cue: .constant(Cue()), selectedCue: .constant(nil), oldText: "")
        }
    }
    
    static var previews: some View {
        RowContainer()
    }
}
