//
//  ListPresenterTest.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 08.12.2024.
//

import XCTest
@testable import ToDoListUIKit

// Мокируем все зависимости
class MockListInteractor: ListInteractorProtocol {
    var loadDataCalled = false
    var editStatusCalled = false
    var deleteCalled = false
    var searchCalled = false
    
    func loadData() {
        loadDataCalled = true
    }
    
    func editStatus(completed: Bool, item: ListItemEntity) {
        editStatusCalled = true
    }
    
    func delete(item: ListItemEntity) {
        deleteCalled = true
    }
    
    func search(text: String) {
        searchCalled = true
    }
}

class MockListView: ListViewProtocol {
    var deliverCalled = false
    var showLoaderCalled = false
    var deliveredData: [ListItemEntity]?
    
    func deliver(_ data: [ListItemEntity]) {
        deliverCalled = true
        deliveredData = data
    }
    
    func showLoader(isLoading: Bool) {
        showLoaderCalled = true
    }
}

class MockListRouter: ListRouter {
    var routeToDetailsCalled = false
    var routeToDetailsId: String?
    
    func routeToDetail(id: String?) {
        routeToDetailsCalled = true
        routeToDetailsId = id
    }
}

// Основной класс тестов
class ListPresenterTests: XCTestCase {
    
    var presenter: ListPresenter!
    var mockInteractor: MockListInteractor!
    var mockView: MockListView!
    var mockRouter: MockListRouter!
    
    override func setUp() {
        super.setUp()
        
        mockInteractor = MockListInteractor()
        mockView = MockListView()
        mockRouter = MockListRouter()
        
        presenter = ListPresenter()
        presenter.interactor = mockInteractor
        presenter.view = mockView
        presenter.router = mockRouter
    }
    
    override func tearDown() {
        presenter = nil
        mockInteractor = nil
        mockView = nil
        mockRouter = nil
        
        super.tearDown()
    }
    
    func testLoadDataCallsInteractorLoadData() {
        presenter.loadData()
        XCTAssertTrue(mockInteractor.loadDataCalled)
    }
    
    func testEditStatusCallsInteractorEditStatus() {
        let item = createItem()
        presenter.editStatus(completed: true, item: item)
        XCTAssertTrue(mockInteractor.editStatusCalled)
    }
    
    func testDeleteCallsInteractorDelete() {
        let item = createItem()
        presenter.delete(item: item)
        XCTAssertTrue(mockInteractor.deleteCalled)
    }
    
    func testDeliverDataCallsViewDeliver() {
        let data = [createItem()]
        presenter.deliverData(data)
        XCTAssertTrue(mockView.deliverCalled)
        XCTAssertEqual(mockView.deliveredData, data)
    }
    
    func testPresentLoadingCallsViewShowLoader() {
        presenter.presentLoading(true)
        XCTAssertTrue(mockView.showLoaderCalled)
    }
    
    func testEditCallsRouterRouteToDetails() {
        let item = createItem()
        presenter.edit(item: item)
        XCTAssertTrue(mockRouter.routeToDetailsCalled)
        XCTAssertEqual(mockRouter.routeToDetailsId, item.id)
    }
    
    func testCreateNoteCallsRouterRouteToDetailsWithNilId() {
        presenter.createTodo()
        XCTAssertTrue(mockRouter.routeToDetailsCalled)
        XCTAssertNil(mockRouter.routeToDetailsId)
    }
    
    func createItem() -> ListItemEntity {
        return .init(id: "1", title: "Item", subtitle: "subtitle", date: Date(), completed: .random())
    }
}
