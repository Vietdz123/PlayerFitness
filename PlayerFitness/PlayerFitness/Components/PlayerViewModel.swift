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
    static let shared: PlayerViewModel = PlayerViewModel()
    @Published var totalTimeVieos: [Float] = []
    @Published var currentTimeVieos: [Float] = []
    
    @Published var secondsReady = 6
    @Published var textReady = "Get Ready"
    @Published var isShowingReadyView = false
    @Published var isLastVideo = false
    
    @Published var isEnableNextButton = true
    @Published var isEnableBackButton = false
    @Published var isShowingBottomProgressView = false
    
    @Published var isShowingRestFullScreenView = false
    @Published var secondsRest = 16
    @Published var isFullScreen: Bool = false
    
    var didTapNextButton: (() -> Void)?
    var didTapBackButton: (() -> Void)?
    var didRestCompletion: (() -> Void)?
    let operationReadyQueue = OperationQueue()
    var timerReady: Timer? = nil
    var timerRest: Timer? = nil
    
    func resetReadyView() {
        self.timerReady?.invalidate()
        self.timerReady = nil
        self.secondsReady = 6
        self.textReady = "Get Ready"
    }
    
    func resetRest() {
        self.timerRest?.invalidate()
        self.timerRest = nil
        self.secondsRest = 16
        self.isShowingRestFullScreenView = false
    }
    
    func showingReadyViewV2(completionShowing: @escaping () -> Void) {
        timerReady = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in

            if self.secondsReady == 6 {
                self.isShowingReadyView = true
                self.textReady = "Get Ready"
                self.secondsReady -= 1
                return
            }
            
            if self.secondsReady <= 5 && self.secondsReady > 0 {
                self.textReady = "\(self.secondsReady)"
                self.secondsReady -= 1
                return
            }
            
            if self.secondsReady == 0 {
                completionShowing()
                self.textReady = "GO"
                self.secondsReady -= 1
                return
            }
            
            if self.secondsReady == -1 {
                self.isShowingReadyView = false
                self.timerReady?.invalidate()
                self.timerReady = nil
                return
            }
        })
    }
    
    func startRest(completionShowing: @escaping () -> Void) {
        timerRest = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in

            if self.secondsRest > 0 {
                self.isShowingRestFullScreenView = true
                self.secondsRest -= 1
                return
            }
            
            self.resetRest()
            self.isShowingRestFullScreenView = false
            self.didRestCompletion?()
        })
    }
    
    @MainActor
    func getCurrentURL() async -> String? {
        if urls.isEmpty || currentIndexURL < 0 || currentIndexURL > urls.count - 1  {
            return nil
        }
        
        let file = FileService.shared.readVideoUrl(urlVideo: urls[currentIndexURL])
        if file != nil {
            print("DEBUG: \(file) file")
            return file
        } else {
            let file =  await FileService.shared.writeToSource(urlVideo: urls[currentIndexURL])
            
            print("DEBUG: \(file) cac")
            return file
        }
        
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
        if currentIndexURL == numberVideo - 2 {
            currentIndexURL += 1
            isEnableNextButton = false
            
            for index in  0 ..< currentIndexURL {
                self.currentTimeVieos[index] = 100000
            }
            isLastVideo = true
            return .isLastVideo
        }
        
        for index in  0 ... currentIndexURL {
            self.currentTimeVieos[index] = 100000
        }
        currentIndexURL += 1
        isEnableNextButton = true
        isEnableBackButton = true
        return .normal
    }
    
    func itemDidFinishPlay() -> StatusUpdatePlayer {
        let status = nextVideo()
        return status
    }
    
    @MainActor
    func backVideo() -> StatusUpdatePlayer {
        if currentIndexURL == 1 {
            currentIndexURL -= 1
            isEnableBackButton = false
            for index in currentIndexURL ..< totalTimeVieos.count {
                self.currentTimeVieos[index] = 0
            }
            return .isFirstVideo
        }
        
        isEnableBackButton = true
        isEnableNextButton = true
        
        currentIndexURL -= 1
        isLastVideo = false
        for index in currentIndexURL ..< totalTimeVieos.count {
            self.currentTimeVieos[index] = 0
        }
        return .normal
    }
    
    func updateViewModel(urls: [String]) {
        self.urls = urls
        self.totalTimeVieos = Array(repeating: 0, count: urls.count)
        self.currentTimeVieos = Array(repeating: 0, count: urls.count)
        self.secondsReady = 3
        self.textReady = "Get Ready"
        self.isShowingReadyView = false
        self.isEnableBackButton = false
        self.isEnableNextButton = true
        self.didTapBackButton = nil
        self.didTapNextButton = nil
        self.isLastVideo = false
        self.isShowingRestFullScreenView = false
        self.isFullScreen = false
        self.secondsRest = 16
    }
    
    init() {}
    
}
