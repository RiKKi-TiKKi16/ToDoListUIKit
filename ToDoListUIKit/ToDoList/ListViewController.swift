//
//  ListViewController.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 03.12.2024.
//

import UIKit

protocol ListPresenterProtocol {
    func loadData()
}

class ListViewController: UIViewController, ListViewProtocol {
    var data: [ListItemEntity] = []
    var presenter: ListPresenterProtocol?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)

        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
        ])
        return tableView
    }()
    
    private lazy var toolbarLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.barTintColor = .backgroundGray
        toolbar.tintColor = .accentYellow
        toolbar.isTranslucent = false
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.heightAnchor.constraint(equalToConstant: 49),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let label = UIBarButtonItem(customView: toolbarLabel)
        let newNote = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newNoteAction))
        
        toolbar.setItems([spacer, label, spacer, newNote], animated: false)
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.setToolbarHidden(false, animated: true)
        //self.navigationController?.toolbarItems
        
        
        navigationItem.title = "Задачи"
        navigationItem.searchController = searchController
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListItemCell.self, forCellReuseIdentifier: String(describing: ListItemCell.self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.loadData()
    }
    
    @objc private func newNoteAction() {
        print("New note")
    }
    
    private func setToolbarTitle(_ title: String) {
        toolbarLabel.text = title
        toolbarLabel.sizeToFit()
    }
    
    func deliver(_ data: [ListItemEntity]) {
        self.data = data
        tableView.reloadData()
        setToolbarTitle("\(data.count) Задач")
    }

}

extension ListViewController: CellDelegateProtocol {
    func cell(_ cell: ListItemCell, completed: Bool) {
        
    }
}

//MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: ListItemCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ListItemCell else { return UITableViewCell() }
        
        let model = data[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        cell.configure(title: model.title,
                       description: model.subtitle,
                       date: dateFormatter.string(from: model.date),
                       isCompleted: model.completed)
        cell.delegate = self
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    
}

