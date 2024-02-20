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
                
                Text("Slow Jog On The Sport")
                    .fontWeight(.semibold)
                    .padding(.top, 16)
                    .font(.system(size: 16))
                
                Text(getTimeString())
                    .font(.system(size: 34))
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(alignment: .center, spacing: 8) {
                    Text("Back")
                        .foregroundColor(Color(red: 0.61, green: 0.61, blue: 0.63))
                        .frame(width: (widthDevice - 48) / 2, height: 50)
                        .background(alignment: .center) {
                            RoundedRectangle(cornerRadius: 14)
                            .inset(by: 0.75)
                            .stroke(Color(red: 0.92, green: 0.92, blue: 0.94), lineWidth: 1.5)
                        }
                    
                    Text("Next")
                        .frame(width: (widthDevice - 48) / 2, height: 50)
                        .foregroundColor(.white)
                        .background(alignment: .center) {
                            RoundedRectangle(cornerRadius: 14)
                                .inset(by: 0.75)
//                                .stroke(Color(red: 0.92, green: 0.92, blue: 0.94), lineWidth: 1.5)
                                .fill(Color(red: 0.95, green: 0.32, blue: 0.14))
                    
                        }
                        
                }
                .padding(.bottom, 58)
                
            }

        }
    }
    
    func getTimeString() -> String {
        let time = CMTime(seconds: Double(viewModel.currentTimeVieos[viewModel.currentIndexURL] ), preferredTimescale: 1)
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
            
            if value < 0.05 {
                return 6
            } else {
                return CGFloat(value) * width
            }
        }
        
        
    }
}

