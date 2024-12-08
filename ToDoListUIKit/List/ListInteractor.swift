//
//  ListInteractor.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

//MARK: - Services protocols - Network
protocol ListNetworkProtocol: AnyObject {
    func loadTodos(completion: @escaping (ResultCompletion<[TodoAPIModel]>) -> Void)
}

//MARK: - Services protocols - CoreData
protocol CreateInLocalStorageProtocol {
    func createTodos(containsOf: [(id: String, title: String, subtitle: String, completed: Bool)])
}

protocol FetchFromLocalStorageProtocol {
    func fetchTodos(callback: @escaping ([ListItemLocalStore]) -> ())
}

protocol DeleteItemInLocalStorageProtocol {
    func deleteTodo(id: String)
}

protocol ChangesTaskInLocalStorageProtocol {
    func editStatus(status: Bool, todoId: String)
    func editTodo(id: String, title: String, subtitle: String, date: Date)
}


protocol ListInteractorOutputProtocol: AnyObject {
    func deliverData(_ data: [ListItemEntity])
    func deliverError(_ error: Error)
    func presentLoading(_ isLoading: Bool)
}


class ListInteractor {
    private var list: [ListItemEntity] = []
    var networkManager: ListNetworkProtocol?
    var localStore: (CreateInLocalStorageProtocol & ChangesTaskInLocalStorageProtocol & FetchFromLocalStorageProtocol & DeleteItemInLocalStorageProtocol)?
    weak var presenter: ListInteractorOutputProtocol?
    
    private func deliverTodos() {
        DispatchQueue.main.async {
            self.presenter?.deliverData(self.list)
        }
    }
}

//MARK: - ListInteractorProtocol
extension ListInteractor: ListInteractorProtocol {
    
    func loadData() {
        
        localStore?.fetchTodos(callback: {[weak self] localList in
            
            if localList.isEmpty {
                DispatchQueue.main.async {
                    self?.presenter?.presentLoading(true)
                }
                
                self?.networkManager?.loadTodos { result in
                    self?.presenter?.presentLoading(false)
                    
                    switch result {
                    case .success(let todos):
                        let serverTodos = todos.map({ ListItemEntity(dto: $0) })
                        let filtered = serverTodos.filter { self?.list.contains($0) == false }
                        self?.list.append(contentsOf: filtered)
                        self?.deliverTodos()
                        
                        let mapped = filtered.map({ return ($0.id, $0.title, $0.subtitle, $0.completed) })
                        
                        self?.localStore?.createTodos(containsOf: mapped)
                        
                    case .failure(let error): self?.presenter?.deliverError(error)
                    }
                }
            } else {
                self?.list = localList.map({ ListItemEntity(local: $0) })
                self?.deliverTodos()
            }
        })
    }
    
    func editStatus(completed: Bool, item: ListItemEntity) {
        localStore?.editStatus(status: completed, todoId: item.id)
    }
    
    func delete(item: ListItemEntity) {
        localStore?.deleteTodo(id: item.id)
        guard let index = list.firstIndex(of: item) else { return }
        list.remove(at: index)
    }
    
    func search(text: String) {
        if text.isEmpty {
            presenter?.deliverData(list)
        } else {
            let filter = list.filter({ $0.title.contains(text) || $0.subtitle.contains(text) })
            presenter?.deliverData(filter)
        }
    }
}

//MARK: - extension ListItemEntity
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
