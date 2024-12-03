//
//  ListViewController.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 03.12.2024.
//

import UIKit

class ListViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        tableView.register(ToDoCell.self, forCellReuseIdentifier: String(describing: ToDoCell.self))
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}


extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: ToDoCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ToDoCell else { return UITableViewCell() }
        
        cell.configure(title: "title",
                       description: "description",
                       date: "11.11.11",
                       isCompleted: Bool.random())
        cell.delegate = self
        
        return cell
    }
    
    
}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: ToDoCellDelegate {
    func cell(_ cell: ToDoCell, completed: Bool) {
        
    }
}
