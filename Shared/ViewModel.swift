//
//  ViewModel.swift
//  Tic Tac Toe WatchKit Extension
//
//  Created by Matteo Ludwig on 30.11.22.
//

import Foundation
import SwiftUI
import WatchConnectivity


struct PlayerData: Identifiable, Equatable, Hashable, Codable {
    enum PlayerColor: Codable {
        case red, blue
        
        var swiftUI: Color {
            switch self {
            case .red:
                return .red
            case .blue:
                return .blue
            }
        }
    }

    
    var id: String {
        colorName
    }
    
    static func == (lhs: PlayerData, rhs: PlayerData) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var name: String
    let color: PlayerColor
    let colorName: String
    let symbol: String
    
    init(name: String, color: PlayerColor, colorName: String, symbol: String) {
        self.name = name
        self.color = color
        self.colorName = colorName
        self.symbol = symbol
    }
}


struct GameModel: Codable {
    enum State: Hashable, Codable {
        case victory(Player)
        case tie
        case ongoing
    }
    
    enum Player: String, Codable {
        case one = "playerOne"
        case two = "playerTwo"
    }
    
    struct TicTacToeGrid: Codable {
        struct Position {
            let row: Int
            let col: Int
        }
        
        private var array: [Player?]
        
        init() {
            array = .init(repeating: nil, count: 3*3)
        }
        
        subscript(position: Position) -> Player? {
            get {
                return array[position.row*3 + position.col]
            }
            set {
                array[position.row*3 + position.col] = newValue
            }
        }
        
        var isFull: Bool {
            return array.allSatisfy {$0 != nil}
        }
    }
    
    var grid = TicTacToeGrid()
    var state: State = .ongoing
    var currentPlayer: Player = .one
    
    
    var timestamp: Date = .now

    
    init() {
        self.reset()
    }
    
    mutating func reset() {
        grid = TicTacToeGrid()
        state = .ongoing
        currentPlayer = Bool.random() ? .one : .two
        timestamp = .now
    }
    
    
    private func checkPath(_ path: [TicTacToeGrid.Position]) -> Player? {
        guard let player = grid[path[0]] else {
            return nil
        }
        
        for position in path[1...] {
            guard grid[position] == player else {
                return nil
            }
        }
        return player
    }
    
    mutating private func checkWin() {
        
        let rows = (0..<3).map { row in (0..<3).map {col in TicTacToeGrid.Position(row: row, col: col)}}
        let cols = (0..<3).map { col in (0..<3).map {row in TicTacToeGrid.Position(row: row, col: col)}}
        let diagonal1 = (0..<3).map {TicTacToeGrid.Position(row: $0, col: $0)}
        let diagonal2 = (0..<3).map {TicTacToeGrid.Position(row: $0, col: 2-$0)}
        
        let allPaths = [rows, cols, [diagonal1, diagonal2]].joined()
        
        for path in allPaths {
            if let winner = checkPath(path) {
                state = .victory(winner)
                return
            }
        }
        
        if grid.isFull {
            state = .tie
        }
    }
    
    mutating func didTap(_ position: TicTacToeGrid.Position) -> Bool {
        guard state == .ongoing && grid[position] == nil else {return false}
        
        grid[position] = currentPlayer
        checkWin()
        
        if self.state == .ongoing {
            let nextPlayer: Player = (currentPlayer == .one) ? .two : .one
            currentPlayer = nextPlayer
        }
        
        timestamp = .now
        return true
    }
}

class TicTacToeViewModel: NSObject, ObservableObject {
    @Published private var model = GameModel()
    
    @Published var playerOneData = PlayerData(name: "Blue", color: .blue, colorName: "Blue", symbol: "circle")
    @Published var playerTwoData = PlayerData(name: "Red", color: .red, colorName: "Red", symbol: "xmark")
    
    var gameState: GameModel.State {
        self.model.state
    }

    var grid: GameModel.TicTacToeGrid {
        self.model.grid
    }
    
    var currentPlayerData: PlayerData {
        return self.playerData(for: self.model.currentPlayer)
    }
    
    @Published var wcSessionGood: Bool = false
    
    
    override init() {
        super.init()
        self.setupWC()
    }
    
    func playerData(for player: GameModel.Player) -> PlayerData {
        switch player {
        case .one:
            return self.playerOneData
        case .two:
            return self.playerTwoData
        }
    }
    
    func didTap(_ position: GameModel.TicTacToeGrid.Position) -> Bool {
        guard self.model.didTap(position) else {
            return false
        }
        self.sendGameModel()
        return true
    }
    
    func restart() {
        self.model.reset()
        self.sendGameModel()
    }
    
    
    func commitSettings() {
        self.sendSettings()
    }
}

// MARK: WatchConnectivity

extension TicTacToeViewModel: WCSessionDelegate {
    private var wcSession: WCSession? {
        WCSession.isSupported() ? WCSession.default : nil
    }
    
    func setupWC() {
        self.wcSession?.delegate = self
        self.wcSession?.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
#if os(iOS)
        if activationState == .activated{
            self.sendSettings()
        }
#endif
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.wcSessionGood = self.wcSession?.isReachable ?? false
            
            if self.wcSessionGood {
                self.sendGameModel()
            }
        }
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
#endif

    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let decoder = JSONDecoder()
        DispatchQueue.main.async {
            self.playerOneData = try! decoder.decode(PlayerData.self, from: applicationContext[GameModel.Player.one.rawValue] as! Data)
            self.playerTwoData = try! decoder.decode(PlayerData.self, from: applicationContext[GameModel.Player.two.rawValue] as! Data)
        }
    }
    
    func sendSettings() {
        do {
            let encoder = JSONEncoder()
            try self.wcSession?.updateApplicationContext([
                GameModel.Player.one.rawValue: try! encoder.encode(self.playerOneData),
                GameModel.Player.two.rawValue: try! encoder.encode(self.playerTwoData)
            ])
        } catch {
            print(error)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        guard let remoteGameModel = try? JSONDecoder().decode(GameModel.self, from: message["model"] as! Data) else {
            return
        }
        
        DispatchQueue.main.async {
            if remoteGameModel.timestamp > self.model.timestamp {
                self.model = remoteGameModel
            }
        }
    }
    
    func sendGameModel() {
        guard self.wcSession?.isReachable == true else { return }
        let encoder = JSONEncoder()
        
        self.wcSession?.sendMessage([
            "model": try! encoder.encode(self.model),
        ], replyHandler: nil)
    }
    
}

// MARK: Preview Instances
extension TicTacToeViewModel {
    static var previewVictory: TicTacToeViewModel {
        let vm = TicTacToeViewModel()
        vm.model.state = .victory(.one)
        return vm
    }
    
    static var previewOngoing: TicTacToeViewModel {
        let vm = TicTacToeViewModel()
        vm.model.grid[.init(row: 0, col: 0)] = .one
        vm.model.grid[.init(row: 0, col: 1)] = .two
        vm.model.grid[.init(row: 1, col: 2)] = .one
        return vm
    }
}
