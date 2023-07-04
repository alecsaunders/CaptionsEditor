//
//  SearchView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Binding var searchResults: [Cue]
    @Binding var scrollTarget: UUID?
    
    var body: some View {
         ForEach($searchResults) { $searchCue in
             VStack {
                 Text(searchCue.startTimestamp.stringValue)
                     .font(Font.system(size: 12, design: .monospaced))
                     .fontWeight(.light)
                 HStack {
                     Text(searchCue.text)
                     Spacer()
                 }
                 Divider()
             }
                .onTapGesture {
                    scrollTarget = searchCue.id
                    dismissSearch()
                }
         }
     }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
