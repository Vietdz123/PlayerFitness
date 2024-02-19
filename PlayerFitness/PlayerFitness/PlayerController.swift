//
//  PlayerController.swift
//  PlayerFitness
//
//  Created by MAC on 02/02/2024.
//

import SwiftUI
import AVFoundation
import AVKit

class PlayerController: UIViewController {
    
    // MARK: - Properties
    let viewModel: PlayerViewModel
    var player = AVPlayer()
    private var isPlaying: Bool = true
    private var isFullScreen: Bool = false
    private lazy var playerLayer = AVPlayerLayer(player: player)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private lazy var playerViewController: LandscapeAVPlayerController = {
        let vc = LandscapeAVPlayerController()
        vc.showsPlaybackControls = false
        vc.player = self.player
        vc.modalPresentationStyle = .overFullScreen
        vc.videoGravity = .resizeAspectFill
        vc.view.backgroundColor = .blue
        return vc
    }()
    
    private lazy var shadowView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: widthDevice, height: widthDevice / 375 * 450)
        view.backgroundColor = UIColor(rgb: 0x151515).withAlphaComponent(0.4)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShadowViewTapped)))
        view.isHidden = true
        return view
    }()
    
    // MARK: - ActivityStackView: Rewind + Play
    private lazy var playVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.playVideo.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rewindNextVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.rewindNextVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(rewindNextTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rewindBackVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.rewindBackVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(rewindBackTappedTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityPlayStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [rewindBackVideoBtn,
                                                       playVideoBtn,
                                                       rewindNextVideoBtn])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 32
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - ActivityStackView: Next + Play
    private lazy var playFullScreenVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.playVideo.rawValue), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlayButtonTapped), for: .touchUpInside)
        button.transform = .init(rotationAngle: .pi / 2)
        return button
    }()
    
    private lazy var nextVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.nextVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleNextButtonTapped), for: .touchUpInside)
        button.transform = .init(rotationAngle: .pi / 2)
        return button
    }()
    
    private lazy var backVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.backVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        button.transform = .init(rotationAngle: .pi / 2)
        button.alpha = 0.4
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var activityFullScreenPlayStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backVideoBtn,
                                                       playFullScreenVideoBtn,
                                                       nextVideoBtn])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 32
        stackView.isHidden = true
        return stackView
    }()
    
    
    // MARK: - containerActionView
    private lazy var fullscreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.fullscreen.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleFullScreenButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tvcastButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.screencastPlayer.rawValue), for: .normal)
        button.addTarget(self, action: #selector(rewindBackTappedTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var mutedSoundButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.soundPlayer.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleMutedButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullscreenButton,
                                                       tvcastButton,
                                                       mutedSoundButton])
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 24
        stackView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
        stackView.layer.cornerRadius = 22
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    @objc func handleMutedButtonTapped() {
        
    }
    
    @objc func handleFullScreenButtonTapped() {
        UIView.animate(withDuration: 0.5) {
            if self.isFullScreen {
                self.playerLayer.setAffineTransform(.identity)
                self.playerLayer.frame = .init(x: 0, y: 0, width: self.widthDevice, height: self.widthDevice / 375 * 450)

            } else {
                self.shadowView.isHidden = true
                self.activityPlayStackView.isHidden = true
                self.playerLayer.setAffineTransform(CGAffineTransform(rotationAngle: .pi / 2))
                self.playerLayer.frame = .init(origin: .zero, size: .init(width: self.widthDevice, height: self.heightDevice))
            }
        }
        
        if self.isFullScreen {
            self.shadowView.frame = .init(x: 0, y: 0, width: self.widthDevice, height: self.widthDevice / 375 * 450)
            self.activityPlayStackView.isHidden = true
            self.actionStackView.isHidden = true
            self.shadowView.isHidden = true
            self.activityFullScreenPlayStackView.isHidden = true
            self.fullscreenButton.setImage(UIImage(named: AssetConstant.fullscreen.rawValue), for: .normal)
            
            self.actionStackView.frame = .init(x: self.widthDevice / 2 - 70, y: self.widthDevice / 375 * 225 + 30 + 48 + 12, width: 140, height: 44)
            self.actionStackView.layer.setAffineTransform(.init(rotationAngle: .pi / 2 * 3))
            self.mutedSoundButton.layer.setAffineTransform(.init(rotationAngle: .pi / 2))
            self.fullscreenButton.layer.setAffineTransform(.init(rotationAngle: .pi / 2))
            self.tvcastButton.layer.setAffineTransform(.init(rotationAngle: .pi / 2))
            
        } else {
            self.actionStackView.isHidden = true
            self.shadowView.frame = .init(origin: .zero, size: .init(width: self.widthDevice, height: self.heightDevice))
            self.activityPlayStackView.isHidden = true
            self.fullscreenButton.setImage(UIImage(named: AssetConstant.smallVideo.rawValue), for: .normal)
          
            self.actionStackView.frame = .init(x: self.widthDevice - 140 - 36, y: self.heightDevice - self.insetBottom - 48, width: 140, height: 44)
            self.actionStackView.layer.setAffineTransform(.init(rotationAngle: .pi / 2))
            self.mutedSoundButton.layer.setAffineTransform(.init(rotationAngle: .pi * 2))
            self.fullscreenButton.layer.setAffineTransform(.init(rotationAngle: .pi * 2))
            self.tvcastButton.layer.setAffineTransform(.init(rotationAngle: .pi * 2))
        }
        isFullScreen.toggle()
    }

    @objc func handlePlayButtonTapped() {
        if isPlaying {
            player.pause()
            self.playVideoBtn.setImage(UIImage(named: AssetConstant.pauseVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.playFullScreenVideoBtn.setImage(UIImage(named: AssetConstant.pauseVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            player.play()
            self.playVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.playFullScreenVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.fullscreenButton.transform = .init(rotationAngle: .pi / -2)
            self.mutedSoundButton.transform = .init(rotationAngle: .pi / 2)
        }
        
        isPlaying.toggle()
    }
    
    @objc func handleNextButtonTapped() {
        let status = viewModel.nextVideo()
        if status == .normal {
            nextVideoBtn.alpha = 1
            nextVideoBtn.isUserInteractionEnabled = true
        } else if status == .isLastVideo {
            nextVideoBtn.alpha = 0.4
            nextVideoBtn.isUserInteractionEnabled = false
        }
        
        backVideoBtn.alpha = 1
        backVideoBtn.isUserInteractionEnabled = true
        updatePlayer()
    }
    
    @objc func handleBackButtonTapped() {
        let status = viewModel.backVideo()
        if status == .normal {
            backVideoBtn.alpha = 1
            backVideoBtn.isUserInteractionEnabled = true
        } else if status == .isFirstVideo {
            backVideoBtn.alpha = 0.4
            backVideoBtn.isUserInteractionEnabled = false
        }
        
        nextVideoBtn.alpha = 1
        nextVideoBtn.isUserInteractionEnabled = true
        updatePlayer()
    }
    
    @objc func handleShadowViewTapped() {
        if !isFullScreen {
            shadowView.isHidden = true
            activityPlayStackView.isHidden = true
            actionStackView.isHidden = true
            
        } else {
            shadowView.isHidden = true
            activityFullScreenPlayStackView.isHidden = true
            actionStackView.isHidden = true
        }
    }
    
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
        addNotification()
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
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(gotoMirrorScreen), name: UIScene.willConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exitMirrorScreen), name: UIScene.didDisconnectNotification, object: nil)
    }
    
    @objc func gotoMirrorScreen() {
        AppDelegate.orientationLock = .all
        UIApplication.shared.windows.first?.rootViewController?.present(playerViewController, animated: false)
    }
    
    @objc func exitMirrorScreen() {
        playerViewController.dismiss(animated: false)
        AppDelegate.orientationLock = .portrait
    }
    
    private func configureUI() {
        updatePlayer()
        playerLayer.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.width / 375 * 450)
        playerLayer.videoGravity = .resizeAspectFill
        player.isMuted = true
        view.layer.addSublayer(playerLayer)
        view.layer.masksToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewMainTapped)))

        view.addSubview(shadowView)
        view.addSubview(activityPlayStackView)
        view.addSubview(actionStackView)
        view.addSubview(activityFullScreenPlayStackView)
        
        NSLayoutConstraint.activate([
            activityPlayStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: widthDevice / 375 * 225 - 30),
            activityPlayStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityFullScreenPlayStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityFullScreenPlayStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        activityPlayStackView.setDimensions(width: 204, height: 60)
        activityFullScreenPlayStackView.setDimensions(width: 60, height: 204)
        actionStackView.frame = .init(x: widthDevice - 44 - 16, y: insetTop + 16, width: 44, height: 147)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.actionStackView.isHidden = true
            self.actionStackView.frame = .init(x: self.widthDevice / 2 - 22, y: self.widthDevice / 375 * 225 + 30 + 48 - 70 + 12, width: 44, height: 140)
            self.actionStackView.transform = .init(rotationAngle: .pi / -2)
            self.fullscreenButton.transform = .init(rotationAngle: .pi / -2)
            self.tvcastButton.transform = .init(rotationAngle: .pi / 2)
            self.mutedSoundButton.transform = .init(rotationAngle: .pi / 2)
            self.actionStackView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinishPlay),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        player.allowsExternalPlayback = true
        player.externalPlaybackVideoGravity = .resizeAspectFill

        
    }
    
    func updatePlayer() {
        guard let currentURL = viewModel.currentURL, let url = URL(string: currentURL) else {return}
        
        let item = AVPlayerItem(url: url)
        item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: nil)
        self.player.replaceCurrentItem(with: item)
        self.isPlaying = true
        self.playVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    
    // MARK: - Selectors
    @objc func rewindNextTapped() {
        var currentTime = player.currentTime().seconds
        currentTime += 5
        
        player.seek(to: CMTime(value: CMTimeValue(currentTime), timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()
    }
    
    @objc func rewindBackTappedTapped() {
        var currentTime = player.currentTime().seconds
        currentTime -= 5
        
        player.seek(to: CMTime(value: CMTimeValue(currentTime), timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()
    }
    
    @objc func handleViewMainTapped() {
        shadowView.isHidden = false
        actionStackView.isHidden = false
        
        if isFullScreen {
            activityFullScreenPlayStackView.isHidden = false
            
        } else {
            activityPlayStackView.isHidden = false
        }
    }
    
    @objc func playerItemDidFinishPlay() {
        let status = viewModel.itemDidFinishPlay()

        if status == .isLastVideo {
            self.playVideoBtn.setImage(UIImage(named: AssetConstant.pauseVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.nextVideoBtn.alpha = 0.4
            self.nextVideoBtn.isUserInteractionEnabled = false
            player.seek(to: CMTime(seconds: .zero, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
            
        } else if status == .normal {
            
            self.updatePlayer()
            self.nextVideoBtn.alpha = 1
            self.nextVideoBtn.isUserInteractionEnabled = true
            
        }
    }
         
}

class LandscapeAVPlayerController: AVPlayerViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    
}
