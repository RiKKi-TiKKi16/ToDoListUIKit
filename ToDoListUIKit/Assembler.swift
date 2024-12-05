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
    
    
}

extension Assembler: StartAssemblerProtocol {
    func createNavController() -> UINavigationController {
        let navVC = UINavigationController(rootViewController: createToDoListViewController())
        
        navVC.navigationBar.prefersLargeTitles = true
        //navVC.navigationBar.isTranslucent = true
        
        navVC.navigationBar.barStyle = .black
        
        
        return navVC
    }
}
extension Assembler: ListAssemblerProtocol {
    func createToDoListViewController() -> UIViewController {
        let vc = ListViewController()
        return vc
    }
}
