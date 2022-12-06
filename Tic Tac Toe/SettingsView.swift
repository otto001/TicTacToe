//
//  SettingsView.swift
//  Tic Tac Toe
//
//  Created by Matteo Ludwig on 30.11.22.
//

import SwiftUI

struct PlayerNameField: View {
    let title: String
    @Binding var name: String
    
    var body: some View {
        HStack {
            Text(title).frame(width: 100, alignment: .leading)
            
            TextField("", text: $name)
                .autocorrectionDisabled()
        }
    }
}

struct SettingsView: View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var viewModel: TicTacToeViewModel
    
    private var isEditing: Bool {
        return editMode?.wrappedValue.isEditing ?? false
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Player Names") {
                    TextField("\(viewModel.playerOneData.colorName)'s Name", text: $viewModel.playerOneData.name)
                        .autocorrectionDisabled()
                        .disabled(!isEditing)
                        .foregroundColor(isEditing ? viewModel.playerOneData.color.swiftUI : Color.gray)
                    
                    TextField("\(viewModel.playerTwoData.colorName)'s Name", text: $viewModel.playerTwoData.name)
                        .autocorrectionDisabled()
                        .disabled(!isEditing)
                        .foregroundColor(isEditing ? viewModel.playerTwoData.color.swiftUI : Color.gray)
                }
            }
            .animation(nil, value: editMode?.wrappedValue)
            .toolbar {
                // Unfortunately, the EditMode button provided by SwiftUI
                // appears to be broken at the time writing this, so we opt to implement a clone of it.
                Button {
                    if isEditing {
                        editMode?.wrappedValue = .inactive
                        viewModel.commitSettings()
                    } else {
                        editMode?.wrappedValue = .active
                    }
                } label: {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
            .navigationTitle("Settings")
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(TicTacToeViewModel())
    }
}
