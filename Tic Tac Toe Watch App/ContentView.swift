//
//  ContentView.swift
//  Tic Tac Toe WatchKit Extension
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI
import UIKit


struct ContentView: View {
    @EnvironmentObject var viewModel: TicTacToeViewModel
    
    var grid: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            VStack {
                Spacer()
                TicTacToeGridView()
                .frame(width: size, height: size)
            }
        }
        .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
        .navigationTitle {
            Text("\(viewModel.currentPlayerData.name)'s turn")
                .foregroundColor(viewModel.currentPlayerData.color.swiftUI)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    var body: some View {
        NavigationView {
            grid
        }.overlay {
            GameFinishedView()
        }.onChange(of: viewModel.gameState) { gameState in
            switch gameState {
            case .tie:
                WKInterfaceDevice.current().play(.retry)
            case .victory:
                WKInterfaceDevice.current().play(.success)
            case .ongoing:
                WKInterfaceDevice.current().play(.start)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView().environmentObject(TicTacToeViewModel.previewVictory)
    }
}
