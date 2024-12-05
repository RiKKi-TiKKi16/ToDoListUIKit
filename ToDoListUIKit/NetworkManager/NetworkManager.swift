//
//  NetworkManager.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

typealias ResultCompletion<T> = Result<T, Error>

class NetworkManager {
    let url: URL
    
    init(urlString: String) {
        self.url = URL(string: urlString)!
    }
    
    func createRequest(appendedPathComponent component: String) -> URLRequest {
        return URLRequest(url: url.appending(component: component))
    }
    
    func executeRequest<T: Decodable>(_ request: URLRequest, type: T.Type, completion: @escaping (ResultCompletion<T>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let data {
                do {
                    let object = try JSONDecoder().decode(type, from: data)
                    DispatchQueue.main.async {completion(.success(object))}
                } catch let decodeError {
                    DispatchQueue.main.async {completion(.failure(decodeError))}
                }
            } else if let error {
                DispatchQueue.main.async {completion(.failure(error))}
            }
        }
        task.resume()
    }
}

extension NetworkManager: ListNetworkProtocol {
    func loadToDos(completion: @escaping (ResultCompletion<[APIModel]>) -> Void) {
        let request = createRequest(appendedPathComponent: "todos")
        executeRequest(request, type: Forma.self) { result in
            switch result {
            case .success(let forma):
                completion(.success(forma.todos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
