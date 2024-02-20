//
//  GetReadyView.swift
//  PlayerFitness
//
//  Created by MAC on 20/02/2024.
//

import SwiftUI

struct GetReadyView: View {
                         
    @StateObject private var viewModel = PlayerViewModel.shared
    
    var body: some View {
        if viewModel.isShowingReadyView {
            
            Text(viewModel.textReady)
                .foregroundColor(.black)
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        }
    }
}

