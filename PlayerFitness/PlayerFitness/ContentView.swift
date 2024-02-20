//
//  ContentView.swift
//  PlayerFitness
//
//  Created by MAC on 02/02/2024.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

struct ContentView: View {
    
    var urls: [String] {
        
        return ["https://cdn-fitness.eztechglobal.com/test_video/1_1.mp4",
                "https://cdn-fitness.eztechglobal.com/test_video/1_1.mp4",
                "https://cdn-fitness.eztechglobal.com/test_video/1_1.mp4",
                "https://cdn-fitness.eztechglobal.com/test_video/1_1.mp4"]
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            PlayerCoordinator(urls: urls)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .ignoresSafeArea()
        }
        
        
    }
    
    
    
    
    
}

