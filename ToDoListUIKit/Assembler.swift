//
//  Assembler.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 02.12.2024.
//

import UIKit

protocol StartAssembler_P: AnyObject {
    func createNavController() -> UINavigationController
}
protocol ListAssembler_P {
    func createToDoListViewController() -> UIViewController
}
protocol DetailAssembler_P {
    func createToDoDetailViewController(id: String?) -> UIViewController
}

//Assembler - Конструктор. Собирает объекты и раздает зависимости.
class Assembler {
    
    
}

extension Assembler: StartAssembler_P {
    func createNavController() -> UINavigationController {
        let navVC = UINavigationController(rootViewController: createToDoListViewController())
        return navVC
    }
}
extension Assembler: ListAssembler_P {
    func createToDoListViewController() -> UIViewController {
        let vc = ListViewController()
        //vc.view.backgroundColor = .magenta
        return vc
    }
}
