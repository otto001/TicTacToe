//
//  ContentView.swift
//  Tic Tac Toe
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: TicTacToeViewModel
    
    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Play", systemImage: "grid")
                }
            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "gear")
                }
        }
        .overlay(alignment: .topLeading) {
            if !viewModel.wcSessionGood {
                Image(systemName: "applewatch.slash")
                    .foregroundColor(.red)
                    .padding(.top, 20)
                    .padding(.leading)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        return ContentView().environmentObject(TicTacToeViewModel.previewVictory)
    }
}
