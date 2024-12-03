//
//  ToDoCell.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 03.12.2024.
//

import UIKit

protocol ToDoCellDelegate: AnyObject {
    func cell(_ cell: ToDoCell, completed: Bool)
}

class ToDoCell: UITableViewCell {
    
    weak var delegate: ToDoCellDelegate?
    
    private lazy var checkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "CheckmsrkSelected"), for: .selected)
        button.setImage(UIImage(named: "CheckmsrkDisabled"), for: .normal)
        
        button.addTarget(self, action: #selector(checkButtonAction), for: .touchUpInside)
        
        contentView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
        
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return button
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(descriptionSubtitle)
        stack.addArrangedSubview(taskDate)
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        return stack
    }()
    
    private lazy var title: UILabel = {
        let title = UILabel()
        title.attributedText = normalTitleAttrStr(title: "")
        return title
    }()
    
    private lazy var descriptionSubtitle: UILabel = {
        let descriptionSubtitle = UILabel()
        descriptionSubtitle.textColor = .textWhite
        descriptionSubtitle.font = .caption
        return descriptionSubtitle
    }()
    
    private lazy var taskDate: UILabel = {
        let date = UILabel()
        date.textColor = .textGray
        date.font = .caption
        return date
    }()
    
    private func normalTitleAttrStr(title: String) -> NSAttributedString {
        return .init(string: title, attributes: [.foregroundColor: UIColor.textWhite,
                                                 .font: UIFont.button])
    }
    
    private func completedTitleAttrStr(title: String) -> NSAttributedString {
        return .init(string: title, attributes: [.foregroundColor: UIColor.textGray,
                                                 .font: UIFont.button,
                                                 NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                                                 NSAttributedString.Key.strikethroughColor: UIColor.textGray])
    }
    
    @objc private func checkButtonAction() {
        let isCompleted = !checkButton.isSelected
        
        configure(title: title.attributedText?.string ?? "",
                  description: descriptionSubtitle.text ?? "",
                  date: taskDate.text ?? "",
                  isCompleted: isCompleted)
        
        delegate?.cell(self, completed: isCompleted)
        
    }
    
    func configure(title:String, description:String, date:String, isCompleted: Bool) {
        
        UIView.transition(with: self.title, duration: 0.3, options: .transitionCrossDissolve) {
            self.title.attributedText = isCompleted ? self.completedTitleAttrStr(title: title) : self.normalTitleAttrStr(title: title)
        }
        
        self.descriptionSubtitle.text = description
        self.taskDate.text = date
        
        self.checkButton.isSelected = isCompleted
        
        UIView.transition(with: self.descriptionSubtitle, duration: 0.3, options: .transitionCrossDissolve) {
            self.descriptionSubtitle.textColor = isCompleted ? .textGray : .textWhite
        }
    }
    
    override func didMoveToWindow() {
        contentView.backgroundColor = .black
        _ = checkButton
        _ = stack
    }
}
