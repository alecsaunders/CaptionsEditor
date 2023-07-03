//
//  FullTextView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 7/2/23.
//

import SwiftUI

struct FullTextView: View {
    @Binding var showTextEditorPopover: Bool
    /// The document that the environment stores.
    @EnvironmentObject var document: CaptionsEditorDocument
    
    var body: some View {
        VStack {
            TextEditor(text: $document.text)
            Divider()
            Button("Done") {
                showTextEditorPopover = false
            }
        }
        .frame(minWidth: 450)
            .padding()  
    }
}

struct FullTextView_Previews: PreviewProvider {
    static var previews: some View {
        FullTextView(showTextEditorPopover: .constant(false))
    }
}
