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
    
    @Published var isEnableNextButton = true
    @Published var isEnableBackButton = false
    @Published var isCallcelShowingView = false
    
    var didTapNextButton: (() -> Void)?
    var didTapBackButton: (() -> Void)?
    var taskReady = Task {}
    
    func resetReadyView() {
        taskReady.cancel()
        seconds = 6
        textReady = "Get Ready"
        
    }
    
    func showingReadyView(completionShowing: @escaping () -> Void) {
        
        
            isShowingReadyView = true
            
            if seconds == 6 {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.seconds -= 1
                    self.showingReadyView() {
                        completionShowing()
                    }
                }
                
                return
            }
            
            if seconds <= 5 && seconds > 0 {
                textReady = "\(seconds)"
                
                if seconds >= 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.seconds -= 1
                        
                        if self.isShowingReadyView {
                            self.showingReadyView() {
                                completionShowing()
                            }
                        }
                    }
                }
            } else {
                self.textReady = "GO"
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    completionShowing()
                    self.isShowingReadyView = false
                }
            }
        
    }
    
    @MainActor
    func showingReadyViewV2(completionShowing: @escaping () -> Void) {
        taskReady = Task {
        isShowingReadyView = true
        
        if seconds == 6 {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.seconds -= 1
            self.showingReadyView() {
                completionShowing()
            }
            
            return
        }
        
        if seconds <= 5 && seconds > 0 {
            textReady = "\(seconds)"
            
            if seconds >= 1 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.seconds -= 1
                
                if self.isShowingReadyView {
                    self.showingReadyView() {
                        completionShowing()
                    }
                }
            }
        } else {
            self.textReady = "GO"
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            completionShowing()
            self.isShowingReadyView = false
        }
        }
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
        if currentIndexURL == numberVideo - 2 {
            currentIndexURL += 1
            isEnableNextButton = false
            
            for index in  0 ..< currentIndexURL {
                self.currentTimeVieos[index] = 100000
            }
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
        for index in currentIndexURL ..< totalTimeVieos.count {
            self.currentTimeVieos[index] = 0
        }
        return .normal
    }
    
    func updateViewModel(urls: [String]) {
        self.urls = urls
        self._totalTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
        self._currentTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
        self._seconds = .init(wrappedValue: 6)
        self._textReady = .init(wrappedValue: "Get Ready")
        self._isShowingReadyView = .init(wrappedValue: false)
        self._isEnableBackButton = .init(wrappedValue: false)
        self._isEnableNextButton = .init(wrappedValue: true)
        self.didTapBackButton = nil
        self.didTapNextButton = nil
    }
    
    init(urls: [String]) {
        self.urls = urls
        self._totalTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
        self._currentTimeVieos = .init(wrappedValue: Array(repeating: 0, count: urls.count))
        self._seconds = .init(wrappedValue: 6)
        self._textReady = .init(wrappedValue: "Get Ready")
        self._isShowingReadyView = .init(wrappedValue: false)
        self._isEnableBackButton = .init(wrappedValue: false)
        self._isEnableNextButton = .init(wrappedValue: true)
        self.didTapBackButton = nil
        self.didTapNextButton = nil
    }
    
}
