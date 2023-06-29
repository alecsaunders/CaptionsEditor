//
//  CueRow.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/28/23.
//

import SwiftUI

struct CueRow: View {
    @Binding var cue: Cue
    @FocusState private var isTitleFieldFocused: Bool
    
    var onTextCommit: (_ oldText: String) -> Void
    
    @State private var oldText: String = ""
    
    var body: some View {
        VStack {
            HStack {
                CueIdPlayButton(cue: $cue)
                TimestampView(cue: $cue)
            }
            TextField("\(cue.id)", text: $cue.text)
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
            Divider()
        }
    }
}

struct CueRow_Previews: PreviewProvider {
    
    // Define a shim for the preview of ChecklistRow.
    struct RowContainer: View {
        @StateObject private var document = CaptionsEditorDocument()

        var body: some View {
            CueRow(cue: .constant(Cue())) { oldText in
                
            }
        }
    }
    
    static var previews: some View {
        RowContainer()
    }
}
