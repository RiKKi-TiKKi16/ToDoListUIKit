//
//  DetaiInteractorTest.swift
//  ToDoListUIKitTests
//
//  Created by Anna Ruslanovna on 08.12.2024.
//

import XCTest
import CoreData
@testable import ToDoListUIKit

// Мок для CreateInLocalStorageProtocol
class MockLocalStorage: ChangesTaskInLocalStorageProtocol, CreateInLocalStorageProtocol, FindTodoInLocalStore {
    func editStatus(status: Bool, todoId: String) {}
    
    var createTodosCalled = false
    var editTodoCalled = false
    var findTodoCalled = false
    var todoToReturn: ListItemLocalStore?
    
    func createTodos(containsOf: [(id: String, title: String, subtitle: String, completed: Bool)]) {
        createTodosCalled = true
    }
    
    func editTodo(id: String, title: String, subtitle: String, date: Date) {
        editTodoCalled = true
    }
    
    func findTodo(id: String, callback: @escaping (ToDoListUIKit.ListItemLocalStore) -> ()) {
        findTodoCalled = true
        if let todo = todoToReturn {
            callback(todo)
        }
    }
}

// Мок для DetailInteractorOutputProtocol
class MockDetailInteractorOutput: DetailInteractorOutputProtocol {
    var presentDataCalled = false
    var expectation: XCTestExpectation?
    
    func presentData() {
        expectation?.fulfill()
        presentDataCalled = true
    }
}

// Тесты для DetailInteractor
class DetailInteractorTests: XCTestCase {
    
    var interactor: DetailInteractor!
    var mockLocalStore: MockLocalStorage!
    var mockPresenter: MockDetailInteractorOutput!
    
    override func setUp() {
        super.setUp()
        
        mockLocalStore = MockLocalStorage()
        mockPresenter = MockDetailInteractorOutput()
        
        interactor = DetailInteractor(id: "123")
        interactor.localStore = mockLocalStore
        interactor.presenter = mockPresenter
    }
    
    override func tearDown() {
        interactor = nil
        mockLocalStore = nil
        mockPresenter = nil
        
        super.tearDown()
    }
    
    // Проверка метода loadData, если задача существует в локальном хранилище
    func testLoadData_TodoExists() {
        let mockTodo = ListItemLocalStore(context: .init(concurrencyType: .mainQueueConcurrencyType))
        
        mockTodo.title = "Test Title"
        mockTodo.subtitle = "Test Subtitle"
        mockTodo.date = 12345
        
        mockPresenter.expectation = expectation(description: "Test")
        mockPresenter.expectation?.expectedFulfillmentCount = 1
        
        mockLocalStore.todoToReturn = mockTodo
        interactor.localStore = mockLocalStore
        
        interactor.loadData()
        
        XCTAssertTrue(mockLocalStore.findTodoCalled, "findTodo() должен быть вызван")
        XCTAssertEqual(interactor.title, "Test Title", "title должен быть правильно загружен")
        XCTAssertEqual(interactor.description, "Test Subtitle", "description должен быть правильно загружен")
        XCTAssertEqual(interactor.date, Date(timeIntervalSince1970: 12345), "date должен быть правильно загружен")
        
        wait(for: [mockPresenter.expectation!])
        
        XCTAssertTrue(mockPresenter.presentDataCalled, "presentData() должен быть вызван в конце загрузки данных")
    }
    
    // Проверка метода save, когда происходит изменение title
    func testSave_TitleChanged() {
        interactor.title = "New Title"
        
        XCTAssertTrue(mockLocalStore.editTodoCalled, "editTodo() должен быть вызван при изменении title")
    }
    
    // Проверка метода save, когда происходит изменение description
    func testSave_DescriptionChanged() {
        interactor.description = "New Description"
        
        XCTAssertTrue(mockLocalStore.editTodoCalled, "editTodo() должен быть вызван при изменении description")
    }
    
    // Проверка, что createTodo() вызывается при отсутствии id
    func testCreateTodo_WhenIdIsNil() {
        let interactorWithoutId = DetailInteractor(id: nil)
        interactorWithoutId.localStore = mockLocalStore
        
        interactorWithoutId.title = "New Title"
        
        XCTAssertTrue(mockLocalStore.createTodosCalled, "createTodos() должен быть вызван, если id задачи отсутствует")
    }
}
