//
//  DetailInteractor.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 07.12.2024.
//

import Foundation

protocol DetailInteractorOutputProtocol: AnyObject {
    func presentData()
}

protocol FindTodoInLocalStore {
    func findTodo(id: String, callback: @escaping (ListItemLocalStore) -> ())
}

class DetailInteractor {
    var localStore: (CreateInLocalStorageProtocol & FindTodoInLocalStore & ChangesTaskInLocalStorageProtocol)?
    weak var presenter: DetailInteractorOutputProtocol?
    let id: String?
    private var createdId: UUID?
    
    var title = String() {
        didSet {
            save()
        }
    }
    
    var description = String() {
        didSet {
            save()
        }
    }
    
    var date = Date()
    
    init(id: String?) {
        self.id = id
    }
}

extension DetailInteractor: DetailInteractorProtocol {
    func loadData() {
        guard let id else { return }
        localStore?.findTodo(id: id, callback: {[weak self] item in
            self?.title = item.title ?? String()
            self?.description = item.subtitle ?? String()
            self?.date = Date(timeIntervalSince1970: item.date)
            
            DispatchQueue.main.async {
                self?.presenter?.presentData()
            }
        })
    }
    
    private func createTodo() {
        
    }
    
    func save() {
        if id == nil && createdId == nil {
            let createdId = UUID()
            self.createdId = createdId
            localStore?.createTodos(containsOf: [(id: createdId.uuidString,
                                                  title: title,
                                                  subtitle: description,
                                                  completed: false)])
        } else if let id = id ?? createdId?.uuidString {
            localStore?.editTodo(id: id,
                                 title: title,
                                 subtitle: description,
                                 date: date)
        }
        
    }
}

