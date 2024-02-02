//
//  PlayerCoordinator.swift
//  PlayerFitness
//
//  Created by MAC on 02/02/2024.
//

import SwiftUI

struct PlayerCoordinator: UIViewControllerRepresentable {
    
    //    @Binding var isShowTabView: Bool
    let urls: [String]
    
    func makeUIViewController(context: Context) -> PlayerController {
        return PlayerController(urls: urls)
    }
    
    func updateUIViewController(_ uiViewController: PlayerController, context: Context) {
        
    }
    
}

