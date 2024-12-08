//
//  ListViewController.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 03.12.2024.
//

import UIKit

protocol ListPresenterProtocol {
    func loadData()
    func editStatus(completed: Bool, item: ListItemEntity)
    func edit(item: ListItemEntity)
    func share(item: ListItemEntity)
    func delete(item: ListItemEntity) //добавить удаление в делегате?
    func createNote()
}


class ListViewController: UIViewController {
    
    var data: [ListItemEntity] = []
    var presenter: ListPresenterProtocol?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        return controller
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListItemCell.self, forCellReuseIdentifier: String(describing: ListItemCell.self))
        
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
    
    private lazy var loadIndicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .accentYellow
        
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.heightAnchor.constraint(equalToConstant: 100),
            indicator.widthAnchor.constraint(equalToConstant: 100),
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Задачи"
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.loadData() //разве не в этот момент нужно включать иникатор загрузки ??
        //почему это требование протокола а не внутренная возможность.....
        //каждый раз когда появляется экран!
    }
    
    @objc private func newNoteAction() {
        presenter?.createNote()
    }
    
    private func setToolbarTitle(count: Int) {
        toolbarLabel.text = "\(count) Задач"
        toolbarLabel.sizeToFit()
    }
    
    private func editActionForItem(_ item: ListItemEntity) {
        presenter?.edit(item: item)
    }
    
    private func shareActionForItem(_ item: ListItemEntity) {
        presenter?.share(item: item)
    }
    
    private func deleteActionForItem(_ item: ListItemEntity) {
        presenter?.delete(item: item)
        guard let index = data.firstIndex(of: item) else { return }
        data.remove(at: index)
        setToolbarTitle(count: data.count)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

//MARK: - ListViewProtocol
extension ListViewController: ListViewProtocol {
        func deliver(_ data: [ListItemEntity]) {
            self.data = data
            tableView.reloadData()
            setToolbarTitle(count: data.count)
        }
    
        func showLoader(isLoading: Bool) {
            isLoading ? loadIndicator.startAnimating() : loadIndicator.stopAnimating()
        }
}

//MARK: - CellDelegateProtocol
extension ListViewController: CellDelegateProtocol {
    func cell(_ cell: ListItemCell, completed: Bool) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }
        let model = data[index]
        presenter?.editStatus(completed: !model.completed, item: model)
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
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let model = data[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {_ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(named: "edit")) {[weak self, model] _ in
                self?.editActionForItem(model)
            }
            let shareAction = UIAction(title: "Поделиться", image: UIImage(named: "export")) {[weak self, model] _ in
                self?.shareActionForItem(model)
            }
            let deleteAction = UIAction(title: "Удалить", image: UIImage(named: "trash"), attributes: .destructive) {[weak self, model] _ in
                self?.deleteActionForItem(model)
            }
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
}


