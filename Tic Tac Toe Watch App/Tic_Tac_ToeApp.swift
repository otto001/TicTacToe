//
//  Tic_Tac_ToeApp.swift
//  Tic Tac Toe WatchKit Extension
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI

@main
struct Tic_Tac_ToeApp: App {
    var viewModel = TicTacToeViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(viewModel)
            }
        }
    }
}
