//
//  SearchView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchResults: [Cue]
    @Binding var scrollTarget: UUID?
    
    var body: some View {
         ScrollView {
             VStack {
                 ForEach($searchResults) { $searchCue in
                     VStack {
//                         HStack {
//                             Text("\(String(searchCue.timings.startTime))")
//                                 .font(Font.system(size: 12, design: .monospaced))
//                                 .fontWeight(.light)
//                         }
                         HStack {
                             Text(searchCue.text)
                             Spacer()
                         }
                             .padding(5)
                         Divider()
                     }
                     .onTapGesture {
                         print("Scroll to \(searchCue.id)")
                         scrollTarget = searchCue.id
                     }
                 }
             }
         }
     }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
