//
//  Habit.swift
//  Mooded
//
//  Created by Gus Rasch on 2/4/25.
//


import Foundation

struct Habit: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var isEnabled: Bool
    var notificationTime: Date?
    
    init(id: UUID = UUID(), name: String, isEnabled: Bool = true, notificationTime: Date? = nil) {
        self.id = id
        self.name = name
        self.isEnabled = isEnabled
        self.notificationTime = notificationTime
    }
}

struct HabitCompletion: Identifiable, Codable {
    let id: UUID
    let habitId: UUID
    let date: Date
    
    init(id: UUID = UUID(), habitId: UUID, date: Date = Date()) {
        self.id = id
        self.habitId = habitId
        self.date = date
    }
}