//
//  PlayerController.swift
//  CaptionsEditor
//
//  Created by Alec Saunders on 6/29/23.
//

import Foundation
import AVKit


final class PlayerController: ObservableObject {
    @Published var player: AVPlayer?
    var videoURL: URL?
    var subsURL: URL?
    private var mix: AVMutableComposition = AVMutableComposition()

    func chooseVideoURL() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.video, .mpeg4Movie, .mpeg2Video]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if panel.runModal() == .OK {
            if let fileUrl = panel.url {
                self.videoURL = fileUrl
                Task {
                    await self.loadPlayer()
                }
            }
        }
    }

    func loadPlayer() async {
        if let thePlayer = player {
            let currentTime = thePlayer.currentTime()
            let isPlaying = thePlayer.rate > 0
            thePlayer.pause()

            let textTrack = mix.tracks(withMediaType: .text)[0]
            mix.removeTrack(textTrack)

            Task {
                await addSubtitleTrackToMix(withDuration: thePlayer.currentItem!.duration)
            }

            let playerItem = AVPlayerItem(asset: mix)
            thePlayer.replaceCurrentItem(with: playerItem)

            self.jumpToPosition(atTimestamp: currentTime.seconds)
            if isPlaying {
                thePlayer.play()
            }
        } else {
            guard let videoURL = self.videoURL else { return }

            mix = AVMutableComposition()

            // 1 - Video Track
            let videoAsset = AVURLAsset(url: videoURL)
            let videoTrack = mix.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try await videoTrack?.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoAsset.load(.duration)),
                    of: videoAsset.loadTracks(withMediaType: .video)[0], at: .zero)
            } catch {
                print(error)
            }

            // 2 - Audio track
            let audioTrack = mix.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try await audioTrack?.insertTimeRange(
                    CMTimeRange(start: .zero, duration: videoAsset.load(.duration)),
                    of: videoAsset.loadTracks(withMediaType: .audio)[0], at: .zero)
            } catch {
                print(error)
            }

            // 3 - Subtitle track
            Task {
                do {
                    try await addSubtitleTrackToMix(withDuration: videoAsset.load(.duration))
                }
            }

            // 4 - Set up player
            let playerItem = AVPlayerItem(asset: mix)

            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: playerItem)
            }
        }
    }

    private func addSubtitleTrackToMix(withDuration: CMTime) async {
        if let subsURL = subsURL {
            let subtitleAsset = AVURLAsset(url: subsURL)
            let subtitleTrack = mix.addMutableTrack(withMediaType: .text, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try await subtitleTrack?.insertTimeRange(
                    CMTimeRange(start: .zero, duration: withDuration),
                    of: subtitleAsset.loadTracks(withMediaType: .text)[0], at: .zero)
            } catch {
                print(error)
            }
        }
    }

    func jumpToPosition(atTimestamp timestampValue: Double) {
        if let thePlayer = player {
            thePlayer.seek(to:  CMTime(value: Int64(timestampValue * 1000 - 500), timescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
            if thePlayer.rate == 0 {
                thePlayer.play()
            }
        }
    }
}
