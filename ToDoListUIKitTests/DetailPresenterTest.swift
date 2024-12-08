//
//  DetailPresenterTest.swift
//  ToDoListUIKitTests
//
//  Created by Anna Ruslanovna on 08.12.2024.
//

import XCTest
@testable import ToDoListUIKit

// Мок для DetailInteractorProtocol
class MockDetailInteractor: DetailInteractorProtocol {
    var title: String = ""
    var description: String = ""
    var date: Date = Date()
    
    var loadDataCalled = false
    
    func loadData() {
        loadDataCalled = true
    }
}

// Мок для DetailViewProtocol
class MockDetailView: DetailViewProtocol {
    var showDataCalled = false
    
    func showData() {
        showDataCalled = true
    }
}

// Тесты для DetailPresenter
class DetailPresenterTests: XCTestCase {
    
    var presenter: DetailPresenter!
    var mockInteractor: MockDetailInteractor!
    var mockView: MockDetailView!
    
    override func setUp() {
        super.setUp()
        
        mockInteractor = MockDetailInteractor()
        mockView = MockDetailView()
        
        presenter = DetailPresenter()
        presenter.interactor = mockInteractor
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockInteractor = nil
        mockView = nil
        
        super.tearDown()
    }
    
    // Тестируем метод prepare, чтобы убедиться, что он вызывает loadData у interactor
    func testPrepareCallsLoadData() {
        presenter.prepare()
        
        XCTAssertTrue(mockInteractor.loadDataCalled, "prepare() должен вызвать loadData() у interactor.")
    }
    
    // Тестируем свойство title
    func testTitleGetterSetter() {
        let testTitle = "Test Title"
        
        // Устанавливаем значение
        presenter.title = testTitle
        
        // Проверяем, что значение в interactor изменилось
        XCTAssertEqual(mockInteractor.title, testTitle, "title должен устанавливать значение в interactor.")
        
        // Проверяем геттер
        let title = presenter.title
        XCTAssertEqual(title, testTitle, "title должен возвращать правильное значение из interactor.")
    }
    
    // Тестируем свойство description
    func testDescriptionGetterSetter() {
        let testDescription = "Test Description"
        
        // Устанавливаем значение
        presenter.description = testDescription
        
        // Проверяем, что значение в interactor изменилось
        XCTAssertEqual(mockInteractor.description, testDescription, "description должен устанавливать значение в interactor.")
        
        // Проверяем геттер
        let description = presenter.description
        XCTAssertEqual(description, testDescription, "description должен возвращать правильное значение из interactor.")
    }
    
    // Тестируем свойство date
    func testDateGetter() {
        let testDate = Date(timeIntervalSince1970: 1234567890)
        mockInteractor.date = testDate
        
        // Проверяем, что геттер возвращает правильную дату
        let date = presenter.date
        XCTAssertEqual(date, testDate, "date должен возвращать правильную дату из interactor.")
    }
    
    // Тестируем метод presentData, чтобы убедиться, что он вызывает showData у view
    func testPresentDataCallsShowData() {
        presenter.presentData()
        
        XCTAssertTrue(mockView.showDataCalled, "presentData() должен вызвать showData() у view.")
    }
}
