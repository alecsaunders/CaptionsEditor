//
//  PlayerView.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    @Binding var playerController: PlayerController
    
    var body: some View {
        VStack {
            VideoPlayer(player: playerController.player != nil ? playerController.player! : AVPlayer())
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(playerController: .constant(PlayerController()))
    }
}
