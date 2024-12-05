//
//  ListItemEntity.swift
//  ToDoListUIKit
//
//  Created by Anna Ruslanovna on 05.12.2024.
//

import Foundation

struct ListItemEntity: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let title: String
    let subtitle: String
    let date: Date
    let completed: Bool
}
