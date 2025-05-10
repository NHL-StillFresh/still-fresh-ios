//
//  database.swift
//  Still Fresh
//
//  Created by Jesse van der Voet on 10/05/2025.
//

import Supabase
import Foundation

/// Enum used for error handling
enum DatabaseError: Error {
    case connectionFailed
    case clientNotInitialized
    case queryFailed
    case invalidResult
}

/// Class that manages the database using a singleton client
class DatabaseClient {
    static let shared = DatabaseClient()
    private var client:SupabaseClient
    
    private init() {
        guard let supabaseURL = URL(string: "https://rfaddfahfpssnxrbxplc.supabase.co") else {
            fatalError(#function + ": Failed to initialize URL")
        }
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmYWRkZmFoZnBzc254cmJ4cGxjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY1MTQ4ODEsImV4cCI6MjA2MjA5MDg4MX0.3cUGivB6XZTWC-7-MrEnatARAWJAap3oC5MCAmqnfo0"
        )
    }
    
    /// Function that returns the Supabase client.
    ///
    ///  - Returns: Instance of `SupabaseClient`
    public func getClient() -> SupabaseClient {
        return self.client
    }
}
