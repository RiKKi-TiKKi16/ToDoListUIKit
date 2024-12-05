//
//  ListInteractor.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

//MARK: - Services protocols
protocol ListNetworkProtocol: AnyObject {
    func loadTodos(completion: @escaping (ResultCompletion<[TodoAPIModel]>) -> Void)
}

protocol CreateListInLocalStorageProtocol {
    func createTodos(containsOf: [(id: String, title: String, subtitle: String, completed: Bool)])
}

protocol ChangeStatusTaskInLocalStorageProtocol {
    func setCompleted(status: Bool, todoId: String)
}

protocol FetchFromLocalStorageProtocol {
    func fetchTodos(callback: @escaping ([ListItemLocalStore]) -> ())
}


protocol ListInteractorOutputProtocol: AnyObject {
    func deliverData(_ data: [ListItemEntity])
    func deliverError(_ error: Error)
}

class ListInteractor: ListInteractorProtocol {

    weak var presenter: ListInteractorOutputProtocol?
    var networkManager: ListNetworkProtocol?
    var localStore: (CreateListInLocalStorageProtocol & ChangeStatusTaskInLocalStorageProtocol & FetchFromLocalStorageProtocol)?
    
    private let lock = NSLock()
    private var list: [ListItemEntity] = [] {
        willSet {
            lock.lock()
        }
        
        didSet {
            lock.unlock()
        }
    }
    
    func loadData() {
        
        let group = DispatchGroup()
        
        group.enter()
        localStore?.fetchTodos(callback: {[weak self] localList in
            self?.list = localList.map({ ListItemEntity(local: $0) })
            group.leave()
        })
        
        if list.isEmpty {
            group.enter()
            networkManager?.loadTodos { [weak self] result in
                switch result {
                case .success(let todos):
                    let serverTodos = todos.map({ ListItemEntity(dto: $0) })
                    let filtered = serverTodos.filter { self?.list.contains($0) == false }
                    self?.list.append(contentsOf: filtered)
                    
                    let mapped = filtered.map({ return ($0.id, $0.title, $0.subtitle, $0.completed) })
                    
                    self?.localStore?.createTodos(containsOf: mapped)
                    
                case .failure(let error): self?.presenter?.deliverError(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main, execute: {
            self.deliverTodos()
        })
    }
    
    private func deliverTodos() {
        presenter?.deliverData(list)
    }
}

private extension ListItemEntity {
    init(dto: TodoAPIModel) {
        self.id = String(dto.id)
        self.title = dto.todo
        self.subtitle = ""
        self.date = Date()
        self.completed = dto.completed
    }
    
    init(local: ListItemLocalStore) {
        self.id = local.id ?? ""
        self.title = local.title ?? ""
        self.subtitle = local.subtitle ?? ""
        self.date = Date(timeIntervalSince1970: local.date)
        self.completed = local.completed
    }
}
