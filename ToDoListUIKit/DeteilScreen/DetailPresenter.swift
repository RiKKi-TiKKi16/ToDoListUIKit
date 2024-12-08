//
//  DetailPresenter.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 07.12.2024.
//

import Foundation

protocol DetailInteractorProtocol {
    var title: String { get set }
    var description: String { get set }
    var date: Date { get }
    func loadData()
}

protocol DetailViewProtocol: AnyObject {
    func showData()
}

class DetailPresenter {
    var interactor: DetailInteractorProtocol?
    weak var view: DetailViewProtocol?
}

extension DetailPresenter: DetailPresenterProtocol {
    func prepare() {
        interactor?.loadData()
    }
    
    var title: String {
        get { interactor?.title ?? String() }
        set { interactor?.title = newValue }
    }
    
    var description: String {
        get { interactor?.description ?? String() }
        set { interactor?.description = newValue }
    }
    
    var date: Date { interactor?.date ?? Date() }
}
extension DetailPresenter: DetailInteractorOutputProtocol {
    func presentData() {
        view?.showData()
    }
}


