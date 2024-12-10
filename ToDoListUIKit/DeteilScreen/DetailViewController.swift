//
//  DetailViewController.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 07.12.2024.
//

import UIKit

protocol DetailPresenterProtocol {
    func prepare()
    var title: String { get set }
    var description: String { get set }
    var date: Date { get }
}

class DetailViewController: UIViewController {
    var presenter: DetailPresenterProtocol?
    
    private lazy var titleAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.bold34, .foregroundColor: UIColor.white]
    private lazy var disabledTitleAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.bold34, .foregroundColor: UIColor.textGray]
    private lazy var dateAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.caption,
                                                                  .foregroundColor: UIColor.textGray,
                                                                  .paragraphStyle: paragraph]
    private lazy var descriptionAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.button, .foregroundColor: UIColor.white]
    private lazy var disabledDescriptionAttributes: [NSAttributedString.Key : Any] = [.font: UIFont.button, .foregroundColor: UIColor.textGray]
    
    private var paragraph: NSParagraphStyle {
        let paragraph = NSMutableParagraphStyle()
        paragraph.paragraphSpacingBefore = 8
        paragraph.paragraphSpacing = 16
        return paragraph
    }
    
    private var taskTitle: String {
        get { presenter?.title ?? String() }
        set { presenter?.title = newValue }
    }
    
    private var taskDescription: String {
        get { presenter?.description ?? String() }
        set { presenter?.description = newValue }
    }
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .black
        view.delegate = self
        view.contentInset.left = 20
        view.contentInset.right = 20
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.view.topAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
        return view
    }()
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .never
        presenter?.prepare()
        registerKeyboardNotifications()
        buildText()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func dateString() -> String {
        
        let date = presenter?.date ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: date)
        
        return "\n\(dateString)\n"
    }
    
    private func buildText() {
        
        let title = taskTitle.isEmpty ? "Заголовок" : taskTitle
        let description = taskDescription.isEmpty ? "Описание" : taskDescription
        
        let attrText = NSMutableAttributedString()
        
        attrText.append(NSAttributedString(string: title,
                                           attributes: !taskTitle.isEmpty ? titleAttributes : disabledTitleAttributes))
        
        attrText.append(NSAttributedString(string: dateString(), attributes: dateAttributes))
        
        attrText.append(NSAttributedString(string: description,
                                           attributes: !taskDescription.isEmpty ? descriptionAttributes : disabledDescriptionAttributes))
        
        textView.attributedText = attrText
    }
    
    private func registerKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset.bottom = .zero
        } else {
            textView.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        }

        textView.verticalScrollIndicatorInsets.bottom = textView.contentInset.bottom
    }
}

extension DetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let sourceString = textView.attributedText.string
        guard let dateRange = sourceString.range(of: dateString()) else { return false }
        guard let replacementRange = Range<String.Index>(range, in: sourceString) else { return false }
        
        if replacementRange.upperBound <= dateRange.lowerBound { // Изменяется заголвок
            taskTitle = taskTitle.replacingCharacters(in: replacementRange, with: text)
            
        } else if replacementRange.lowerBound >= dateRange.upperBound { // Изменяется описание
            
            let tempRange = NSRange(location: range.location - dateRange.upperBound.utf16Offset(in: sourceString),
                                    length: range.length)
            guard let bTempRange = Range<String.Index>(tempRange, in: taskDescription) else { return false }
            
            taskDescription = taskDescription.replacingCharacters(in: bTempRange, with: text)
        } else { // Указатель на дате
            return false
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let storeSelectedRange = textView.selectedRange
        buildText()
        textView.selectedRange = storeSelectedRange
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let sourceString = textView.attributedText.string
        guard let selectedRange = Range<String.Index>(textView.selectedRange, in: sourceString) else { return }
        guard let dateRange = sourceString.range(of: dateString()) else { return }
        
        if selectedRange.upperBound <= dateRange.lowerBound {
            textView.typingAttributes = titleAttributes
            
            if taskTitle.isEmpty {
                textView.selectedRange = NSRange(location: 0, length: 0)
            }
            
        } else if selectedRange.lowerBound >= dateRange.upperBound {
            textView.typingAttributes = descriptionAttributes
            
            if taskDescription.isEmpty {
                let location = dateRange.upperBound.utf16Offset(in: sourceString)
                textView.selectedRange = NSRange(location: location, length: 0)
            }
        } else {
            if selectedRange.lowerBound < dateRange.lowerBound && selectedRange.upperBound > dateRange.lowerBound {
                
                let location = selectedRange.lowerBound.utf16Offset(in: sourceString)
                let length = dateRange.lowerBound.utf16Offset(in: sourceString) - location
                
                textView.selectedRange = NSRange(location: location,
                                                 length: length)
                
            } else if selectedRange.upperBound > dateRange.upperBound && selectedRange.lowerBound < dateRange.lowerBound {
                
                let location = dateRange.lowerBound.utf16Offset(in: sourceString)
                let length = selectedRange.upperBound.utf16Offset(in: sourceString) - location
                
                textView.selectedRange = NSRange(location: location,
                                                 length: length)
            } else {
                textView.selectedRange = NSRange(location: 0, length: 0)
            }
        }
    }
}

extension DetailViewController: DetailViewProtocol {
    func showData() {
        buildText()
    }
}

