//
//  TrelloApi.swift
//  trello
//
//  Created by Jan Christophersen on 25.09.22.
//

import Foundation
import Combine

class TrelloApi: ObservableObject {
    let key: String;
    let token: String;
    
    @Published var board: Board;
    @Published var boards: [BasicBoard];
    
    init(key: String, token: String) {
        self.key = key
        self.token = token
        self.board = Board(id: "", name: "", prefs: BoardPrefs())
        self.boards = []
    }
    
    static var DateFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter
    }
    
    func getBoards(completion: @escaping ([BasicBoard]) -> Void = { boards in }) {
        guard let url = URL(string: "https://api.trello.com/1/members/me/boards?key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedBoards = try JSONDecoder().decode([BasicBoard].self, from: data)
                        
                        self.boards = decodedBoards
                        completion(self.boards)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print("Status code: ", response.statusCode)
            }
        }
        
        dataTask.resume()
    }
    
    func getBoard(id: String, completion: @escaping (Board) -> Void = { board in }) {
        guard let url = URL(string: "https://api.trello.com/1/boards/\(id)?labels=all&cards=open&lists=open&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        var decodedBoard = try JSONDecoder().decode(Board.self, from: data)
                        
                        var listMap = Dictionary(uniqueKeysWithValues: decodedBoard.lists.map{ ($0.id, $0) })
                        
                        for card in decodedBoard.cards {
                            listMap[card.idList]!.cards.append(card);
                        }
                        
                        for var (i, list) in decodedBoard.lists.enumerated() {
                            list.cards = listMap[list.id]!.cards
                            decodedBoard.lists[i] = list
                        }
                        
                        self.objectWillChange.send()
                        self.board = decodedBoard
                        completion(self.board)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print("Status code: ", response.statusCode)
            }
        }
        
        dataTask.resume()
    }
    
    func markAsDone(card: Card, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void) {
        guard let doneLabel = self.board.labels.first(where: { label in label.name == "done"}) else {
            fatalError("No done label exists")
        }
        
        let newLabels = card.idLabels + [doneLabel.id]
        
        guard let url = URL(string: "https://api.trello.com/1/cards/\(card.id)?idLabels=\(newLabels.joined(separator: ","))&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let newCard = try JSONDecoder().decode(Card.self, from: data)
                        
                        completion(newCard)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
                
                DispatchQueue.main
                    .schedule(
                        after: .init(.now() + 5),
                        tolerance: .seconds(1),
                        options: nil
                    ) {
                        after_timeout()
                    }
            }
        }
        
        dataTask.resume()
    }
}
