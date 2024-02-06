//
//  PlayerViewModel.swift
//  PlayerFitness
//
//  Created by MAC on 05/02/2024.
//

import Foundation

import SwiftUI
import AVFoundation

enum StatusUpdatePlayer: Int, CaseIterable {
    case isFirstVideo
    case isLastVideo
    case normal
}

class PlayerViewModel: ObservableObject {
    
    var urls: [String] = []
    var currentURL: String? {
        if urls.isEmpty || currentIndexURL < 0 || currentIndexURL > urls.count - 1  {
            return nil
        }
        
        return urls[currentIndexURL]
    }
    
    var currentIndexURL: Int = 0
    
    var numberVideo: Int {
        return urls.count
    }
    
    func nextVideo() -> StatusUpdatePlayer {
        if currentIndexURL == numberVideo - 2 {
            currentIndexURL += 1
            return .isLastVideo
        }
        
        currentIndexURL += 1
        return .normal
    }
    
    func itemDidFinishPlay() -> StatusUpdatePlayer {
        let status = nextVideo()
        return status
    }
    
    func backVideo() -> StatusUpdatePlayer {
        if currentIndexURL == 1 {
            currentIndexURL -= 1
            return .isFirstVideo
        }
        
        currentIndexURL -= 1
        return .normal
    }
    
    init(urls: [String]) {
        self.urls = urls
        

    }
    
}
