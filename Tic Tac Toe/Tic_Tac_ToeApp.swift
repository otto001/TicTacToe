//
//  Tic_Tac_ToeApp.swift
//  Tic Tac Toe
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI

@main
struct Tic_Tac_ToeApp: App {
    @StateObject var viewModel = TicTacToeViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
