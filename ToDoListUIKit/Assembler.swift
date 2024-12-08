//
//  Assembler.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 02.12.2024.
//

import UIKit

protocol StartAssemblerProtocol: AnyObject {
    func createNavController() -> UINavigationController
}
protocol ListAssemblerProtocol {
    func createToDoListViewController() -> UIViewController
}
protocol DetailAssemblerProtocol {
    func createToDoDetailViewController(id: String?) -> UIViewController
}

//Assembler - Конструктор. Собирает объекты и раздает зависимости.
class Assembler {
    var router: Router!
    let networkManager: NetworkManager
    let localStorage: CoreDataManager
    
    init(networkManager: NetworkManager, localStorage: CoreDataManager) {
        self.networkManager = networkManager
        self.localStorage = localStorage
    }
}

extension Assembler: StartAssemblerProtocol {
    func createNavController() -> UINavigationController {
        let navVC = UINavigationController(rootViewController: createToDoListViewController())
        navVC.navigationBar.barStyle = .black
        navVC.navigationBar.prefersLargeTitles = true
        navVC.navigationBar.tintColor = .accentYellow
        return navVC
    }
}
extension Assembler: ListAssemblerProtocol {
    func createToDoListViewController() -> UIViewController {
        let vc = ListViewController()
        let presenter = ListPresenter()
        presenter.router = router
        vc.presenter = presenter
        presenter.view = vc
        
        let interactor = ListInteractor()
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        interactor.networkManager = networkManager
        interactor.localStore = localStorage
        
        return vc
    }
}

extension Assembler: DetailAssemblerProtocol {
    func createToDoDetailViewController(id: String?) -> UIViewController {
        let vc = DetailViewController()
        
        let presenter = DetailPresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        let interactor = DetailInteractor(id: id)
        interactor.presenter = presenter
        interactor.localStore = localStorage
        
        presenter.interactor = interactor
        
        return vc
    }
}
