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
    
    func fetch<T: NSManagedObject>(context: NSManagedObjectContext, type: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        request.predicate = predicate
        return (try? context.fetch(request)) ?? []
    }
    
    func findObject<T: NSManagedObject>(context: NSManagedObjectContext, type: T.Type, predicate: NSPredicate) -> T? {
        return fetch(context: context, type: type, predicate: predicate).first
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save() //изменения произошедшие в контексте
            } catch {
                context.rollback() //откатывает изменения
            }
        }
        context.reset() //возвращает контекст в его базовое состояние
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

//MARK: - CreateInLocalStorageProtocol
extension CoreDataManager: CreateInLocalStorageProtocol {
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
    }
}

//MARK: - FetchFromLocalStorageProtocol
extension CoreDataManager: FetchFromLocalStorageProtocol {
    func fetchTodos(callback: @escaping ([ListItemLocalStore]) -> ()) {
        perform {[weak self] context in
            let list = self?.fetch(context: context, type: ListItemLocalStore.self) ?? []
            callback(list)
        }
    }
}

//MARK: - DeleteItemInLocalStorageProtocol
extension CoreDataManager: DeleteItemInLocalStorageProtocol {
    func deleteTodo(id: String) {
        performAndSave {[weak self] writeContext in
            guard let model = self?.findObject(context: writeContext,
                                   type: ListItemLocalStore.self,
                                   predicate: NSPredicate(format: "id == %@", id))
            else { return }
            writeContext.delete(model)
        }
    }
}

//MARK: - ChangesTaskInLocalStorageProtocol
extension CoreDataManager: ChangesTaskInLocalStorageProtocol {
    func editStatus(status: Bool, todoId: String) {
        performAndSave {[weak self] writeContext in
            guard let model = self?.findObject(context: writeContext,
                                   type: ListItemLocalStore.self,
                                   predicate: NSPredicate(format: "id == %@", todoId))
            else { return }
            
            model.completed = status
        }
    }
    
    func editTodo(id: String, title: String, subtitle: String, date: Date) {
        performAndSave {[weak self] writeContext in
            guard let model = self?.findObject(context: writeContext,
                                   type: ListItemLocalStore.self,
                                   predicate: NSPredicate(format: "id == %@", id))
            else { return }
            
            model.title = title
            model.subtitle = subtitle
            model.date = date.timeIntervalSince1970
        }
    }
}

//MARK: - FindTodoInLocalStore                                                                              //-//
extension CoreDataManager: FindTodoInLocalStore {
    func findTodo(id: String, callback: @escaping (ListItemLocalStore) -> ()) {
        perform {[weak self] context in
            guard let model = self?.findObject(context: context,
                                   type: ListItemLocalStore.self,
                                   predicate: NSPredicate(format: "id == %@", id))
            else { return }
            
            callback(model)
        }
    }
}
