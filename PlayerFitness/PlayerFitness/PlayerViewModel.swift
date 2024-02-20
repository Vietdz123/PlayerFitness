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
    static let shared: PlayerViewModel = .init(urls: [])
    @Published var totalTimeVieos: [Float]
    @Published var currentTimeVieos: [Float]
    
    @Published var seconds = 6
    @Published var textReady = "Get Ready"
    @Published var isShowingReadyView = false
    
    func resetReadyView() {
        seconds = 6
        textReady = "Get Ready"
    }
    
    func showingReadyView() {
//        isShowingReadyView = true
        
//        if seconds == 6 {
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.seconds -= 1
//                self.showingReadyView()
//            }
//            
//            return
//        }
//        
//        if seconds <= 5 && seconds > 0 {
//            textReady = "\(seconds)"
//            
//            if seconds >= 1 {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.seconds -= 1
//                    
//                    if self.isShowingReadyView {
//                        self.showingReadyView()
//                    }
//                }
//            }
//        } else {
//            self.textReady = "GO"
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.isShowingReadyView = false
//            }
//        }
    }
    
    var currentURL: String? {
        if urls.isEmpty || currentIndexURL < 0 || currentIndexURL > urls.count - 1  {
            return nil
        }
        
        return urls[currentIndexURL]
    }
    
    @Published var currentIndexURL: Int = 0
    
    var numberVideo: Int {
        return urls.count
    }
    
    func updateCurrentTime(currentTime: CMTime) {
        self.currentTimeVieos[currentIndexURL] = Float(currentTime.seconds)
    }
    
    func updateTotalTime(totalTime: CMTime) {
        self.totalTimeVieos[currentIndexURL] = Float(totalTime.seconds)
    }
    
    func nextVideo() -> StatusUpdatePlayer {
        if currentIndexURL == numberVideo - 1 {
            return .isLastVideo
        }
        
        self.currentTimeVieos[currentIndexURL] = 500
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
        
        self.currentTimeVieos[currentIndexURL] = 0
        currentIndexURL -= 1
        return .normal
    }
    
    func updateViewModel(urls: [String]) {
        self.urls = urls
        self._totalTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
        self._currentTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))

    }
    
    init(urls: [String]) {
        self.urls = urls
        self._totalTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
        self._currentTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
   
    }
    
}
