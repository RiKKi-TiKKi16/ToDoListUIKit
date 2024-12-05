//
//  CoreDataManager.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    private var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    
    
    func fetchList<T: NSManagedObject>(context: NSManagedObjectContext, type: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        return (try? context.fetch(request)) ?? []
    }
    
    func findObject<T: NSManagedObject>(context: NSManagedObjectContext, type: T.Type, predicate: NSPredicate) -> T? {
        return fetchList(context: context, type: type, predicate: predicate).first
    }
    
    
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
        context.reset()
    }
    
    func perform(_ block: @escaping (_ writeContext: NSManagedObjectContext) -> Void) {
        let context = backgroundContext
        context.perform {
            block(context)
        }
    }
    
    func performAndSave(_ block: @escaping (_ writeContext: NSManagedObjectContext) -> Void) {
        perform { writeContext in
            block(writeContext)
            self.saveContext(writeContext)
        }
    }
}

extension CoreDataManager: CreateListInLocalStorageProtocol {
    func createTodos(containsOf: [(id: String, title: String, subtitle: String, completed: Bool)]) {
        perform {[weak self] writeContext in
            
            for item in containsOf {
                let toDo = ListItemLocalStore(context: writeContext)
                toDo.id = item.id
                toDo.title = item.title
                toDo.subtitle = item.subtitle
                toDo.date = Date().timeIntervalSince1970
                toDo.completed = item.completed
                self?.saveContext(writeContext)
            }
            
        }
//        performAndSave { writeContext in
//            containsOf.forEach({
//                let toDo = ListItemLocalStore(context: writeContext)
//                toDo.id = $0.id
//                toDo.title = $0.title
//                toDo.subtitle = $0.subtitle
//                toDo.date = Date().timeIntervalSince1970
//                toDo.completed = $0.completed
//            })
//        }
    }
}

extension CoreDataManager: ChangeStatusTaskInLocalStorageProtocol {
    func setCompleted(status: Bool, todoId: String) {
        performAndSave {[weak self] writeContext in
            guard let model = self?.findObject(context: writeContext,
                                   type: ListItemLocalStore.self,
                                   predicate: NSPredicate(format: "id = \(todoId)"))
            else { return }
            
            model.completed = status
        }
    }
}

extension CoreDataManager: FetchFromLocalStorageProtocol {
    func fetchTodos(callback: @escaping ([ListItemLocalStore]) -> ()) {
        perform {[weak self] context in
            let list = self?.fetchList(context: context, type: ListItemLocalStore.self) ?? []
            callback(list)
        }
    }
}
