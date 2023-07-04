//
//  ToolbarSidebarView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 7/3/23.
//

import SwiftUI

struct ToolbarSidebarView: View {
    @EnvironmentObject var playerController: PlayerController
    @Binding var showTextEditorPopover: Bool
    
    var body: some View {
        Button {
            Task {
                await playerController.loadPlayer()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
        }
            .keyboardShortcut("r", modifiers: .command)
        Button {
            showTextEditorPopover = true
        } label: {
            Image(systemName: "doc.text")
        }
    }
}

//struct ToolbarSidebarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToolbarSidebarView()
//    }
//}
