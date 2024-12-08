//
//  ListInteractorTest.swift
//  ToDoListUIKitTests
//
//  Created by Anna Ruslanovna on 08.12.2024.
//

import XCTest
import CoreData
@testable import ToDoListUIKit

// Моки для зависимостей

class MockListNetworkManager: ListNetworkProtocol {
    var loadTodosCalled = false
    var resultToReturn: Result<[TodoAPIModel], Error>!
    
    func loadTodos(completion: @escaping (ResultCompletion<[TodoAPIModel]>) -> Void) {
        loadTodosCalled = true
        completion(resultToReturn)
    }
}

class MockLocalStore: CreateInLocalStorageProtocol, FetchFromLocalStorageProtocol, DeleteItemInLocalStorageProtocol, ChangesTaskInLocalStorageProtocol {
    var createTodosCalled = false
    var fetchTodosCalled = false
    var deleteTodoCalled = false
    var editStatusCalled = false
    var editTodoCalled = false
    var fetchedTodos: [ListItemLocalStore] = []
    
    func createTodos(containsOf: [(id: String, title: String, subtitle: String, completed: Bool)]) {
        createTodosCalled = true
    }
    
    func fetchTodos(callback: @escaping ([ListItemLocalStore]) -> ()) {
        fetchTodosCalled = true
        callback(fetchedTodos)
    }
    
    func deleteTodo(id: String) {
        deleteTodoCalled = true
    }
    
    func editStatus(status: Bool, todoId: String) {
        editStatusCalled = true
    }
    
    func editTodo(id: String, title: String, subtitle: String, date: Date) {
        editTodoCalled = true
    }
}

class MockListInteractorOutput: ListInteractorOutputProtocol {
    var deliverDataCalled = false
    var deliverErrorCalled = false
    var presentLoadingCalled = false
    var deliveredData: [ListItemEntity]?
    var error: Error?
    var expectation: XCTestExpectation?
    
    func deliverData(_ data: [ListItemEntity]) {
        expectation?.fulfill()
        deliverDataCalled = true
        deliveredData = data
    }
    
    func deliverError(_ error: Error) {
        deliverErrorCalled = true
        self.error = error
    }
    
    func presentLoading(_ isLoading: Bool) {
        presentLoadingCalled = true
    }
}

// Тесты для ListInteractor

class ListInteractorTests: XCTestCase {
    
    var interactor: ListInteractor!
    var mockNetworkManager: MockListNetworkManager!
    var mockLocalStore: MockLocalStore!
    var mockPresenter: MockListInteractorOutput!
    
    override func setUp() {
        super.setUp()
        
        mockNetworkManager = MockListNetworkManager()
        mockLocalStore = MockLocalStore()
        mockPresenter = MockListInteractorOutput()
        
        interactor = ListInteractor()
        interactor.networkManager = mockNetworkManager
        interactor.localStore = mockLocalStore
        interactor.presenter = mockPresenter
    }
    
    override func tearDown() {
        interactor = nil
        mockNetworkManager = nil
        mockLocalStore = nil
        mockPresenter = nil
        
        super.tearDown()
    }
    
    // Проверка, что данные загружаются из локального хранилища, если они там есть
    func testLoadData_LocalDataAvailable() {
        
        mockPresenter.expectation = expectation(description: "testLoadData_LocalDataAvailable")
        mockPresenter.expectation?.expectedFulfillmentCount = 1
        let localItem = ListItemLocalStore(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        localItem.title = "Test"
        
        mockLocalStore.fetchedTodos = [localItem]
        
        interactor.loadData()
        
        // Проверяем, что presenter получил данные
        waitForExpectations(timeout: 5) {[weak self] error in
            if let error = error {
                XCTFail("WaitForExpectationsWithTimeout errored: \(error)")
            } else {
                XCTAssertTrue(self?.mockPresenter.deliverDataCalled == true)
                XCTAssertEqual(self?.mockPresenter.deliveredData?.count, 1)
                XCTAssertEqual(self?.mockPresenter.deliveredData?.first?.title, "Test")
            }
        }
    }
    
    // Проверка, что если данных в локальном хранилище нет, они загружаются из сети и сохраняются
    func testLoadData_NoLocalData_LoadFromNetwork() {
        
        mockPresenter.expectation = expectation(description: "testLoadData_LocalDataAvailable")
        mockPresenter.expectation?.expectedFulfillmentCount = 1
        
        mockLocalStore.fetchedTodos = [] // Нет данных в локальном хранилище
        let mockTodos = [TodoAPIModel(id: 1, todo: "Todo 1", completed: false)]
        mockNetworkManager.resultToReturn = .success(mockTodos)
        
        interactor.loadData()
        
        // Проверяем, что данные были загружены с сети
        XCTAssertTrue(mockNetworkManager.loadTodosCalled)
        XCTAssertTrue(mockPresenter.presentLoadingCalled)
        XCTAssertTrue(mockLocalStore.createTodosCalled)
        
        waitForExpectations(timeout: 5) {[weak self] error in
            if let error = error {
                XCTFail("WaitForExpectationsWithTimeout errored: \(error)")
            } else {
                XCTAssertTrue(self?.mockPresenter.deliverDataCalled == true)
            }
        }
        
    }
    
    // Проверка, что если произошла ошибка при загрузке данных из сети, presenter получает ошибку
    func testLoadData_NetworkError() {
        mockLocalStore.fetchedTodos = [] // Нет данных в локальном хранилище
        mockNetworkManager.resultToReturn = .failure(NSError(domain: "TestError", code: 1, userInfo: nil))
        
        interactor.loadData()
        
        // Проверяем, что presenter получил ошибку
        XCTAssertTrue(mockPresenter.deliverErrorCalled)
        XCTAssertNotNil(mockPresenter.error)
    }
    
    // Проверка, что редактирование статуса задачи вызывает метод локального хранилища
    func testEditStatus() {
        let item = ListItemEntity(id: "1", title: "Test", subtitle: "Test subtitle", date: Date(), completed: false)
        
        interactor.editStatus(completed: true, item: item)
        
        // Проверяем, что метод локального хранилища был вызван
        XCTAssertTrue(mockLocalStore.editStatusCalled)
    }
    
    // Проверка, что удаление задачи вызывает метод локального хранилища
    func testDelete() {
        let item = ListItemEntity(id: "1", title: "Test", subtitle: "Test subtitle", date: Date(), completed: false)
        
        interactor.delete(item: item)
        
        // Проверяем, что метод локального хранилища был вызван
        XCTAssertTrue(mockLocalStore.deleteTodoCalled)
    }
    
    // Проверка поиска задач
    func testSearch() {
        
        mockPresenter.expectation = expectation(description: "testLoadData_LocalDataAvailable")
        mockPresenter.expectation?.expectedFulfillmentCount = 2
        
        let item1 = TodoAPIModel(id: 1, todo: "Test", completed: true)
        let item2 = TodoAPIModel(id: 1, todo: "Another", completed: true)
        
        mockNetworkManager.resultToReturn = .success([item1, item2])
        interactor.loadData() // Загружаем тестовые данные
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.interactor.search(text: "Test")
        }
        
        waitForExpectations(timeout: 5) {[weak self] error in
            if let error = error {
                XCTFail("WaitForExpectationsWithTimeout errored: \(error)")
            } else {
                // Проверяем, что был выполнен поиск
                XCTAssertTrue(self?.mockPresenter.deliverDataCalled == true)
                XCTAssertEqual(self?.mockPresenter.deliveredData?.count, 1)  // Ожидаем, что будет найден 1 элемент
            }
        }
    }
}
