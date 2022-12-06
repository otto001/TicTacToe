//
//  TicTacToeGrid.swift
//  Tic Tac Toe App
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI


struct TileView: View {
    let playerData: PlayerData?
    let action: () -> Void
    
    var body: some View {
        ZStack {
            if let playerData = playerData {
                
                Image(systemName: playerData.symbol)
                    .resizable()
                    .foregroundColor(playerData.color.swiftUI)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(0.4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background()
        .onTapGesture {
            action()
        }
    }
}

struct TicTacToeGridView: View {
    @EnvironmentObject var viewModel: TicTacToeViewModel
    
    func tileView(for position: GameModel.TicTacToeGrid.Position) -> TileView {
        
        var playerData: PlayerData?
        if let player = viewModel.grid[position] {
            playerData = viewModel.playerData(for: player)
        }
        
        return TileView(playerData: playerData) {
            if viewModel.didTap(position) {
                #if os(watchOS)
                    WKInterfaceDevice.current().play(.click)
                #endif
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 1) {
            ForEach(0..<3) { i in
                HStack(spacing: 1) {
                    ForEach(0..<3) { j in
                        tileView(for: .init(row: i, col: j))
                    }
                }
            }
        }
        .background(Color.gray)
    }
}


struct TicTacToeGridView_Previews: PreviewProvider {
    static var previews: some View {

        return TicTacToeGridView().environmentObject(TicTacToeViewModel.previewOngoing)
    }
}
