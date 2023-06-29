//
//  PlayerController.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import Foundation
import AVKit


class PlayerController: ObservableObject {
    @Published var player: AVPlayer?
    var URL: URL?
    
    func chooseVideoURL() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.video, .mpeg4Movie, .mpeg2Video]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            if let fileUrl = panel.url {
                self.URL = fileUrl
                self.loadPlayer()
            }
        }
    }
    
    func loadPlayer() {
        guard let videoURL = self.URL else { return }

        let mixComposition = AVMutableComposition()

        // 1 - Video Track
        let videoAsset = AVURLAsset(url: videoURL)
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
        } catch {
            print(error)
        }

        // 2 - Audio track
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: .zero)
        } catch {
            print(error)
        }

//        // 3 - Subtitle track
//        let subtitleAsset = AVURLAsset(url: subsUrl)
//        let subtitleTrack = mixComposition.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)
//        do {
//            try subtitleTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: subtitleAsset.tracks(withMediaType: .text)[0], at: .zero)
//        } catch {
//            print(error)
//        }

        // 4 - Set up player
        let playerItem = AVPlayerItem(asset: mixComposition)

        player = AVPlayer(playerItem: playerItem)
    }
    
    func jumpToPosition(atTimestamp timestamp: Double) {
        player?.seek(to:  CMTime(value: Int64(500 * 1000), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
