//
//  AVController.swift
//  PlayerFitness
//
//  Created by MAC on 06/02/2024.
//

import UIKit
import AVFoundation
import AudioUnit

class VietPlayer: AVPlayer {
    
    override var isExternalPlaybackActive: Bool {
        return true
    }
    
}
