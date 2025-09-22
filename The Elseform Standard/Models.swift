//
//  Models.swift
//  The Elseform Standard
//

import Foundation

struct Story: Codable, Identifiable {
    let id: UUID
    let headline: String
    let teaser: String
    let body: String
    let story_type: String
}

struct DailyHeadline: Codable, Identifiable {
    let id: UUID
    let story_id: UUID
    let position: Int
    let display_date: String
    let stories: Story?
}
