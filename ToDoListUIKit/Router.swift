//
//  Router.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 02.12.2024.
//

import UIKit

protocol StartRouter_P: AnyObject {
    func start()
}
protocol ListRouter_P {}

protocol DetailRouter_P {}

//Router - Экспонент. Отвечает за переходы и отображение экранов/модулей.
class Router: StartRouter_P {
    let assembler: StartAssembler_P
    let window: UIWindow
    var navController: UINavigationController!
    
    init(assembler: StartAssembler_P, window: UIWindow) {
        self.assembler = assembler
        self.window = window
    }
    
    func start() {
        navController = assembler.createNavController()
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}
