//
//  SupabaseManager.swift
//  The Elseform Standard
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabase = SupabaseClient(
        supabaseURL: URL(string: "https://rdywvwljudifvqyfkqff.supabase.co")!,
        supabaseKey: "sb_publishable_B5tPZj4HpwTLFZKyQpWFuA_EkuCuqcA"
    )
    
    private init() {}
    
    func fetchTodaysHeadlines() async throws -> [DailyHeadline] {
        let todayEastern = DateFormatter.supabaseDate.string(from: Date())
        
        let response: [DailyHeadline] = try await supabase
            .from("daily_headlines")
            .select("""
                id,
                story_id,
                position,
                display_date,
                stories (
                    id,
                    headline,
                    teaser,
                    body,
                    story_type
                )
            """)
            .eq("display_date", value: todayEastern)
            .order("position")
            .execute()
            .value
        
        return response
    }
}

extension DateFormatter {
    // converts date field from Supabase to Louisville time to avoid 1-hour-from-midnight errors
    static let supabaseDate: DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Kentucky/Louisville")
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
}
