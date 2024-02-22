//
//  BottomFullScreenProgressView.swift
//  PlayerFitness
//
//  Created by MAC on 22/02/2024.
//

import SwiftUI
import ClockKit
import AVFoundation

struct BottomFullScreenProgressView: View {
    @StateObject private var viewModel = PlayerViewModel.shared
    
    var body: some View {
        
        if viewModel.isShowingBottomProgressView {
            HStack(alignment: .center, spacing: 0) {
                Circle()
                    .stroke(Color.white, lineWidth: 8)
                    .overlay(alignment: .center) {
                        Circle()
                            .trim(from: 0, to: Double(viewModel.currentIndexURL + 1) / Double(viewModel.totalTimeVieos.count == 0 ? 1 : viewModel.totalTimeVieos.count))
                            .rotation(.degrees(-90))
                            .stroke(Color(red: 0.95, green: 0.32, blue: 0.14), lineWidth: 8)
                        
                    }
                    .frame(width: 54, height: 54, alignment: .center)
                    .padding(.trailing, 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Push up")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                    
                    Text("Step \(viewModel.currentIndexURL + 1)/\(viewModel.totalTimeVieos.count)")
                        .foregroundColor(Color(red: 0.39, green: 0.39, blue: 0.43))
                }
                
                Spacer()
                
                Text(getTimeString())
                    .font(.system(size: 34))
                    .fontWeight(.semibold)
                    .frame(width: 100, height: 33.33333, alignment: .center)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.98).opacity(0.5))
                    .cornerRadius(6)
//                    .padding(.trailing, 10)
                
            }
            .padding(.horizontal, 32)
            .frame(width: widthDevice, height: 60, alignment: .center)
            
        }
    }
    
    func getTimeString() -> String {
        let time = CMTime(seconds: Double(viewModel.currentTimeVieos[viewModel.currentIndexURL] ), preferredTimescale: 1)
        return time.getTimeString() ?? "00:00"
    }
}

