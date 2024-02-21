//
//  PlayerController.swift
//  PlayerFitness
//
//  Created by MAC on 02/02/2024.
//

import SwiftUI
import AVFoundation
import AVKit


extension UIViewController {
    
    func setOrientationController(rotateOrientation: UIInterfaceOrientation) {
        if #available(iOS 16.0, *) {
                guard
                    let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController,
                    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                else { return }
            
            if windowScene.interfaceOrientation.isPortrait {
                AppDelegate.orientationLock = .landscape
            } else {
                AppDelegate.orientationLock = .portrait
            }
                rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
                windowScene.requestGeometryUpdate(.iOS(
                    interfaceOrientations: windowScene.interfaceOrientation.isLandscape
                        ? .portrait
                        : .landscapeRight
                ))
            
            } else {
                UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
            }
    }
    
}

class PlayerController: UIViewController {
    
    // MARK: - Properties
    let viewModel: PlayerViewModel
    var player = AVPlayer()
    private var timeObserverToken: Any?
    private var isPlaying: Bool = true
    private var isFullScreen: Bool = false
    private lazy var playerLayer = AVPlayerLayer(player: player)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - SwiftUI View
    private var bottomProgressView: ProgressPlayerView = ProgressPlayerView()
    private var topFullScreenProgressView: TotalProgressView = TotalProgressView()
    private var getReadyView: GetReadyView = GetReadyView()
    
    private var bottomProgressSwiftUIView: UIHostingController<ProgressPlayerView>?
    private var topFullScreenSwiftUIView: UIHostingController<TotalProgressView>?
    private var getReadySwiftUIView: UIHostingController<GetReadyView>?
    
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
        stackView.spacing = 32
        stackView.isHidden = true
        return stackView
    }()
    
    // MARK: - ActivityStackView: Next + Play
    private lazy var playFullScreenVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.playVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handlePlayButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var nextVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.nextVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleNextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backVideoBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.backVideo.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
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
        stackView.spacing = 32
        stackView.isHidden = true
        return stackView
    }()
    
    
    // MARK: - containerActionView
    private lazy var fullscreenButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.fullscreen.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleFullScreenButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tvcastButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.screencastPlayer.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleFullScreenButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    private lazy var mutedSoundButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: AssetConstant.soundPlayer.rawValue), for: .normal)
        button.addTarget(self, action: #selector(handleMutedButtonTapped), for: .touchUpInside)
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
        if self.isFullScreen {
            self.setOrientationController(rotateOrientation: .portrait)

        } else {
            self.setOrientationController(rotateOrientation: .landscapeLeft)

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
        }
        
        isPlaying.toggle()
    }
    
    @objc func handleNextButtonTapped() {
        DispatchQueue.main.async {
            let status = self.viewModel.nextVideo()
            if status == .normal {
                self.nextVideoBtn.alpha = 1
                self.nextVideoBtn.isUserInteractionEnabled = true
                
            } else if status == .isLastVideo {
                self.nextVideoBtn.alpha = 0.4
                self.nextVideoBtn.isUserInteractionEnabled = false
            }
            
            self.backVideoBtn.alpha = 1
            self.backVideoBtn.isUserInteractionEnabled = true
            self.player.pause()
            self.playVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.playFullScreenVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.updatePlayer()
        }
    }
    
    @objc func handleBackButtonTapped() {
        DispatchQueue.main.async {
            let status = self.viewModel.backVideo()
            if status == .normal {
                self.backVideoBtn.alpha = 1
                self.backVideoBtn.isUserInteractionEnabled = true
            } else if status == .isFirstVideo {
                self.backVideoBtn.alpha = 0.4
                self.backVideoBtn.isUserInteractionEnabled = false
            }
            
            self.nextVideoBtn.alpha = 1
            self.nextVideoBtn.isUserInteractionEnabled = true
            self.player.pause()
            self.playVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.playFullScreenVideoBtn.setImage(UIImage(named: AssetConstant.playVideo.rawValue)?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.updatePlayer()
        }

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
        PlayerViewModel.shared.updateViewModel(urls: urls)
        self.viewModel = PlayerViewModel.shared

        super.init(nibName: nil, bundle: nil)
        self.viewModel.didTapBackButton = { [weak self] in
            self?.handleBackButtonTapped()
        }
        
        self.viewModel.didTapNextButton = { [weak self] in
            self?.handleNextButtonTapped()
        }
    }
    
    deinit {
        print("DEBUG: PlayerViewController deinit By Viet")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        print("DEBUG: \(size) siuuu")
        let width = size.width
        let height = size.height
        
        
        //Is Landscape
        if width > height {
            self.playerLayer.frame = .init(origin: .zero, size: .init(width: widthDevice, height: heightDevice))
            self.shadowView.frame = .init(origin: .zero, size: size)
            self.actionStackView.isHidden = true
            self.shadowView.isHidden = true
            self.activityPlayStackView.isHidden = true
            self.activityFullScreenPlayStackView.isHidden = true
            self.fullscreenButton.setImage(UIImage(named: AssetConstant.smallVideo.rawValue), for: .normal)
          
            self.actionStackView.axis = .vertical
            self.actionStackView.frame = .init(x: width - 36 - 44, y: 36, width: 44, height: 144)
            self.actionStackView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: -20)
            self.activityFullScreenPlayStackView.frame = .init(x: width / 2 - 204 / 2, y: height / 2 - 30 / 2, width: 204, height: 60)
            self.activityFullScreenPlayStackView.axis = .horizontal
            
            let swiftuiView = topFullScreenSwiftUIView?.view
            swiftuiView?.isHidden = false
            swiftuiView?.frame = .init(x: 32, y: 20, width: width - 64, height: 10)
            
        } else {

            self.playerLayer.frame = .init(x: 0, y: 0, width: width, height: width / 375 * 450)
            self.shadowView.frame = .init(x: 0, y: 0, width: width, height: width / 375 * 450)
            self.activityPlayStackView.isHidden = true
            self.actionStackView.isHidden = true
            self.shadowView.isHidden = true
            self.activityFullScreenPlayStackView.isHidden = true
            self.fullscreenButton.setImage(UIImage(named: AssetConstant.fullscreen.rawValue), for: .normal)
            
            self.actionStackView.frame = .init(x: width / 2 - 70, y: width / 375 * 225 + 30 + 48 + 12, width: 140, height: 44)
            self.actionStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
            self.actionStackView.axis = .horizontal

            let swiftuiView = topFullScreenSwiftUIView?.view!
            swiftuiView?.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addTimeObserver()
        AppDelegate.orientationLock = .portrait
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
                 
                 self.viewModel.updateTotalTime(totalTime: player.currentItem?.duration ?? .zero)
                 viewModel.resetReadyView()
                 viewModel.showingReadyViewV2() { [weak self] in
                     self?.player.play()
                 }
                 
             case .failed: return
             case .unknown: return
             @unknown default: return
             }
         }
     }

    
    private func configureUI() {
        view.backgroundColor = .white
        updatePlayer()
        addBottomSwiftUIView()
           
        playerLayer.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.width / 375 * 450)
        playerLayer.videoGravity = .resizeAspectFill
        player.isMuted = true
        view.layer.addSublayer(playerLayer)
        view.layer.masksToBounds = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewMainTapped)))
        
        addTopFullScreenSwiftUIView()
        view.addSubview(shadowView)
        view.addSubview(activityPlayStackView)
        view.addSubview(actionStackView)
        view.addSubview(activityFullScreenPlayStackView)
        addGetReadyView()
        
        activityPlayStackView.frame = .init(x: widthDevice / 2 - 204 / 2, y: widthDevice / 375 * 225 - 30, width: 204, height: 60)
        activityFullScreenPlayStackView.frame = .init(x: widthDevice / 2 - 60 / 2, y: heightDevice / 2 - 204 / 2, width: 60, height: 204)
        actionStackView.frame = .init(x: widthDevice - 44 - 16, y: insetTop + 16, width: 44, height: 147)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.actionStackView.isHidden = true
            self.actionStackView.axis = .horizontal
            self.actionStackView.frame = .init(x: self.widthDevice / 2 - 70, y: self.widthDevice / 375 * 225 + 30 + 48 + 12, width: 144, height: 44)
            self.actionStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
            self.actionStackView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidFinishPlay),
                                               name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        player.allowsExternalPlayback = true
        player.externalPlaybackVideoGravity = .resizeAspectFill
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] currentTime in
            self?.viewModel.updateCurrentTime(currentTime: currentTime)
        })
    }
    
    private func addBottomSwiftUIView() {
        self.bottomProgressSwiftUIView = UIHostingController(rootView: bottomProgressView)
        let swiftuiView = self.bottomProgressSwiftUIView!.view!
        swiftuiView.frame = .init(x: 16, y: view.frame.width / 375 * 450, width: widthDevice - 32, height: heightDevice - view.frame.width / 375 * 450)
        view.addSubview(swiftuiView)
    }
    
    private func addTopFullScreenSwiftUIView() {
        self.topFullScreenSwiftUIView = UIHostingController(rootView: topFullScreenProgressView)
        let swiftuiView = self.topFullScreenSwiftUIView!.view!
        
        swiftuiView.isHidden = true
        swiftuiView.backgroundColor = .clear
        view.addSubview(swiftuiView)
    }
    
    private func addGetReadyView() {
        self.getReadySwiftUIView = UIHostingController(rootView: getReadyView)
        
        let swiftuiView = self.getReadySwiftUIView!.view!
        
        swiftuiView.backgroundColor = .clear
        view.addSubview(swiftuiView)
        swiftuiView.frame = .init(x: widthDevice / 2 - 204 / 2, y: widthDevice / 375 * 225 - 30, width: 204, height: 60)
        swiftuiView.layer.zPosition = .infinity
        swiftuiView.isUserInteractionEnabled = false
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
