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
    
    @Published var errors: Int = 0;
    
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
    
    private func addError() {
        DispatchQueue.main.async {
            self.errors += 1
        }
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
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func getBoard(id: String, completion: @escaping (Board) -> Void = { board in }) {
        guard let url = URL(string: "https://api.trello.com/1/boards/\(id)?labels=all&cards=open&lists=open&checklists=all&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
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
                        
                        if !listMap.isEmpty {
                            for card in decodedBoard.cards {
                                if var list = listMap[card.idList] {
                                    list.cards.append(card);
                                    listMap[card.idList]!.cards.append(card);
                                }
                            }
                            
                            for var (i, list) in decodedBoard.lists.enumerated() {
                                list.cards = listMap[list.id]!.cards
                                decodedBoard.lists[i] = list
                            }
                        }
                        
                        self.board = decodedBoard
                        completion(self.board)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print("Status code: ", response.statusCode)
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func getCardChecklists(id: String, completion: @escaping ([Checklist]) -> Void = { checklists in }) {
        guard let url = URL(string: "https://api.trello.com/1/cards/\(id)/checklists?key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
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
                        let decodedChecklists = try JSONDecoder().decode([Checklist].self, from: data)
                        
                        completion(decodedChecklists)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print("Status code: ", response.statusCode)
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func updateCheckItem(cardId: String, checkItem: CheckItem, completion: @escaping (CheckItem) -> Void) {
        var url = URLComponents(string: "https://api.trello.com/1/cards/\(cardId)/checkItem/\(checkItem.id)")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "name", value: checkItem.name),
            URLQueryItem(name: "state", value: checkItem.state.rawValue),
            URLQueryItem(name: "idChecklist", value: checkItem.idChecklist),
            
        ]
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
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
                        let newCheckItem = try JSONDecoder().decode(CheckItem.self, from: data)
                        
                        completion(newCheckItem)
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            } else {
                print("status code \(response.statusCode)")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func addLabelsToCard(card: Card, labelIds: [String], completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        let newLabels = card.idLabels + labelIds
        
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == newCard.id })!
                        
                        self.board.lists[listIdx].cards[cardIdx] = newCard
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
            } else {
                print("status code \(response.statusCode)")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func removeLabelsFromCard(card: Card, labelIds: [String], completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        let newLabels = card.idLabels.filter{ label in !labelIds.contains(where: { l in l == label }) }
        
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == newCard.id })!
                        
                        self.board.lists[listIdx].cards[cardIdx] = newCard
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
            } else {
                print("status code \(response.statusCode)")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func markAsDone(card: Card, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void) {
        guard let doneLabel = self.board.labels.first(where: { label in label.name == "done"}) else {
            fatalError("No done label exists")
        }
        
        self.addLabelsToCard(card: card, labelIds: [doneLabel.id], completion: completion, after_timeout: after_timeout)
    }
    
    func createList(boardId: String, name: String, completion: @escaping (List) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/lists")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "idBoard", value: boardId),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "pos", value: "bottom")
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "POST"
        
        print(url.url!)
        
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
                        let newList = try JSONDecoder().decode(List.self, from: data)
                        
                        self.board.lists.append(newList)
                        completion(newList)
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
            } else {
                print("status code \(response.statusCode)")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func archiveList(listId: String, completion: @escaping () -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/lists/\(listId)/closed")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "value", value: "true")
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "PUT"
        
        print(url.url!)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    self.board.lists = self.board.lists.filter{ l in l.id != listId }
                    completion()
                }
                
                DispatchQueue.main
                    .schedule(
                        after: .init(.now() + 5),
                        tolerance: .seconds(1),
                        options: nil
                    ) {
                        after_timeout()
                    }
            } else {
                print("status code \(response.statusCode)")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func setListName(list: List, name: String, completion: @escaping (List) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/lists/\(list.id)")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "name", value: name),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
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
                        let newList = try JSONDecoder().decode(List.self, from: data)
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == list.id })!
                        
                        self.board.lists[listIdx].name = newList.name
                        
                        completion(newList)
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
            } else {
                print("status code \(response.statusCode)")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func moveList(listId: String, pos: String, completion: @escaping (List) -> Void, after_timeout: @escaping () -> Void = {}) {
        guard let url = URL(string: "https://api.trello.com/1/lists/\(listId)?pos=\(pos)&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
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
                        let newList = try JSONDecoder().decode(List.self, from: data)
                        
                        if let listIdx = self.board.lists.firstIndex(where: {l in l.id == listId}) {
                            self.board.lists[listIdx].pos = newList.pos
                        }
                        
                        completion(newList)
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func moveCard(cardId: String, destination: String, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        guard let url = URL(string: "https://api.trello.com/1/cards/\(cardId)?idList=\(destination)&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
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
                        
                        // find old card
                        if let card = self.board.cards.first(where: { card in card.id == cardId }) {
                            
                            // Remove from old list and add to new locally
                            if let oldList = self.board.lists.firstIndex(where: { list in list.id == card.idList }) {
                                self.board.lists[oldList].cards.remove(at: self.board.lists[oldList].cards.firstIndex(of: card)!)
                            }
                        }
                        
                        if let newList = self.board.lists.firstIndex(where: { list in list.id == destination }) {
                            self.board.lists[newList].cards.append(newCard)
                        }
                        
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func setCardDue(card: Card, due: Date, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        guard let url = URL(string: "https://api.trello.com/1/cards/\(card.id)?due=\(TrelloApi.DateFormatter.string(from: due))&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == newCard.id })!
                        
                        self.board.lists[listIdx].cards[cardIdx] = newCard
                        
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func setCardDesc(card: Card, desc: String, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/cards/\(card.id)")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "desc", value: desc),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == newCard.id })!
                        
                        self.board.lists[listIdx].cards[cardIdx] = newCard
                        
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func setCardName(card: Card, name: String, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/cards/\(card.id)")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "name", value: name),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == newCard.id })!
                        
                        self.board.lists[listIdx].cards[cardIdx] = newCard
                        
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func setCardPos(card: Card, pos: Float, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        guard let url = URL(string: "https://api.trello.com/1/cards/\(card.id)?pos=\(pos)&key=\(key)&token=\(token)") else { fatalError("Missing URL") }
        
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        let cardIdx = self.board.lists[listIdx].cards.firstIndex(where: { c in c.id == newCard.id })!
                        
                        self.board.lists[listIdx].cards[cardIdx] = newCard
                        
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func createCard(list: List, name: String, description : String, completion: @escaping (Card) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/cards")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "idList", value: list.id),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "desc", value: description),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "POST"
        
        print(url.url!)
        
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
                        
                        let listIdx = self.board.lists.firstIndex(where: { l in l.id == newCard.idList })!
                        
                        self.board.lists[listIdx].cards.append(newCard)
                        
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func createChecklist(name: String, cardId: String, completion: @escaping (Checklist) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/checklists")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "idCard", value: cardId),
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "pos", value: "bottom"),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "POST"
        
        print(url.url!)
        
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
                        let checklist = try JSONDecoder().decode(Checklist.self, from: data)
                        
                        completion(checklist)
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func addCheckItem(checklistId: String, name: String, completion: @escaping (CheckItem) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/checklists/\(checklistId)/checkItems")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "name", value: name),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "POST"
        
        print(url.url!)
        
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
                        let checkItem = try JSONDecoder().decode(CheckItem.self, from: data)
                        
                        completion(checkItem)
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func setCheckItemName(cardId: String, checklistId: String, checkItemId: String, name: String, completion: @escaping (CheckItem) -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/cards/\(cardId)/checklist/\(checklistId)/checkItem/\(checkItemId)")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
            URLQueryItem(name: "name", value: name),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "PUT"
        
        print(url.url!)
        
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
                        let checkItem = try JSONDecoder().decode(CheckItem.self, from: data)
                        
                        completion(checkItem)
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
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
    
    func deleteChecklist(checklistId: String, completion: @escaping () -> Void, after_timeout: @escaping () -> Void = {}) {
        var url = URLComponents(string: "https://api.trello.com/1/checklists/\(checklistId)")!
        
        url.queryItems = [
            URLQueryItem(name: "key", value: self.key),
            URLQueryItem(name: "token", value: self.token),
        ]
        
        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var urlRequest = URLRequest(url: url.url!)
        urlRequest.httpMethod = "DELETE"
        
        print(url.url!)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                completion()
                
                DispatchQueue.main
                    .schedule(
                        after: .init(.now() + 5),
                        tolerance: .seconds(1),
                        options: nil
                    ) {
                        after_timeout()
                    }
            } else {
                print("status code \(response.statusCode) \(String(decoding: data!, as: UTF8.self))")
                self.addError()
            }
        }
        
        dataTask.resume()
    }
}
