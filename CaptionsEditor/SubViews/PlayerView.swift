//
//  PlayerView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    @EnvironmentObject var playerController: PlayerController
    
    var body: some View {
        return VStack {
            if let player = playerController.player {
                VideoPlayer(player: player)
            } else {
                Color.black
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
