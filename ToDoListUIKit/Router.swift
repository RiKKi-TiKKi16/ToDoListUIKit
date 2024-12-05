//
//  Router.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 02.12.2024.
//

import UIKit

protocol StartRouterProtocol: AnyObject {
    func start()
}
protocol ListRouterProtocol {}

protocol DetailRouterProtocol {}

//Router - Экспонент. Отвечает за переходы и отображение экранов/модулей.
class Router: StartRouterProtocol {
    let assembler: StartAssemblerProtocol
    let window: UIWindow
    var navController: UINavigationController!
    
    init(assembler: StartAssemblerProtocol, window: UIWindow) {
        self.assembler = assembler
        self.window = window
    }
    
    func start() {
        navController = assembler.createNavController()
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}
