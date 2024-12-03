//
//  ProjectProvider.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 02.12.2024.
//

import UIKit

//ProjectProvider - Тамбур. Собирает базовые сущьности: router, assembler. Прокидывает окно в router.
//Дополнительный слой для оптимизации.
class ProjectProvider {
    let router: StartRouter_P
    
    init(window: UIWindow) {
        let assembler = Assembler()
        let router = Router(assembler: assembler, window: window)
        
        self.router = router
        //assembler.router = router
    }
    
    func start() {
        router.start()
    }
}
