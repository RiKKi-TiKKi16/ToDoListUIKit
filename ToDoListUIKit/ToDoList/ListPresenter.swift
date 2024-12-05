//
//  ListPresenter.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

protocol ListViewProtocol: AnyObject {
    func deliver(_ data:[ListItemEntity])
}

protocol ListInteractorProtocol {
    func loadData()
}

class ListPresenter: ListPresenterProtocol, ListInteractorOutputProtocol {

    
    
    weak var view: ListViewProtocol?
    var interactor: ListInteractorProtocol?
    
    func loadData() {
        interactor?.loadData()
    }
    
    func deliverData(_ data: [ListItemEntity]) {
        view?.deliver(data)
    }
    
    func deliverError(_ error: any Error) {
        //
    }

    
}
