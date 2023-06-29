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
    @FocusState private var isTitleFieldFocused: Bool
    
    var onTextCommit: (_ oldText: String) -> Void
    
    @State private var oldText: String = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CueIdPlayButton(cue: $cue, selectedCue: $selectedCue)
                    TimestampView(cue: $cue)
                }
                TextField("\(cue.id)", text: $cue.text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .focused($isTitleFieldFocused)
                    .onChange(of: isTitleFieldFocused) { newValue in
                        if isTitleFieldFocused {
                            // The TextField is now focused.
                            oldText = cue.text
                        }
                    }
                    .onSubmit {
                        // The commit handler registers an undo action using the old title.
                        onTextCommit(oldText)
                    }
            }
            .padding([.top, .leading, .trailing], 4)
            .padding([.bottom], 10)
            .background(cue.id == selectedCue?.id ? Color.secondary.opacity(0.07) : Color.clear)
                .cornerRadius(7)
            Divider()
        }
    }
}

struct CueRow_Previews: PreviewProvider {
    
    // Define a shim for the preview of ChecklistRow.
    struct RowContainer: View {
        @StateObject private var document = CaptionsEditorDocument()

        var body: some View {
            CueRow(cue: .constant(Cue()), selectedCue: .constant(nil)) { oldText in
                
            }
        }
    }
    
    static var previews: some View {
        RowContainer()
    }
}
