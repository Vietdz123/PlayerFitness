//
//  ContentView.swift
//  PlayerFitness
//
//  Created by MAC on 02/02/2024.
//

import SwiftUI

struct ContentView: View {
    
//    var urls: [String] {
//        let video1 = Bundle.main.url(forResource: "Alternating Pull Down", withExtension: "mp4")?.absoluteString ?? ""
//        let video2 = Bundle.main.url(forResource: "Arm Cross Over", withExtension: "mp4")?.absoluteString ?? ""
//        let video3 = Bundle.main.url(forResource: "Bust Up", withExtension: "mp4")?.absoluteString ?? ""
//        
//        return [video1, video2, video3]
//    }
    
    var urls: [String] {
        
        return ["https://cdn-fitness.eztechglobal.com/test_video/1_1.mp4",
                "https://cdn-fitness.eztechglobal.com/test_video/1_2.mp4",
                "https://cdn-fitness.eztechglobal.com/test_video/1_3.mp4",
                "https://cdn-fitness.eztechglobal.com/test_video/1_4.mp4"]
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            PlayerCoordinator(urls: urls)
                .frame(width: widthDevice, height: heightDevice)
                .background(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .ignoresSafeArea()
    
    }
}

