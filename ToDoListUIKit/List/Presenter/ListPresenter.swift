//
//  ListPresenter.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

protocol ListRouter {
    func routeToDetail(id: String?) //func createTodo() && editTodo(item: ListItemEntity)
    //func share(item: ListItemEntity)
}

protocol ListInteractorProtocol {
    func loadData()
    func editStatus(completed: Bool, item: ListItemEntity)
    func delete(item: ListItemEntity)
    func search(text: String)
}

protocol ListViewProtocol: AnyObject {
    func deliver(_ data:[ListItemEntity])
    func showLoader(isLoading: Bool)
}
//Presenter - Ядро модуля. Отвечает за связи между объектами viper модуля.
class ListPresenter {
    var router: ListRouter?
    var interactor: ListInteractorProtocol?
    weak var view: ListViewProtocol?
}

//MARK: - ListPresenterProtocol
extension ListPresenter: ListPresenterProtocol{
    
    func loadData() {
        interactor?.loadData()
    }
    
    func search(text: String) {
        interactor?.search(text: text)
    }
    
    func editStatus(completed: Bool, item: ListItemEntity) {
        interactor?.editStatus(completed: completed, item: item)
    }
    
    func edit(item: ListItemEntity) {
        router?.routeToDetail(id: item.id)
    }
    
    func share(item: ListItemEntity) {}
    
    func delete(item: ListItemEntity) {
        interactor?.delete(item: item)
    }
    
    func createTodo() {
        router?.routeToDetail(id: nil)
    }
}

//MARK: - ListInteractorOutputProtocol
extension ListPresenter: ListInteractorOutputProtocol{
    
    func deliverData(_ data: [ListItemEntity]) {
        view?.deliver(data)
    }
    
    func deliverError(_ error: any Error) {}
    
    func presentLoading(_ isLoading: Bool) {
        view?.showLoader(isLoading: isLoading)
    }
}
