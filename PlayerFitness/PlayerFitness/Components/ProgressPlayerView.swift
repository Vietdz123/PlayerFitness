//
//  ProgressPlayerView.swift
//  PlayerFitness
//
//  Created by MAC on 20/02/2024.
//

import SwiftUI
import AVFoundation

struct TotalProgressView: View {
    @StateObject var viewModel: PlayerViewModel = PlayerViewModel.shared
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: viewModel.totalTimeVieos.count)
        
        ZStack(alignment: .leading) {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 8, content: {
                ForEach(viewModel.totalTimeVieos.indices) { index in
                    ProgressVideoView(isPlaying: .constant(viewModel.currentIndexURL == index),
                                      currentTimeVideo: $viewModel.currentTimeVieos[index],
                                      totalTimeVideo: $viewModel.totalTimeVieos[index])
                    
                }
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Color.clear
            }
        }

        .background {
            Color.clear
        }
    }
}

struct ProgressPlayerView: View {
    
    @StateObject var viewModel: PlayerViewModel = PlayerViewModel.shared
    
    var didSelecBackButton: (() -> Void)?
    var didSelecNextButton: (() -> Void)?
    @State var willShowBackButton: Bool = true
    @State var willShowNextButton: Bool = true

    
    var body: some View {
        ZStack(alignment: .center) { 
            VStack(alignment: .center, spacing: 0) {
                TotalProgressView()
                    .padding(.top, 28)
                
                if !viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen {
                    Text("Slow Jog On The Sport")
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                        .font(.system(size: 16))
                    
                    Text(getTimeString())
                        .font(.system(size: 34))
                        .fontWeight(.semibold)
                } else if viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen {
                    Text("Rest")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                        .padding(.top, 16)
                    
                    Text(getTimeRestString())
                        .font(.system(size: 34))
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                HStack(alignment: .center, spacing: 8) {
                    Button(action: {
                        if viewModel.isEnableBackButton && !viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen {
                            viewModel.didTapBackButton?()
                            return
                        }
                        
                        viewModel.secondsRest += 20
                    }, label: {
                        Text(!viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen ? "Back" : "+20s")
                            .foregroundColor(!viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen ? (viewModel.isEnableBackButton ? Color(red: 0.95, green: 0.32, blue: 0.14) : Color(red: 0.61, green: 0.61, blue: 0.63)) : .white)
                            .frame(width: (widthDevice - 48) / 2, height: 50)
                            .background(alignment: .center) {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(viewModel.isEnableBackButton ? Color(red: 0.95, green: 0.32, blue: 0.14) : Color(red: 0.92, green: 0.92, blue: 0.94).opacity(0.6), lineWidth: 1.5)
                                    .background(
                                        !viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen ? .white : Color(red: 0.21, green: 0.21, blue: 0.27)
                                    )
                                    .cornerRadius(14, corners: .allCorners)
                            }
                            
                    })
                    .allowsHitTesting(viewModel.isEnableBackButton || viewModel.isShowingRestFullScreenView)
  
                    
                    Button(action: {
                        if viewModel.isEnableNextButton && !viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen {
                            viewModel.didTapNextButton?()
                            return 
                        }
                        
                        viewModel.resetRest()
                        viewModel.didTapNextButton?()
                    }, label: {
                        Text(!viewModel.isShowingRestFullScreenView && !viewModel.isFullScreen ? "Next" : "Skip")
                            .frame(width: (widthDevice - 48) / 2, height: 50)
                            .foregroundColor(.white)
                            .background(alignment: .center) {
                                RoundedRectangle(cornerRadius: 14)
                                    .inset(by: 0.75)
                                    .fill(Color(red: 0.95, green: 0.32, blue: 0.14))
                                    
                        
                            }
                            .opacity(viewModel.isEnableNextButton ? 1 : 0.6)
                            
                    })
                    .allowsHitTesting(viewModel.isEnableNextButton)

                        
                }
                .padding(.bottom, 58)
                
            }

        }
    }
    
    func getTimeString() -> String {
        let time = CMTime(seconds: Double(viewModel.currentTimeVieos[viewModel.currentIndexURL] ), preferredTimescale: 1)
        return time.getTimeString() ?? "00:00"
    }
    
    func getTimeRestString() -> String {
        let time = CMTime(seconds: Double(viewModel.secondsRest), preferredTimescale: 1)
        return time.getTimeString() ?? "00:00"
    }
}

struct ProgressVideoView: View {
    
    @Binding var isPlaying: Bool
    @Binding var currentTimeVideo: Float
    @Binding var totalTimeVideo: Float
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(alignment: .leading) {
                
                Color(hex: "0xF5F5FA")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(Capsule())
                
                Color(hex: "0xF15223")
                    .frame(maxWidth: getWidth(width: geometry.size.width),
                           maxHeight: .infinity)
                    .clipShape(Capsule())
            }
        })
    }
    
    func getWidth(width: CGFloat) -> CGFloat {
        if currentTimeVideo == 0 && isPlaying {
            return 6
        } else if currentTimeVideo == 0 && !isPlaying {
            return 0
        } else {
            let value = currentTimeVideo / totalTimeVideo
            
            if CGFloat(value) * width < 6 {
                return 6
            } else {
                return CGFloat(value) * width
            }
        }
        
        
    }
}

