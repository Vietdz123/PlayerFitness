//
//  PlayerController.swift
//  PlayerFitness
//
//  Created by MAC on 02/02/2024.
//

import SwiftUI
import AVFoundation

class PlayerViewModel: ObservableObject {
    
    var urls: [String] = []
    var currentURL: String? = nil
    
    var currentIndexURL: Int = 0
    
    init(urls: [String]) {
        self.urls = urls
        
        if !urls.isEmpty {
            self.currentURL = urls[currentIndexURL]
        }
    }
    
}


class PlayerController: UIViewController {
    
    // MARK: - Properties
    let viewModel: PlayerViewModel
    
    let player = AVPlayer()
    private lazy var playerLayer = AVPlayerLayer(player: player)
    
    
    // MARK: - View Lifecycle
    init(urls: [String]) {
        self.viewModel = PlayerViewModel(urls: urls)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    // MARK: - Methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         
         if keyPath == #keyPath(AVPlayerItem.status) {
             let status: AVPlayerItem.Status
             if let statusNumber = change?[.newKey] as? NSNumber {
                 status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
             } else {
                 status = .unknown
             }
             switch status {
             case .readyToPlay:
                 player.play()
             case .failed: return
             case .unknown: return
             @unknown default: return
             }
         }
         

     }
    
    private func configureUI() {
        guard let currentURL = viewModel.currentURL, let url = URL(string: currentURL) else {return}
        
        let item = AVPlayerItem(url: url)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        player.replaceCurrentItem(with: item)
        playerLayer.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.layer.addSublayer(playerLayer)
    }
    
    
    // MARK: - Selectors
    
}

