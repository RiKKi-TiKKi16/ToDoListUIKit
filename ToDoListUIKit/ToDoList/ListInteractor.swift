//
//  ListInteractor.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

//MARK: - Services protocols
protocol ListNetworkProtocol: AnyObject {
    func loadToDos(completion: @escaping (ResultCompletion<[APIModel]>) -> Void)
}




protocol ListInteractorOutputProtocol: AnyObject {
    func deliverData(_ data: [APIModel])
    func deliverError(_ error: Error)
}

class ListInteractor: ListInteractorProtocol {

    weak var presenter: ListInteractorOutputProtocol?
    var networkManager: ListNetworkProtocol?
    
    
    func loadData() {
        networkManager?.loadToDos{ [weak self] result in
            switch result {
            case .success(let data): self?.presenter?.deliverData(data)
            case .failure(let error): self?.presenter?.deliverError(error)
            }
        }
    }
}
