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
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
}

extension Assembler: StartAssemblerProtocol {
    func createNavController() -> UINavigationController {
        let navVC = UINavigationController(rootViewController: createToDoListViewController())
        //navVC.navigationBar.isTranslucent = true
        navVC.navigationBar.barStyle = .black
        navVC.navigationBar.prefersLargeTitles = true
        return navVC
    }
}
extension Assembler: ListAssemblerProtocol {
    func createToDoListViewController() -> UIViewController {
        let vc = ListViewController()
        let presenter = ListPresenter()
        vc.presenter = presenter
        presenter.view = vc
        
        let interactor = ListInteractor()
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        interactor.networkManager = networkManager
        
        return vc
    }
}
