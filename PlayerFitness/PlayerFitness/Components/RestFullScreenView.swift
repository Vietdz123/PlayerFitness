//
//  RestFullScreenView.swift
//  PlayerFitness
//
//  Created by MAC on 22/02/2024.
//

import SwiftUI
import AVFoundation

struct RestFullScreenView: View {
    
    @StateObject private var viewModel = PlayerViewModel.shared
    
    var body: some View {
        if viewModel.isShowingRestFullScreenView && viewModel.isFullScreen {
            
            VStack(alignment: .leading, spacing: 0) {
                
                TotalProgressView()
                    .frame(width: widthDevice - 64, height: 8)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next: \(viewModel.currentIndexURL + 1)/\(viewModel.totalTimeVieos.count)")
                        .foregroundColor(Color(red: 0.21, green: 0.21, blue: 0.27))
                    
                    Text("Lat Pulldown")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                }
                .padding(.top, 28)
                
                HStack(alignment: .bottom, spacing: 36) {
                    Image("next_thumb")
                        .resizable()
                        .frame(width: (widthDevice - 64 - 36) / 2, height: (heightDevice - 116 - 38))
                        .cornerRadius(14)
                        .padding(.top, 12)
                    
                    VStack(alignment: .center, spacing: 0) {
                        Spacer()
                        
                        Text("Rest")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                            .padding(.bottom, 4)
                        
                        Text(getTimeString())
                            .font(.system(size: 34))
                            .fontWeight(.semibold)
                            .padding(.bottom, 60)
                        
                        HStack(alignment: .center, spacing: 16) {
                            Button(action: {
                                viewModel.secondsRest += 20
                            }, label: {
                                Text("+20s")
                                    .foregroundColor(.white)
                                    .frame(width: 164, height: 50, alignment: .center)
                                    .background {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(red: 0.21, green: 0.21, blue: 0.27))
                                        
                                    }
                                
                            })
                            
                            Button(action: {
                                if viewModel.isEnableNextButton {
                                    viewModel.resetRest()
                                    viewModel.didTapNextButton?()
                                }
                            }, label: {
                                Text("Skip")
                                    .frame(width: 164, height: 50, alignment: .center)
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
                        
                        
                    }
                    
                    
                }
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white)
            
        }
        
    }
    

    func getTimeString() -> String {
        let time = CMTime(seconds: Double(viewModel.secondsRest), preferredTimescale: 1)
        return time.getTimeString() ?? "00:00"
    }
}

