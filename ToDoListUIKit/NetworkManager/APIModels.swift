//
//  APIModels.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation
// MARK: - Forma
struct Forma: Codable {
    let todos: [APIModel]
}

// MARK: - Todo
struct APIModel: Codable {
    let id: Int
    let todo: String
    let completed: Bool
}
