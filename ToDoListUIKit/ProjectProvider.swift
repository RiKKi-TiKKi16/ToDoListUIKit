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
    let router: StartRouterProtocol
    
    init(window: UIWindow) {
        let networkManager = NetworkManager(urlString: "https://dummyjson.com")
        let assembler = Assembler(networkManager: networkManager)
        let router = Router(assembler: assembler, window: window)
        
        self.router = router
        //assembler.router = router
    }
    
    func start() {
        router.start()
    }
}
