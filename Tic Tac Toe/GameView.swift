//
//  GameView.swift
//  Tic Tac Toe
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewModel: TicTacToeViewModel
    
    var body: some View {
        VStack {
            Text("\(viewModel.currentPlayerData.name)'s turn")
                .font(.largeTitle)
                .foregroundColor(viewModel.currentPlayerData.color.swiftUI)
                .padding()
            TicTacToeGridView()
                .border(.gray)
                .overlay {
                    GameFinishedView()
                }
            Spacer()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView().environmentObject(TicTacToeViewModel.previewOngoing)
    }
}
