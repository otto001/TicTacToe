//
//  GameFinishedView.swift
//  Tic Tac Toe
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI

struct GameFinishedView: View {
    @EnvironmentObject var viewModel: TicTacToeViewModel
    
    
    var text: Text? {
        switch viewModel.gameState {
        case .victory(let winner):
            let playerData = viewModel.playerData(for: winner)
            return Text("\(playerData.name) wins!")
                .foregroundColor(playerData.color.swiftUI)
            
        case .tie:
            return Text("Tie!")
        default:
            return nil
        }
    }
    
    @ViewBuilder var content: some View {
        if let text = text {
            
            VStack {
                text
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                
                Text("Tap to restart")
                    .foregroundColor(.white)
                    .font(.footnote)
                    .padding(.bottom)
                    .padding(.horizontal)
            }
            .onTapGesture {
                viewModel.restart()
            }
        }
    }
    
    var body: some View {
        #if os(watchOS)
            content.background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.12))
                    .opacity(1)
            }
        #else
            content.background(Material.regular).clipShape(RoundedRectangle(cornerRadius: 12))
        #endif

    }
    
}

struct GameFinishedView_Previews: PreviewProvider {
    static var previews: some View {
        GameFinishedView().environmentObject(TicTacToeViewModel.previewVictory)
    }
}
