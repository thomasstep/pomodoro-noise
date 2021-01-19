//
//  Noises.swift
//  Pomodoro Noise
//
//  Created by Thomas Step on 11/5/20.
//

import Foundation
import AVFoundation

enum NoiseTypes: String {
    case brown
    case white
    case pink
    
    var id: String { self.rawValue }
}

//var player: AVAudioPlayer?
enum MyError: Error {
    case runtimeError(String)
}

var player: AVAudioPlayer?

class NoisePlayer {
    func playSound( noise: String ) {
        guard let url = Bundle.main.url(forResource: noise, withExtension: "mp3") else { return }        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            // Set infinite repeat until stop is called
            player.numberOfLoops = -1
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func pauseSound() {
        guard let player = player else { return }
        player.pause()
    }
    
    func resumeSound() {
        guard let player = player else { return }
        player.play()
    }
    
    func stopSound() {
        guard let player = player else { return }
        player.stop()
    }
}
